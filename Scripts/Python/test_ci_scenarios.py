"""Exercise CLI decisions against the checked-in workflow; deployments are spies."""

import ast
from contextlib import redirect_stderr, redirect_stdout
import io
import itertools
import json
import os
import re
import unittest
from unittest.mock import Mock, patch

import run_tests as runner
import test_run_tests as collection_fixture


WORKFLOW = runner.REPOSITORY_ROOT / ".github/workflows/ios-cicd.yml"


def deployment_allowed(step_id, outputs, outcome, upstream=None, prior_success=True):
    # Read the actual step condition, including its folded continuation lines.
    block = next(block for block in WORKFLOW.read_text().split("      - name:")
                 if f"\n        id: {step_id}\n" in block)
    lines = block.splitlines()
    index = next(i for i, line in enumerate(lines) if line.startswith("        if: "))
    expression = lines[index].removeprefix("        if: ")
    if expression == ">-":
        continuation = itertools.takewhile(lambda line: line.startswith("          "), lines[index + 1:])
        expression = " ".join(line.strip() for line in continuation)
    context = {"steps.setup-tuist.outcome": "success", "steps.setup-ruby.outcome": "success",
               "steps.install-ios-signing-assets.outcome": "success", "steps.test-gate.outcome": outcome,
               "steps.test-gate.outputs.execution_mode": outputs.get("execution_mode", ""),
               "steps.test-gate.outputs.decision": outputs.get("decision", ""), **(upstream or {})}
    expression = re.sub(r"steps\.[a-z-]+\.(?:outcome|outputs\.[a-z_]+)",
                        lambda match: repr(context[match[0]]), expression)
    tree = ast.parse(expression.replace("&&", " and ").replace("||", " or "), mode="eval")

    def evaluate(node):
        if isinstance(node, ast.Expression):
            return evaluate(node.body)
        if isinstance(node, ast.Constant) and isinstance(node.value, str):
            return node.value
        if isinstance(node, ast.BoolOp) and isinstance(node.op, (ast.And, ast.Or)):
            values = [evaluate(value) for value in node.values]
            return all(values) if isinstance(node.op, ast.And) else any(values)
        if isinstance(node, ast.Compare) and len(node.ops) == 1 and isinstance(node.ops[0], ast.Eq):
            return evaluate(node.left) == evaluate(node.comparators[0])
        raise AssertionError(f"Unsupported workflow condition: {ast.dump(node)}")

    # GitHub also applies success() when an if condition has no status function.
    return prior_success and evaluate(tree)


