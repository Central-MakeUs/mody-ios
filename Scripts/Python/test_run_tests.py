"""Policy and collection regression checks; Xcode commands use a recording fake."""

from contextlib import redirect_stdout, redirect_stderr
from copy import deepcopy
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
from types import SimpleNamespace

import run_tests as runner


class ScopeTests(unittest.TestCase):
    def setUp(self):
        self.config = runner.load_configuration()
        # Example thresholds belong to fixtures, never to the shared policy.
        for module in self.config["modules"]:
            if module["enabled"]:
                module["minimumCoverage"] = 70

    def select(self, deployment="DEV", target=None, config=None):
        kind, demo = runner.resolve_deployment(deployment, target, {})
        return runner.select_scope(self.config if config is None else config, kind, demo)

    def write_config(self, directory, config):
        path = Path(directory) / "configuration.json"
        path.write_text(json.dumps(config), encoding="utf-8")
        return path

    def invoke(self, path, args, env=None):
        output = io.StringIO()
        with patch.dict(os.environ, env or {}, clear=True), redirect_stdout(output):
            status = runner.main(["--config", str(path), *args])
        return status, json.loads(output.getvalue())

    def test_dev_prod_select_all_17_in_config_order(self):
        expected = [m["name"] for m in self.config["modules"] if m["enabled"]]
        self.assertEqual(len(expected), 17)
        for kind in ("DEV", "PROD"):
            self.assertEqual([m["name"] for m in self.select(kind)[0]], expected)

    def test_demo_selects_only_feed(self):
        selected, results = self.select("DEMO", "FeedDemo")
        self.assertEqual([m["name"] for m in selected], ["Feed"])
        self.assertEqual({m["reason"] for m in results if m["name"] != "Feed"}, {"out_of_scope"})

    def test_disabled_scope_and_reason_precedence(self):
        self.config["enabled"] = False
        for kind, target in (("DEV", None), ("DEMO", "FeedDemo")):
            selected, results = self.select(kind, target)
            self.assertEqual(selected, [])
            self.assertEqual({m["reason"] for m in results}, {"global_disabled"})
        self.config["enabled"] = True
        next(m for m in self.config["modules"] if m["name"] == "Feed")["enabled"] = False
        selected, results = self.select("DEMO", "FeedDemo")
        self.assertEqual(selected, [])
        self.assertEqual(next(m["reason"] for m in results if m["name"] == "Feed"), "module_disabled")
        self.assertEqual(self.select("DESIGN")[0], [])

    def test_local_and_ci_scopes_match(self):
        for kind, target, scheme in (("DEV", None, "Mody-DEV"), ("PROD", None, "Mody"),
                                     ("DEMO", "FeedDemo", "FeedDemo"),
                                     ("DESIGN", "DesignSystemDemo", "DesignSystemDemo")):
            with self.subTest(kind=kind):
                env = {"CICD_DEPLOYMENT_KIND": kind, "CICD_DEMO_TARGET": target or "",
                       "CICD_SCHEME": scheme}
                resolved = runner.resolve_deployment(environ=env)
                self.assertEqual(runner.select_scope(self.config, *resolved), self.select(kind, target))

    def test_unknown_demo_fails_even_when_globally_disabled(self):
        for enabled in (True, False):
            self.config["enabled"] = enabled
            with self.assertRaises(runner.ConfigurationError):
                self.select("DEMO", "UnknownDemo")

    def test_bad_metadata_never_falls_back_to_full_scope(self):
        invalid = [({}, None, None), ({"GITHUB_ACTIONS": "true"}, "DEV", None),
                   ({"CICD_SCHEME": "FeedDemo"}, "DEV", None),
                   ({"CICD_DEPLOYMENT_KIND": "OTHER"}, "DEV", None)]
        for kind, target, scheme in (("DEMO", "", "FeedDemo"), ("DEV", "FeedDemo", "Mody-DEV"),
                                     ("PROD", "", "Mody-DEV"), ("DESIGN", "", "DesignSystemDemo"),
                                     ("DEMO", "FeedDemo", "MyPageDemo")):
            invalid.append(({"CICD_DEPLOYMENT_KIND": kind, "CICD_DEMO_TARGET": target,
                             "CICD_SCHEME": scheme}, None, None))
        for env, kind, target in invalid:
            with self.subTest(env=env), self.assertRaises(runner.ConfigurationError):
                runner.resolve_deployment(kind, target, env)
        env = {"CICD_DEPLOYMENT_KIND": "DEMO", "CICD_DEMO_TARGET": "FeedDemo", "CICD_SCHEME": "FeedDemo"}
        for kind, target in (("DEV", None), ("DEMO", "MyPageDemo")):
            with self.assertRaises(runner.ConfigurationError):
                runner.resolve_deployment(kind, target, env)
        for kind, target in (("DEMO", None), ("DEMO", "Feed"), ("DEMO", "DesignSystemDemo"),
                             ("DESIGN", "FeedDemo"), ("DEV", "FeedDemo")):
            with self.assertRaises(runner.ConfigurationError):
                runner.resolve_deployment(kind, target, {})

    def test_configuration_structure_validation(self):
        invalid = [[], {"enabled": 1, "modules": []}, {"enabled": True, "modules": {}},
                   {"enabled": True, "modules": [None]}]
        for field, value in (("name", "../Feed"), ("enabled", 1), ("projectPath", None),
                             ("projectPath", "/tmp/Feed"), ("projectPath", "Projects/Feature/../Feed"),
                             ("projectPath", "Projects/Feature/Feed/"),
                             ("projectPath", "Projects/Feature/Unknown")):
            config = deepcopy(self.config)
            config["modules"][0][field] = value
            invalid.append(config)
        duplicate = deepcopy(self.config)
        duplicate["modules"].append(duplicate["modules"][0])
        invalid.append(duplicate)
        with tempfile.TemporaryDirectory() as directory:
            for config in invalid:
                with self.subTest(config=config), self.assertRaises(runner.ConfigurationError):
                    runner.load_configuration(self.write_config(directory, config))
            path = self.write_config(directory, self.config)
            for text in ('{"enabled":true,"enabled":false,"modules":[]}',
                         '{"enabled":true,"modules":[],"value":NaN}', '{'):
                path.write_text(text)
                with self.assertRaises(ValueError):
                    runner.load_configuration(path)

    def test_threshold_boundaries_and_missing_values(self):
        for value in (0, 69.999, 70, 100):
            self.assertEqual(runner.threshold_errors([{"name": "Feed", "minimumCoverage": value}]), [])
        for value in (None, True, "70", -0.1, 100.1, float("nan"), float("inf"), 10**1000):
            with self.subTest(value=value):
                self.assertTrue(runner.threshold_errors([{"name": "Feed", "minimumCoverage": value}]))
        self.assertTrue(runner.threshold_errors([{"name": "Feed"}]))

    def test_only_selected_thresholds_are_required(self):
        for module in self.config["modules"]:
            if module["name"] != "Feed":
                module["minimumCoverage"] = "unconfirmed"
        self.assertEqual(runner.threshold_errors(self.select("DEMO", "FeedDemo")[0]), [])
        self.assertTrue(runner.threshold_errors(self.select()[0]))
        with tempfile.TemporaryDirectory() as directory:
            self.config["modules"][0]["minimumCoverage"] = float("inf")
            path = self.write_config(directory, self.config)
            path.write_text(path.read_text().replace("Infinity", "1e309"))
            status, report = self.invoke(path, ["--deployment", "DEMO", "--demo-target", "FeedDemo", "--dry-run"])
            self.assertEqual(status, 0)
            self.assertEqual(report["errors"], [])
        self.config["enabled"] = False
        self.assertEqual(runner.threshold_errors(self.select()[0]), [])

    def test_zero_active_and_unregistered_tests_fail_for_full_scope_only(self):
        for module in self.config["modules"]:
            module["enabled"] = False
        with self.assertRaises(runner.ConfigurationError):
            self.select()
        self.assertEqual(self.select("DEMO", "FeedDemo")[0], [])
        self.config = runner.load_configuration()
        self.config["modules"] = [m for m in self.config["modules"] if m["name"] != "CoreAuth"]
        with self.assertRaisesRegex(runner.ConfigurationError, "CoreAuth"):
            self.select()
        self.assertEqual(self.select("DEMO", "FeedDemo")[0][0]["name"], "Feed")

    def test_cli_never_executes_or_writes_results(self):
        existing_runs = set((runner.REPOSITORY_ROOT / "Test/Result").glob("*"))
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_config(directory, self.config)
            output_path = Path(directory) / "github-output"
            env = {"GITHUB_OUTPUT": str(output_path)}
            with patch.object(subprocess, "run", side_effect=AssertionError("Execution forbidden")):
                status, report = self.invoke(path, ["--deployment", "DEMO", "--demo-target", "FeedDemo", "--dry-run"], env)
                self.assertEqual(status, 0)
                self.assertEqual(report["decision"], "not_evaluated")
                self.assertEqual(report["scheme"], "FeedTests")
                self.assertEqual(report["selected_modules"], ["Feed"])
                status, report = self.invoke(path, ["--deployment", "DEV"])
                self.assertEqual(status, 2)
                self.assertEqual(report["execution_mode"], "execute")
                self.assertEqual(report["decision"], "failed")
            self.assertFalse(output_path.exists())
            self.assertEqual(set((runner.REPOSITORY_ROOT / "Test/Result").glob("*")), existing_runs)

    def test_default_unconfirmed_policy_reports_scope_and_errors(self):
        config = runner.load_configuration()
        for module in config["modules"]:
            module.pop("minimumCoverage", None)
        with tempfile.TemporaryDirectory() as directory:
            status, report = self.invoke(self.write_config(directory, config), ["--deployment", "DEV", "--dry-run"])
            self.assertEqual(status, 2)
            self.assertEqual(len(report["selected_modules"]), 17)
            self.assertEqual(len(report["errors"]), 17)
            self.assertEqual(report["decision"], "not_evaluated")

    def test_cli_configuration_failure_is_nonzero(self):
        with redirect_stderr(io.StringIO()):
            self.assertEqual(runner.main(["--config", "/nonexistent/config.json", "--dry-run"]), 2)

    def test_cli_resolves_configuration_outside_repository(self):
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(
                [sys.executable, str(runner.REPOSITORY_ROOT / "Scripts/Python/run_tests.py"),
                 "--config", "Test/Settings/TestConfiguration.json",
                 "--deployment", "DESIGN", "--dry-run"],
                cwd=directory, env={}, text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        report = json.loads(result.stdout)
        self.assertEqual(report["selected_modules"], [])
        self.assertEqual(report["decision"], "not_evaluated")


class CollectionTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        config = runner.load_configuration()
        names = ("CoreKeyChainStorage", "FirebaseService", "Util")
        self.selected = [m for m in config["modules"] if m["name"] in names]
        for module in self.selected:
            module["minimumCoverage"] = 70
            source = self.root / module["projectPath"] / "Sources/Implementation.swift"
            source.parent.mkdir(parents=True)
            source.write_text("// fixture source")
        self.config_path = self.root / "config.json"
        self.config_path.write_text(json.dumps(config))
        self.args = SimpleNamespace(config=self.config_path, results_dir=self.root / "results",
                                    derived_data=None, destination="platform=iOS Simulator,id=fixture",
                                    command_timeout=1)
        self.report = {"execution_mode": "collection", "decision": "not_evaluated",
                       "selected_modules": [m["name"] for m in self.selected],
                       "demo_target": None, "scheme": "ModyAllTests",
                       "modules": [{**m, "reason": "selected"} for m in self.selected], "errors": []}
        self.commands = []
        self.fail_tests = set()
        self.missing_results = set()
        self.bad_extraction = set()
        self.fail_build = False
        self.interrupt_module = None
        self.summary_overrides = {}

    def fake_command(self, command, log_path, timeout, env=None):
        self.commands.append((command, env))
        log_path.write_text("tool output")
        code = 0
        if command[:2] == ["xcodebuild", "build-for-testing"] and self.fail_build:
            code = 65
        if command[:2] == ["xcodebuild", "test-without-building"]:
            name = next(arg.split(":", 1)[1][:-5] for arg in command if arg.startswith("-only-testing:"))
            if name == self.interrupt_module:
                raise KeyboardInterrupt()
            if name not in self.missing_results:
                Path(command[command.index("-resultBundlePath") + 1]).mkdir()
            code = 65 if name in self.fail_tests else 0
        if command[:2] == ["xcrun", "xcresulttool"]:
            bundle = Path(command[command.index("--path") + 1])
            name = bundle.stem
            if command[4] == "summary":
                failed = int(name in self.fail_tests)
                data = {"result": "Failed" if failed else "Passed", "totalTestCount": 2,
                        "passedTests": 2 - failed, "failedTests": failed, "skippedTests": 0,
                        "expectedFailures": 0, "testFailures": []}
                data.update(self.summary_overrides)
            else:
                data = {"testNodes": [{"nodeType": "Unit test bundle", "name": name + "Tests",
                                       "children": [{"nodeType": "Test Case", "name": "example", "result": "Passed"}]}]}
            log_path.write_text(json.dumps(data))
        if command[:2] == ["xcrun", "xccov"]:
            name = Path(command[-1]).stem
            module = next(m for m in self.selected if m["name"] == name)
            source = self.root / module["projectPath"] / "Sources/Implementation.swift"
            log_path.write_text(json.dumps({"targets": [{"name": f"lib{name}.a", "coveredLines": 3, "executableLines": 4,
                               "files": [{"path": str(source), "coveredLines": 3, "executableLines": 4}]}]}))
            if name in self.bad_extraction:
                code = 1
        return {"command": command, "log": str(log_path), "exit_code": code, "duration_seconds": 0.01}

    def execute(self):
        coverage = {m["name"]: f"lib{m['name']}.a" for m in self.selected}
        with patch.object(runner, "REPOSITORY_ROOT", self.root), \
             patch.object(runner, "verify_scheme", return_value=coverage), \
             patch.object(runner, "run_command", side_effect=self.fake_command):
            return runner.execute_collection(self.args, self.report, self.selected)

    def test_full_collection_builds_once_and_isolates_each_module_result(self):
        self.assertEqual(self.execute(), 0)
        commands = [c for c, env in self.commands]
        self.assertEqual(sum(c[:2] == ["xcodebuild", "build-for-testing"] for c in commands), 1)
        tests = [c for c in commands if c[:2] == ["xcodebuild", "test-without-building"]]
        self.assertEqual(len(tests), 3)
        self.assertEqual([next(v for v in c if v.startswith("-only-testing:")) for c in tests],
                         [f"-only-testing:{m['name']}Tests" for m in self.selected])
        for c in tests:
            self.assertIn("CODE_SIGNING_ALLOWED=YES", c)
            self.assertIn("CODE_SIGN_IDENTITY=-", c)
            self.assertEqual(c[c.index("-parallel-testing-enabled") + 1], "NO")
            self.assertEqual(c[c.index("-configuration") + 1], "DEV")
        generate = next(env for c, env in self.commands if c[:2] == ["tuist", "generate"])
        self.assertEqual(generate["TUIST_CONFIG_CACHE_MANIFESTS"], "false")
        self.assertEqual(self.report["decision"], "not_evaluated")
        self.assertTrue(all(m["tests"] == "passed" for m in self.report["modules"]))
        run = Path(self.report["result_directory"])
        self.assertTrue((run / "summary.md").is_file())
        persisted = json.loads((run / "summary.json").read_text())
        self.assertEqual(persisted, self.report)
        events = [json.loads(line) for line in (run / "results.jsonl").read_text().splitlines()]
        self.assertEqual(events[-1]["event"], "run_finished")
        self.assertEqual(sum(e["event"] == "module_finished" for e in events), 3)

    def test_demo_collection_builds_only_its_scheme(self):
        self.selected = self.selected[-1:]
        self.report.update(demo_target="UtilDemo", scheme="UtilTests", selected_modules=["Util"],
                           modules=[self.report["modules"][-1]])
        self.assertEqual(self.execute(), 0)
        for command, env in self.commands:
            if command[0] == "xcodebuild" and "-scheme" in command:
                self.assertEqual(command[command.index("-scheme") + 1], "UtilTests")

    def test_failed_tests_do_not_stop_later_modules(self):
        self.fail_tests.add(self.selected[0]["name"])
        self.assertEqual(self.execute(), 1)
        self.assertEqual(self.report["modules"][0]["tests"], "failed")
        self.assertEqual(self.report["modules"][-1]["reason"], "collected")
        self.assertEqual(self.report["decision"], "not_evaluated")

    def test_build_failure_marks_all_selected_as_not_completed(self):
        self.fail_build = True
        self.assertEqual(self.execute(), 1)
        self.assertTrue(all(m["reason"] == "build_failed" and m["tests"] == "not_run"
                            for m in self.report["modules"]))
        self.assertFalse(any(c[:2] == ["xcodebuild", "test-without-building"] for c, env in self.commands))

    def test_missing_bundle_and_extraction_errors_are_preserved(self):
        self.missing_results.add(self.selected[0]["name"])
        self.bad_extraction.add(self.selected[1]["name"])
        self.assertEqual(self.execute(), 1)
        self.assertEqual([m["collection_status"] for m in self.report["modules"]], ["error", "error", "completed"])
        self.assertTrue(self.report["modules"][1]["test_summary_path"].endswith(".json"))

    def test_interrupt_preserves_finished_module_and_marks_remaining(self):
        self.interrupt_module = self.selected[1]["name"]
        self.assertEqual(self.execute(), 130)
        self.assertEqual(self.report["collection_status"], "interrupted")
        self.assertEqual([m["reason"] for m in self.report["modules"]], ["collected", "interrupted", "interrupted"])
        saved = json.loads((Path(self.report["result_directory"]) / "summary.json").read_text())
        self.assertEqual(saved["collection_status"], "interrupted")

    def test_disabled_collection_never_invokes_external_commands(self):
        self.selected = []
        self.report.update(selected_modules=[], modules=[{"name": "Feed", "reason": "global_disabled"}])
        self.assertEqual(self.execute(), 0)
        self.assertFalse(self.commands)
        self.assertEqual(self.report["collection_status"], "disabled")
        self.assertEqual(self.report["decision"], "not_evaluated")

    def test_each_execution_creates_a_new_run_directory(self):
        self.execute()
        first = self.report["result_directory"]
        self.execute()
        self.assertNotEqual(self.report["result_directory"], first)

    def test_execute_requires_both_tests_and_coverage_and_persists_decision(self):
        self.report["execution_mode"] = "execute"
        self.report["modules"][0]["minimumCoverage"] = 75.001
        self.assertEqual(self.execute(), 1)
        self.assertEqual(self.report["collection_status"], "completed")
        self.assertEqual(self.report["decision"], "failed")
        self.assertEqual(self.report["modules"][0]["reason"], "coverage_below_threshold")
        self.assertEqual(self.report["modules"][-1]["gate"], "passed")
        run = Path(self.report["result_directory"])
        self.assertIn("deployment decision: failed", (run / "summary.md").read_text())
        events = [json.loads(line) for line in (run / "results.jsonl").read_text().splitlines()]
        self.assertEqual(events[-1]["decision"], "failed")
        self.assertEqual(len([e for e in events if e["event"] == "module_evaluated"]), 3)

    def test_execute_passes_on_equal_threshold(self):
        self.report["execution_mode"] = "execute"
        for module in self.report["modules"]:
            module["minimumCoverage"] = 75
        self.assertEqual(self.execute(), 0)
        self.assertEqual(self.report["decision"], "passed")

    def test_zero_skipped_expected_or_inconsistent_counts_cannot_pass(self):
        self.report["execution_mode"] = "execute"
        for counts in ({"totalTestCount": 0, "passedTests": 0},
                       {"passedTests": 1, "skippedTests": 1},
                       {"passedTests": 1, "expectedFailures": 1},
                       {"totalTestCount": 3}):
            self.summary_overrides = counts
            self.assertEqual(self.execute(), 1)
            self.assertEqual(self.report["decision"], "failed")

    def test_execute_build_failure_and_interrupt_cannot_authorize_deployment(self):
        self.report["execution_mode"] = "execute"
        self.fail_build = True
        self.assertEqual(self.execute(), 1)
        self.assertEqual(self.report["decision"], "failed")
        self.fail_build = False
        self.interrupt_module = self.selected[0]["name"]
        self.assertEqual(self.execute(), 130)
        self.assertEqual(self.report["decision"], "failed")

    def test_actions_outputs_follow_actual_gate_and_preserve_interrupted_results(self):
        self.report["execution_mode"] = "execute"
        output = self.root / "github-output"
        with patch.dict(os.environ, {"GITHUB_OUTPUT": str(output)}, clear=True):
            self.assertEqual(self.execute(), 0)
            values = dict(line.split("=", 1) for line in output.read_text().splitlines())
            self.assertEqual(values["decision"], "passed")
            self.assertEqual(values["execution_mode"], "execute")
            self.assertEqual(values["result_directory"], self.report["result_directory"])
            self.interrupt_module = self.selected[0]["name"]
            self.assertEqual(self.execute(), 130)
            values = dict(line.split("=", 1) for line in output.read_text().splitlines())
            self.assertEqual(values["decision"], "failed")
            self.assertTrue((Path(values["result_directory"]) / "summary.json").is_file())

    def test_collection_execution_never_writes_actions_outputs(self):
        output = self.root / "github-output"
        with patch.dict(os.environ, {"GITHUB_OUTPUT": str(output)}, clear=True):
            self.assertEqual(self.execute(), 0)
        self.assertFalse(output.exists())

    def test_stdout_jsonl_and_summary_keep_test_success_separate_from_coverage_failure(self):
        self.report["execution_mode"] = "execute"
        self.report["modules"][0]["minimumCoverage"] = 80
        with redirect_stdout(io.StringIO()) as output:
            self.assertEqual(self.execute(), 1)
        run = Path(self.report["result_directory"])
        events = [json.loads(line) for line in (run / "results.jsonl").read_text().splitlines()]
        evaluated = [e for e in events if e["event"] == "module_evaluated"]
        self.assertEqual(len(evaluated), 3)
        for event in evaluated:
            self.assertIn(event["message"], output.getvalue())
            self.assertEqual(event["configuration_sha256"], self.report["configuration_sha256"])
        self.assertIn('tests=passed', evaluated[0]["message"])
        self.assertIn('coverage="75.0000 < 80 (3/4)"', evaluated[0]["message"])
        self.assertIn('reason=coverage_below_threshold', evaluated[0]["message"])
        summary = (run / "summary.md").read_text()
        self.assertIn("3/4", summary)
        self.assertIn("2 / 0 / 0 / 0", summary)
        self.assertIn(self.report["modules"][0]["xcresult"], summary)

    def test_generated_scheme_must_match_scope_and_dev_coverage(self):
        path = self.root / "Mody.xcworkspace/xcshareddata/xcschemes/ModyAllTests.xcscheme"
        path.parent.mkdir(parents=True)
        xml = """<Scheme><TestAction buildConfiguration="DEV" codeCoverageEnabled="YES"
            onlyGenerateCoverageForSpecifiedTargets="YES"><Testables>
            <TestableReference skipped="NO"><BuildableReference BlueprintName="UtilTests"/></TestableReference>
            </Testables><CodeCoverageTargets><BuildableReference BlueprintName="Util" BuildableName="libUtil.a"/>
            </CodeCoverageTargets></TestAction></Scheme>"""
        self.selected = [self.selected[-1]]
        path.write_text(xml)
        with patch.object(runner, "REPOSITORY_ROOT", self.root):
            self.assertEqual(runner.verify_scheme(self.report, self.selected), {"Util": "libUtil.a"})
            for altered in (xml.replace("UtilTests", "FeedTests"), xml.replace('skipped="NO"', 'skipped="YES"'),
                            xml.replace('buildConfiguration="DEV"', 'buildConfiguration="PROD"'),
                            xml.replace('BlueprintName="Util"', 'BlueprintName="Feed"'),
                            xml.replace('onlyGenerateCoverageForSpecifiedTargets="YES"', 'onlyGenerateCoverageForSpecifiedTargets="NO"')):
                path.write_text(altered)
                with self.assertRaises(ValueError):
                    runner.verify_scheme(self.report, self.selected)

    def test_malformed_counts_unexpected_bundle_and_ambiguous_coverage_are_errors(self):
        module = self.selected[-1]
        run_dir = self.root / "invalid-results"
        run_dir.mkdir()
        (run_dir / "Util.xcresult").mkdir()
        good_summary = {"result": "Passed", "totalTestCount": 2, "passedTests": 2,
                        "failedTests": 0, "skippedTests": 0, "expectedFailures": 0}
        good_tree = {"testNodes": [{"nodeType": "Unit test bundle", "name": "UtilTests"}]}
        good_target = {"name": "libUtil.a", "coveredLines": 2, "executableLines": 3}
        scenarios = [(dict(good_summary, totalTestCount=True), good_tree, [good_target]),
                     (good_summary, {"testNodes": [{"nodeType": "Unit test bundle", "name": "FeedTests"}]}, [good_target]),
                     (good_summary, good_tree, [good_target, good_target]),
                     (good_summary, good_tree, [dict(good_target, executableLines=0)])]
        for summary, tree, targets in scenarios:
            def invoke(command, path):
                if command[1] == "xccov":
                    value = {"targets": targets}
                else:
                    value = summary if command[4] == "summary" else tree
                path.write_text(json.dumps(value))
                return {"exit_code": 0}
            result = {"exit_code": 0, "tests": "error"}
            runner.collect_results(module, result, run_dir, invoke, "libUtil.a")
            self.assertEqual(result["collection_status"], "error")
            self.assertTrue(result["errors"])

    def test_subprocess_timeout_stops_process_and_keeps_log(self):
        result = runner.run_command([sys.executable, "-c", "import time; time.sleep(5)"],
                                    self.root / "timeout.log", 0.05)
        self.assertEqual(result["exit_code"], 124)
        self.assertLess(result["duration_seconds"], 2)

    def test_collection_dry_run_needs_no_threshold_and_has_no_side_effects(self):
        with patch.dict(os.environ, {}, clear=True), patch.object(runner, "run_command", side_effect=AssertionError), redirect_stdout(io.StringIO()) as output:
            status = runner.main(["--deployment", "DEMO", "--demo-target", "FeedDemo", "--collect-only", "--dry-run"])
        self.assertEqual(status, 0)
        report = json.loads(output.getvalue())
        self.assertEqual(report["execution_mode"], "dry_run")
        self.assertEqual(report["decision"], "not_evaluated")
        self.assertEqual(len(report["command_plan"]), 3)
        self.assertIn("FeedTests", report["command_plan"][1])

    def test_invalid_destination_or_timeout_rejects_collection_before_writes(self):
        for extra in ([], ["--destination", "platform=iOS,id=fixture"], ["--command-timeout", "nan"]):
            with patch.dict(os.environ, {}, clear=True), patch.object(runner, "execute_collection", side_effect=AssertionError), redirect_stdout(io.StringIO()) as output:
                status = runner.main(["--deployment", "DEV", "--collect-only", *extra])
            self.assertEqual(status, 2)
            self.assertTrue(json.loads(output.getvalue())["errors"])


class GateTests(unittest.TestCase):
    def setUp(self):
        self.module = {"name": "Feed", "reason": "collected", "enabled": True,
                       "minimumCoverage": 70, "tests": "passed", "collection_status": "completed",
                       "finished_at": "2026-10-15T00:00:00+00:00",
                       "coverage": {"covered_lines": 70000, "executable_lines": 100000}}
        self.report = {"execution_mode": "execute", "selected_modules": ["Feed"],
                       "collection_status": "completed", "errors": [], "modules": [self.module]}

    def test_exact_threshold_just_below_equal_and_above(self):
        for covered, expected in ((69999, "failed"), (70000, "passed"), (70001, "passed")):
            self.module["coverage"]["covered_lines"] = covered
            runner.evaluate_gate(self.report)
            self.assertEqual(self.module["coverage_result"], expected)
            self.assertEqual(self.module["gate"], expected)
            self.assertEqual(self.report["decision"], expected)
        # A rounded percentage would conceal a failure for this decimal threshold.
        self.module.update(minimumCoverage=33.333333333333336,
                           coverage={"covered_lines": 1, "executable_lines": 3})
        runner.evaluate_gate(self.report)
        self.assertEqual(self.report["decision"], "failed")
        for threshold in (0, 100):
            self.module.update(minimumCoverage=threshold,
                               coverage={"covered_lines": threshold, "executable_lines": 100})
            runner.evaluate_gate(self.report)
            self.assertEqual(self.report["decision"], "passed")

    def test_test_and_coverage_failures_remain_independent(self):
        self.module["tests"] = "failed"
        runner.evaluate_gate(self.report)
        self.assertEqual(self.module["coverage_result"], "passed")
        self.assertEqual(self.module["reason"], "test_failed")
        self.assertEqual(self.report["decision"], "failed")
        self.module["coverage"]["covered_lines"] = 69999
        runner.evaluate_gate(self.report)
        self.assertEqual(self.module["coverage_result"], "failed")
        self.assertEqual(self.module["reason"], "test_failed")

    def test_missing_unfinished_duplicate_or_interrupted_results_never_pass(self):
        for status, reason in (("error", "build_failed"), ("error", "result_invalid"),
                               ("running", "tests_not_completed")):
            self.module.update(collection_status=status, reason=reason)
            runner.evaluate_gate(self.report)
            self.assertEqual(self.report["decision"], "failed")
            self.assertEqual(self.module["reason"], reason)
        self.module.update(collection_status="completed", finished_at=None)
        runner.evaluate_gate(self.report)
        self.assertEqual(self.report["decision"], "failed")
        self.module["finished_at"] = "finished"
        self.report["collection_status"] = "interrupted"
        runner.evaluate_gate(self.report)
        self.assertEqual(self.report["decision"], "failed")
        self.report["collection_status"] = "completed"
        for modules in ([], [self.module, deepcopy(self.module)]):
            self.report["modules"] = modules
            runner.evaluate_gate(self.report)
            self.assertEqual(self.report["decision"], "failed")

    def test_full_scope_failure_but_demo_ignores_non_target(self):
        other = {"name": "Challenge", "reason": "out_of_scope", "tests": "not_run",
                 "collection_status": "not_run", "enabled": True}
        self.report["modules"].append(other)
        runner.evaluate_gate(self.report)
        self.assertEqual(self.report["decision"], "passed")
        self.assertEqual(other["gate"], "passed")
        self.assertEqual(other["tests"], "not_run")
        self.report["selected_modules"].append("Challenge")
        runner.evaluate_gate(self.report)
        self.assertEqual(self.report["decision"], "failed")

    def test_explicit_global_or_target_disabled_is_distinct_from_passed(self):
        self.report.update(selected_modules=[], collection_status="disabled")
        self.module.update(tests="not_run", collection_status="not_run")
        for reason in ("global_disabled", "module_disabled"):
            self.module["reason"] = reason
            runner.evaluate_gate(self.report)
            self.assertEqual(self.report["decision"], "disabled")
            self.assertEqual(self.module["tests"], "not_run")
            self.assertEqual(self.module["gate"], "passed")
        self.module["reason"] = "tests_not_completed"
        runner.evaluate_gate(self.report)
        self.assertEqual(self.report["decision"], "failed")

    def test_collection_and_dry_run_are_never_deployment_decisions(self):
        for mode in ("collection", "dry_run"):
            self.report["execution_mode"] = mode
            runner.evaluate_gate(self.report)
            self.assertEqual(self.report["decision"], "not_evaluated")
            self.assertEqual(self.module["gate"], "not_evaluated")


class CoverageSourceTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.module = {"name": "Feed", "projectPath": "Projects/Feature/Feed"}
        self.source = self.root / self.module["projectPath"] / "Sources/File.swift"
        self.source.parent.mkdir(parents=True)
        self.source.touch()
        self.target = {"name": "libFeed.a", "coveredLines": 7, "executableLines": 10,
                       "files": [{"path": str(self.source), "coveredLines": 7, "executableLines": 10}]}

    def validate(self, targets=None):
        with patch.object(runner, "REPOSITORY_ROOT", self.root):
            return runner.validated_coverage(self.module, [self.target] if targets is None else targets, "libFeed.a")

    def test_valid_implementation_paths_and_line_totals(self):
        result = self.validate()
        self.assertEqual(result["file_count"], 1)
        self.assertEqual(result["covered_lines"], 7)
        self.assertEqual(result["line_percent"], 70)

    def test_testing_demo_host_dependency_and_missing_sources_are_rejected(self):
        for directory in ("Tests", "Testing", "Demo", "TestHost"):
            file = self.root / self.module["projectPath"] / directory / "File.swift"
            file.parent.mkdir()
            file.touch()
            self.target["files"][0]["path"] = str(file)
            with self.assertRaisesRegex(ValueError, "Unexpected"):
                self.validate()
        for value in (str(self.root / "Projects/Core/Other/Sources/File.swift"),
                      str(self.source.with_name("Missing.swift")), "Sources/File.swift", None):
            self.target["files"][0]["path"] = value
            with self.assertRaises(ValueError):
                self.validate()

    def test_duplicates_missing_files_or_mismatched_totals_are_rejected(self):
        for files in ([], None, self.target["files"] * 2,
                      [dict(self.target["files"][0], coveredLines=6)],
                      [dict(self.target["files"][0], coveredLines=True)]):
            self.target["files"] = files
            with self.assertRaises(ValueError):
                self.validate()


class ActionsTests(unittest.TestCase):
    def test_auto_destination_chooses_available_iphone_in_newest_ios_runtime(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "devices.json"
            old = "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
            newest = "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB"
            phone = {"name": "iPhone 17 Pro", "isAvailable": True, "state": "Shutdown", "udid": newest}
            path.write_text(json.dumps({"devices": {
                "com.apple.CoreSimulator.SimRuntime.iOS-18-5": [dict(phone, udid=old, state="Booted")],
                "com.apple.CoreSimulator.SimRuntime.iOS-26-2": [phone, dict(phone, name="iPad Pro", udid=old)],
                "com.apple.CoreSimulator.SimRuntime.tvOS-26-2": [dict(phone, udid=old)],
            }}))
            self.assertEqual(runner.simulator_destination(path), "platform=iOS Simulator,id=" + newest)
            for devices in ({}, {"com.apple.CoreSimulator.SimRuntime.iOS-26-2": [dict(phone, isAvailable=False)]}):
                path.write_text(json.dumps({"devices": devices}))
                with self.assertRaises(ValueError):
                    runner.simulator_destination(path)

    def test_configuration_error_cannot_leave_a_passed_actions_decision(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "outputs"
            with patch.dict(os.environ, {"GITHUB_OUTPUT": str(output)}, clear=True), redirect_stderr(io.StringIO()):
                self.assertEqual(runner.main(["--config", "/missing-config.json", "--deployment", "DEV"]), 2)
            values = dict(line.split("=", 1) for line in output.read_text().splitlines())
            self.assertEqual(values, {"execution_mode": "execute", "decision": "failed"})

    def test_disabled_cli_publishes_explicit_disabled_and_preserves_skip_reasons(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "outputs"
            env = {"GITHUB_OUTPUT": str(output), "GITHUB_ACTIONS": "true",
                   "CICD_DEPLOYMENT_KIND": "DESIGN", "CICD_DEMO_TARGET": "DesignSystemDemo",
                   "CICD_SCHEME": "DesignSystemDemo"}
            with patch.dict(os.environ, env, clear=True), redirect_stdout(io.StringIO()) as stdout:
                self.assertEqual(runner.main(["--results-dir", directory]), 0)
            values = dict(line.split("=", 1) for line in output.read_text().splitlines())
            self.assertEqual(values["decision"], "disabled")
            report = json.loads((Path(values["result_directory"]) / "summary.json").read_text())
            self.assertEqual(report["commands"], [])
            self.assertEqual(len([line for line in stdout.getvalue().splitlines() if "module=" in line]), 25)
            target = next(m for m in report["modules"] if m["name"] == "DesignSystem")
            self.assertEqual((target["tests"], target["gate"], target["reason"]),
                             ("not_run", "passed", "module_disabled"))


if __name__ == "__main__":
    unittest.main()