class CIScenarioTests(unittest.TestCase):
    def invoke(self, kind="DEV", target=None, fault=None, mode=None):
        fixture = collection_fixture.CollectionTests()
        fixture.setUp()
        self.addCleanup(fixture.doCleanups)
        config = json.loads(fixture.config_path.read_text())
        names = [m["name"] for m in fixture.selected]
        for module in config["modules"]:
            module["enabled"] = module["name"] in names
            module["minimumCoverage"] = 70
            manifest = fixture.root / module["projectPath"] / "Project.swift"
            manifest.parent.mkdir(parents=True, exist_ok=True)
            manifest.touch()
        selected = [m for m in config["modules"] if m["enabled"]]
        if fault == "global_off":
            config["enabled"] = False
        elif fault == "target_off":
            next(m for m in selected if m["name"] == "Util")["enabled"] = False
        elif fault == "empty_scope":
            for module in selected:
                module["enabled"] = False
        elif fault in ("test_failure", "non_target_failure"):
            fixture.fail_tests.add(names[0])
        elif fault == "target_test_failure":
            fixture.fail_tests.add("Util")
        elif fault == "coverage_failure":
            selected[0]["minimumCoverage"] = 75.001
        elif fault == "target_coverage_failure":
            next(m for m in selected if m["name"] == "Util")["minimumCoverage"] = 75.001
        elif fault == "equal_coverage":
            for module in selected:
                module["minimumCoverage"] = 75
        elif fault == "missing_threshold":
            selected[0].pop("minimumCoverage")
        elif fault == "non_target_threshold":
            selected[0]["minimumCoverage"] = "unconfirmed"
        elif fault == "missing_result":
            fixture.missing_results.add(names[0])
        elif fault == "bad_extraction":
            fixture.bad_extraction.add(names[0])
        elif fault == "build_failure":
            fixture.fail_build = True
        elif fault == "interrupted":
            fixture.interrupt_module = names[0]
        elif fault == "zero_tests":
            fixture.summary_overrides = {"totalTestCount": 0, "passedTests": 0}
        elif fault == "skipped_test":
            fixture.summary_overrides = {"passedTests": 1, "skippedTests": 1}
        elif fault == "unregistered":
            project = fixture.root / "Projects/Feature/Unregistered"
            (project / "Tests").mkdir(parents=True)
            (project / "Project.swift").touch()
            (project / "Tests/Example.swift").write_text("func testExample() {}")
        fixture.config_path.write_text(json.dumps(config))
        scheme = {"DEV": "Mody-DEV", "PROD": "Mody", "DESIGN": "DesignSystemDemo"}.get(kind, target)
        output = fixture.root / "github-output"
        env = {"GITHUB_ACTIONS": "true", "GITHUB_OUTPUT": str(output),
               "CICD_DEPLOYMENT_KIND": kind, "CICD_DEMO_TARGET": target or "",
               "CICD_SCHEME": scheme}
        if fault == "metadata_missing":
            env.pop("CICD_DEPLOYMENT_KIND")
        elif fault == "metadata_mismatch":
            env["CICD_SCHEME"] = "OtherDemo"
        args = ["--config", str(fixture.config_path), "--results-dir", str(fixture.root / "results"),
                "--destination", fixture.args.destination]
        if mode:
            args.append(mode)
        coverage = {m["name"]: f"lib{m['name']}.a" for m in fixture.selected}
        load_configuration = runner.load_configuration
        select_scope = runner.select_scope
        with patch.dict(os.environ, env, clear=True), \
             patch.object(runner, "REPOSITORY_ROOT", fixture.root), \
             patch.object(runner, "load_configuration", side_effect=lambda path: load_configuration(path, fixture.root)), \
             patch.object(runner, "select_scope", side_effect=lambda config, kind, target: select_scope(config, kind, target, fixture.root)), \
             patch.object(runner, "verify_scheme", return_value=coverage), \
             patch.object(runner, "run_command", side_effect=fixture.fake_command), \
             redirect_stdout(io.StringIO()) as stdout, redirect_stderr(io.StringIO()) as stderr:
            status = runner.main(args)
        outputs = dict(line.split("=", 1) for line in output.read_text().splitlines()) if output.exists() else {}
        reports = list((fixture.root / "results").glob("*/summary.json"))
        report = json.loads(reports[0].read_text()) if reports else None
        commands = [command for command, _ in fixture.commands]
        return status, outputs, report, commands, stdout.getvalue(), stderr.getvalue()

    def test_cli_to_workflow_and_deployment_spy_scenarios(self):
        scenarios = [
            ("dev_pass", "DEV", None, None, None, 0, "passed", True),
            ("prod_pass", "PROD", None, None, None, 0, "passed", True),
            ("demo_pass", "DEMO", "UtilDemo", None, None, 0, "passed", True),
            ("demo_ignores_other_failure", "DEMO", "UtilDemo", "non_target_failure", None, 0, "passed", True),
            ("demo_ignores_other_threshold", "DEMO", "UtilDemo", "non_target_threshold", None, 0, "passed", True),
            ("demo_test_failure", "DEMO", "UtilDemo", "target_test_failure", None, 1, "failed", False),
            ("demo_coverage_failure", "DEMO", "UtilDemo", "target_coverage_failure", None, 1, "failed", False),
            ("dev_test_failure", "DEV", None, "test_failure", None, 1, "failed", False),
            ("prod_test_failure", "PROD", None, "test_failure", None, 1, "failed", False),
            ("coverage_failure", "DEV", None, "coverage_failure", None, 1, "failed", False),
            ("equal_threshold", "DEV", None, "equal_coverage", None, 0, "passed", True),
            ("dev_global_off", "DEV", None, "global_off", None, 0, "disabled", True),
            ("prod_global_off", "PROD", None, "global_off", None, 0, "disabled", True),
            ("demo_global_off", "DEMO", "UtilDemo", "global_off", None, 0, "disabled", True),
            ("design_global_off", "DESIGN", "DesignSystemDemo", "global_off", None, 0, "disabled", True),
            ("demo_target_off", "DEMO", "UtilDemo", "target_off", None, 0, "disabled", True),
            ("design_target_off", "DESIGN", "DesignSystemDemo", None, None, 0, "disabled", True),
            ("empty_scope", "DEV", None, "empty_scope", None, 2, "failed", False),
            ("unknown_demo", "DEMO", "UnknownDemo", None, None, 2, "failed", False),
            ("unknown_demo_global_off", "DEMO", "UnknownDemo", "global_off", None, 2, "failed", False),
            ("missing_threshold", "DEV", None, "missing_threshold", None, 2, "failed", False),
            ("missing_metadata", "DEV", None, "metadata_missing", None, 2, "failed", False),
            ("mismatched_metadata", "DEMO", "UtilDemo", "metadata_mismatch", None, 2, "failed", False),
            ("missing_result", "DEV", None, "missing_result", None, 1, "failed", False),
            ("extraction_failure", "DEV", None, "bad_extraction", None, 1, "failed", False),
            ("build_failure", "DEV", None, "build_failure", None, 1, "failed", False),
            ("interrupted", "DEV", None, "interrupted", None, 130, "failed", False),
            ("zero_tests", "DEV", None, "zero_tests", None, 1, "failed", False),
            ("skipped_test", "DEV", None, "skipped_test", None, 1, "failed", False),
            ("unregistered_full", "DEV", None, "unregistered", None, 2, "failed", False),
            ("unregistered_demo", "DEMO", "UtilDemo", "unregistered", None, 0, "passed", True),
            ("collection", "DEV", None, None, "--collect-only", 0, None, False),
            ("dry_run", "DEV", None, None, "--dry-run", 0, None, False),
        ]
        for name, kind, target, fault, mode, expected_status, decision, allowed in scenarios:
            with self.subTest(scenario=name):
                status, outputs, report, commands, stdout, stderr = self.invoke(kind, target, fault, mode)
                self.assertEqual(status, expected_status, stderr)
                self.assertEqual(outputs.get("decision"), decision)
                outcome = "success" if status == 0 else "cancelled" if status == 130 else "failure"
                for step_id in ("setup-ruby", "build-and-distribute-app"):
                    spy = Mock()
                    if deployment_allowed(step_id, outputs, outcome):
                        spy(kind, target)
                    self.assertEqual(spy.call_count, int(allowed), step_id)
                tested = [next(arg.split(":", 1)[1][:-5] for arg in c if arg.startswith("-only-testing:"))
                          for c in commands if c[:2] == ["xcodebuild", "test-without-building"]]
                if decision == "disabled" or expected_status == 2 or mode == "--dry-run":
                    self.assertEqual(commands, [])
                elif kind == "DEMO":
                    self.assertEqual(tested, ["Util"])
                    self.assertEqual({m["reason"] for m in report["modules"] if m["name"] != "Util"}, {"out_of_scope"})
                elif fault != "build_failure":
                    self.assertEqual(tested, ["CoreKeyChainStorage"] if fault == "interrupted" else
                                     ["CoreKeyChainStorage", "FirebaseService", "Util"])
                if report:
                    self.assertEqual(len([line for line in stdout.splitlines() if "module=" in line]), 25)
                    if fault == "global_off":
                        self.assertEqual({m["reason"] for m in report["modules"]}, {"global_disabled"})
                    if decision == "disabled":
                        self.assertEqual({m["tests"] for m in report["modules"]}, {"not_run"})
                print(f"scenario={name} exit={status} decision={outputs.get('decision', 'NO_OUTPUT')} deploy_spy={int(allowed)}")

    def test_actual_workflow_condition_matrix_and_upstream_failures(self):
        for step, outcome, mode, decision in itertools.product(
                ("setup-ruby", "build-and-distribute-app"),
                ("success", "failure", "cancelled", "skipped", ""),
                ("execute", "collection", "dry_run", ""),
                ("passed", "disabled", "failed", "not_evaluated", "")):
            with self.subTest(step=step, outcome=outcome, mode=mode, decision=decision):
                outputs = {"execution_mode": mode, "decision": decision}
                self.assertEqual(deployment_allowed(step, outputs, outcome),
                                 outcome == "success" and mode == "execute" and decision in ("passed", "disabled"))
        outputs = {"execution_mode": "execute", "decision": "passed"}
        for step in ("setup-ruby", "build-and-distribute-app"):
            self.assertFalse(deployment_allowed(step, outputs, "success", prior_success=False))
        for step, upstream in (("setup-ruby", "setup-tuist"), ("build-and-distribute-app", "setup-ruby"),
                               ("build-and-distribute-app", "install-ios-signing-assets")):
            self.assertFalse(deployment_allowed(step, outputs, "success", {f"steps.{upstream}.outcome": "failure"}))


if __name__ == "__main__":
    unittest.main()
