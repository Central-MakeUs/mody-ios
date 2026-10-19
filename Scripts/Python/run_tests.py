#!/usr/bin/env python3
"""Run module tests and require their individual coverage thresholds.

Inspect with --dry-run. Execute with --destination 'platform=iOS Simulator,id=<UDID>'.
Use --collect-only to measure without a gate. This script never invokes deployment.
"""

import argparse
from datetime import datetime, timezone
from fractions import Fraction
import hashlib
import json
import math
import os
from pathlib import Path, PurePosixPath
import re
import signal
import subprocess
import time
from uuid import uuid4
import xml.etree.ElementTree as ET
import sys


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CONFIGURATION = REPOSITORY_ROOT / "Test/Settings/TestConfiguration.json"
DEPLOYMENTS = ("DEV", "PROD", "DEMO", "DESIGN")


class ConfigurationError(ValueError):
    """An invalid configuration or contradictory deployment metadata."""


def _unique_keys(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ConfigurationError(f"Duplicate JSON key: {key}")
        result[key] = value
    return result


def _invalid_constant(value):
    raise ConfigurationError(f"Invalid JSON number: {value}")


def load_configuration(path=DEFAULT_CONFIGURATION, root=REPOSITORY_ROOT):
    with Path(path).open(encoding="utf-8") as source:
        config = json.load(source, object_pairs_hook=_unique_keys,
                           parse_constant=_invalid_constant)
    if not isinstance(config, dict) or type(config.get("enabled")) is not bool:
        raise ConfigurationError("Configuration requires a boolean enabled")
    modules = config.get("modules")
    if not isinstance(modules, list):
        raise ConfigurationError("modules must be an array")
    names, paths = set(), set()
    for module in modules:
        if not isinstance(module, dict):
            raise ConfigurationError("Each module must be an object")
        name, path = module.get("name"), module.get("projectPath")
        if not isinstance(name, str) or not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", name):
            raise ConfigurationError(f"Invalid module name: {name!r}")
        if type(module.get("enabled")) is not bool:
            raise ConfigurationError(f"{name}: enabled must be boolean")
        if not isinstance(path, str) or not path:
            raise ConfigurationError(f"{name}: projectPath must be a relative path")
        relative = PurePosixPath(path)
        resolved = (root / path).resolve()
        if (relative.is_absolute() or ".." in relative.parts
                or path != relative.as_posix() or relative.parts[0] != "Projects"
                or relative.name != name or not resolved.is_relative_to(root.resolve())
                or not (resolved / "Project.swift").is_file()):
            raise ConfigurationError(f"{name}: invalid projectPath: {path}")
        if name in names or resolved in paths:
            raise ConfigurationError(f"Duplicate module name or projectPath: {name}")
        names.add(name)
        paths.add(resolved)
    return config


def resolve_deployment(deployment=None, demo_target=None, environ=None):
    env = os.environ if environ is None else environ
    kind, target, scheme = (env.get(key, "") for key in (
        "CICD_DEPLOYMENT_KIND", "CICD_DEMO_TARGET", "CICD_SCHEME"))
    if env.get("GITHUB_ACTIONS") == "true" or any((kind, target, scheme)):
        if kind not in DEPLOYMENTS or not scheme:
            raise ConfigurationError("CI metadata requires a valid deployment kind and scheme")
        if deployment is not None and deployment != kind:
            raise ConfigurationError("--deployment contradicts CICD_DEPLOYMENT_KIND")
        if demo_target is not None and demo_target != target:
            raise ConfigurationError("--demo-target contradicts CICD_DEMO_TARGET")
        deployment, demo_target = kind, target
    if deployment not in DEPLOYMENTS:
        raise ConfigurationError("Specify --deployment or complete CI metadata")
    if deployment in ("DEV", "PROD"):
        expected = "Mody-DEV" if deployment == "DEV" else "Mody"
        if demo_target or (scheme and scheme != expected):
            raise ConfigurationError(f"{deployment}: unexpected demo target or scheme")
        return deployment, None
    if deployment == "DESIGN":
        if kind and demo_target != "DesignSystemDemo":
            raise ConfigurationError("DESIGN CI metadata requires DesignSystemDemo")
        demo_target = demo_target or "DesignSystemDemo"
        if demo_target != "DesignSystemDemo":
            raise ConfigurationError("DESIGN requires DesignSystemDemo")
    if (not demo_target or not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*Demo", demo_target)
            or (scheme and scheme != demo_target)
            or (deployment == "DEMO" and demo_target == "DesignSystemDemo")):
        raise ConfigurationError("Invalid or contradictory Demo target/scheme")
    return deployment, demo_target


def select_scope(config, deployment, demo_target, root=REPOSITORY_ROOT):
    modules = config["modules"]
    target = demo_target[:-4] if demo_target else None
    if target is not None and target not in {module["name"] for module in modules}:
        raise ConfigurationError(f"Unregistered Demo module: {target}")
    selected = []
    results = []
    for module in modules:
        if not config["enabled"]:
            reason = "global_disabled"
        elif target is not None and module["name"] != target:
            reason = "out_of_scope"
        elif not module["enabled"]:
            reason = "module_disabled"
        else:
            reason = "selected"
            selected.append(module)
        result = {**module, "reason": reason}
        value = result.get("minimumCoverage")
        if isinstance(value, float) and not math.isfinite(value):
            result["minimumCoverage"] = str(value)
        results.append(result)
    if config["enabled"] and target is None:
        if not selected:
            raise ConfigurationError("Global testing is enabled but no modules are enabled")
        # A Tests target or an empty XCTestCase alone is not a test implementation.
        test_pattern = re.compile(r"\bfunc\s+test\w*\s*\(|@Test\b")
        registered = {module["projectPath"] for module in modules}
        for manifest in sorted((root / "Projects").rglob("Project.swift")):
            project = manifest.parent
            if project.relative_to(root).as_posix() in registered:
                continue
            if any(test_pattern.search(source.read_text(encoding="utf-8"))
                   for source in (project / "Tests").rglob("*.swift")):
                raise ConfigurationError(f"Test module is not registered: {project.name}")
    return selected, results


def threshold_errors(modules):
    errors = []
    for module in modules:
        value = module.get("minimumCoverage")
        try:
            valid = (type(value) in (int, float) and math.isfinite(value)
                     and 0 <= value <= 100)
        except OverflowError:
            valid = False
        if not valid:
            errors.append(f"{module['name']}: minimumCoverage must be a finite number in 0..100")
    return errors


def timestamp():
    return datetime.now(timezone.utc).isoformat()


def write_json(path, value):
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, indent=2, allow_nan=False) + "\n", encoding="utf-8")
    temporary.replace(path)


def publish_outputs(report):
    """Only real gate execution may expose deployment decisions to Actions."""
    output = os.environ.get("GITHUB_OUTPUT")
    if report["execution_mode"] != "execute" or not output:
        return
    values = {key: report[key] for key in
              ("execution_mode", "decision", "run_id", "result_directory") if key in report}
    if any("\n" in str(value) or "\r" in str(value) for value in values.values()):
        raise ValueError("GitHub output values must occupy a single line")
    with Path(output).open("a", encoding="utf-8") as stream:
        stream.writelines(f"{key}={value}\n" for key, value in values.items())


def simulator_destination(devices_path):
    """Choose an available iPhone from the newest installed iOS runtime."""
    candidates = []
    for runtime, devices in json.loads(devices_path.read_text())["devices"].items():
        if ".iOS-" not in runtime:
            continue
        version = tuple(int(part) for part in runtime.split(".iOS-", 1)[1].split("-"))
        for device in devices:
            if (device.get("isAvailable") is True and device.get("name", "").startswith("iPhone")
                    and re.fullmatch(r"[A-Fa-f0-9-]{36}", device.get("udid", ""))):
                candidates.append((version, device.get("state") == "Booted", device["udid"]))
    if not candidates:
        raise ValueError("No available iPhone Simulator for an installed iOS runtime")
    return "platform=iOS Simulator,id=" + max(candidates)[2]


def coverage_expression(module):
    coverage = module.get("coverage")
    if not coverage:
        return "NOT_MEASURED"
    operator = {"passed": ">=", "failed": "<"}.get(module["coverage_result"], "vs")
    return (f"{coverage['line_percent']:.4f} {operator} {module.get('minimumCoverage', 'UNCONFIRMED')}"
            f" ({coverage['covered_lines']}/{coverage['executable_lines']})")


def module_message(module):
    counts = module.get("test_counts", {})
    return (f"module={module['name']} enabled={module.get('enabled')} gate={module['gate']} "
            f"tests={module['tests']} passed={counts.get('passedTests', 'NOT_RUN')} "
            f"failed={counts.get('failedTests', 'NOT_RUN')} skipped={counts.get('skippedTests', 'NOT_RUN')} "
            f"expected_failures={counts.get('expectedFailures', 'NOT_RUN')} "
            f"exit_code={module.get('exit_code', 'NOT_RUN')} seconds={module.get('duration_seconds', 'NOT_RUN')} "
            f"coverage=\"{coverage_expression(module)}\" coverage_result={module['coverage_result']} reason={module['reason']}")


def stop_process(process):
    try:
        os.killpg(process.pid, signal.SIGTERM)
        try:
            process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()
    except ProcessLookupError:
        process.wait()


def run_command(command, log_path, timeout, env=None):
    """Keep raw output, terminate the entire child group on timeout or cancellation."""
    started = time.monotonic()
    with log_path.open("w", encoding="utf-8") as log:
        process = subprocess.Popen(command, cwd=REPOSITORY_ROOT, env=env,
                                   stdout=log, stderr=subprocess.STDOUT,
                                   start_new_session=True)
        try:
            code = process.wait(timeout=timeout)
        except (subprocess.TimeoutExpired, KeyboardInterrupt) as error:
            stop_process(process)
            if isinstance(error, KeyboardInterrupt):
                raise
            code = 124
    return {"command": command, "log": str(log_path), "exit_code": code,
            "duration_seconds": time.monotonic() - started}


def xcode_command(action, scheme, destination, derived_data):
    return ["xcodebuild", action, "-workspace", str(REPOSITORY_ROOT / "Mody.xcworkspace"),
            "-scheme", scheme, "-configuration", "DEV", "-destination", destination,
            "-derivedDataPath", str(derived_data), "-enableCodeCoverage", "YES",
            "-parallel-testing-enabled", "NO", "-disableAutomaticPackageResolution",
            "CODE_SIGNING_ALLOWED=YES", "CODE_SIGN_IDENTITY=-"]


def command_plan(report, destination, derived_data, result_dir):
    if not report["selected_modules"]:
        return []
    base = (report["scheme"], destination, derived_data)
    return [["tuist", "generate", "--no-open"],
            xcode_command("build-for-testing", *base),
            *[xcode_command("test-without-building", *base) +
              [f"-only-testing:{name}Tests", "-resultBundlePath",
               str(result_dir / f"{name}.xcresult")]
              for name in report["selected_modules"]]]


def verify_scheme(report, selected):
    if report["demo_target"]:
        module = selected[0]
        path = (REPOSITORY_ROOT / module["projectPath"] / f"{module['name']}.xcodeproj"
                / "xcshareddata/xcschemes" / f"{report['scheme']}.xcscheme")
    else:
        path = REPOSITORY_ROOT / "Mody.xcworkspace/xcshareddata/xcschemes/ModyAllTests.xcscheme"
    action = ET.parse(path).getroot().find("TestAction")
    if (action is None or action.get("buildConfiguration") != "DEV"
            or action.get("codeCoverageEnabled") != "YES"
            or action.get("onlyGenerateCoverageForSpecifiedTargets") != "YES"):
        raise ValueError("Generated scheme must enable DEV coverage")
    testables = action.findall("Testables/TestableReference")
    references = [item.find("BuildableReference") for item in testables]
    if any(reference is None for reference in references):
        raise ValueError("Generated scheme is missing a test target reference")
    actual = [reference.get("BlueprintName") for reference in references]
    expected = [module["name"] + "Tests" for module in selected]
    if actual != expected or any(item.get("skipped") == "YES" for item in testables):
        raise ValueError("Generated scheme targets differ from selected policy; use matching shared JSON")
    coverage = action.findall("CodeCoverageTargets/BuildableReference")
    if [item.get("BlueprintName") for item in coverage] != [m["name"] for m in selected]:
        raise ValueError("Generated coverage targets differ from selected policy")
    return {item.get("BlueprintName"): item.get("BuildableName") for item in coverage}


def validated_coverage(module, targets, coverage_name):
    matches = [target for target in targets if target.get("name") == coverage_name]
    if len(matches) != 1:
        raise ValueError(f"Missing or ambiguous coverage target: {coverage_name}")
    target = matches[0]
    covered, executable = target.get("coveredLines"), target.get("executableLines")
    if (type(covered) is not int or type(executable) is not int
            or not 0 <= covered <= executable or executable == 0):
        raise ValueError("Invalid coverage line counts")
    source_directory = (REPOSITORY_ROOT / module["projectPath"] / "Sources").resolve()
    files = target.get("files")
    if not isinstance(files, list) or not files:
        raise ValueError("Missing coverage source files")
    seen = set()
    covered_sum = executable_sum = 0
    for source in files:
        raw_path = source.get("path")
        if not isinstance(raw_path, str) or not Path(raw_path).is_absolute():
            raise ValueError("Coverage requires an absolute source path")
        path = Path(raw_path).resolve()
        if not path.is_relative_to(source_directory) or not path.is_file() or path in seen:
            raise ValueError(f"Unexpected, missing or duplicate coverage source: {raw_path}")
        seen.add(path)
        file_covered, file_executable = source.get("coveredLines"), source.get("executableLines")
        if (type(file_covered) is not int or type(file_executable) is not int
                or not 0 <= file_covered <= file_executable):
            raise ValueError(f"Invalid source line counts: {raw_path}")
        covered_sum += file_covered
        executable_sum += file_executable
    if (covered_sum, executable_sum) != (covered, executable):
        raise ValueError("Coverage source line sums differ from target totals")
    return {"target": coverage_name, "covered_lines": covered, "executable_lines": executable,
            "line_percent": covered / executable * 100, "source_directory": str(source_directory),
            "file_count": len(files)}


def evaluate_gate(report):
    """Judge only selected modules; explicit skips never count as executed tests."""
    selected = set(report["selected_modules"])
    failed = bool(report["errors"]) or report["collection_status"] not in ("completed", "disabled")
    observed = [m["name"] for m in report["modules"] if m["name"] in selected]
    failed |= set(observed) != selected or len(observed) != len(selected)
    for module in report["modules"]:
        module.update(gate="not_evaluated", coverage_result="not_evaluated")
        if report["execution_mode"] != "execute":
            continue
        if module["name"] not in selected:
            module["gate"] = "passed" if module["reason"] in (
                "global_disabled", "module_disabled", "out_of_scope") else "failed"
            failed |= module["gate"] == "failed"
            continue
        coverage = module.get("coverage")
        if coverage and not threshold_errors([module]):
            # Compare exact ratios, including decimal JSON thresholds, without display rounding.
            passed = (Fraction(coverage["covered_lines"] * 100, coverage["executable_lines"])
                      >= Fraction(str(module["minimumCoverage"])))
            module["coverage_result"] = "passed" if passed else "failed"
        module["gate"] = "failed"
        if module["collection_status"] != "completed" or not module.get("finished_at"):
            pass  # Keep the recorded build/result/interruption reason.
        elif module["tests"] != "passed":
            module["reason"] = "test_failed"
        elif module["coverage_result"] != "passed":
            module["reason"] = "coverage_below_threshold" if coverage else "result_missing"
        else:
            module.update(gate="passed", reason="tests_and_coverage_passed")
        failed |= module["gate"] == "failed"
    report["decision"] = ("not_evaluated" if report["execution_mode"] != "execute" else
                          "failed" if failed else "passed" if selected else "disabled")


def collect_results(module, result, run_dir, invoke, coverage_name):
    name = module["name"]
    bundle = run_dir / f"{name}.xcresult"
    result["xcresult"] = str(bundle)
    result["errors"] = []
    if not bundle.is_dir():
        raise ValueError("Result bundle is missing")
    commands = {
        "test_summary": ["xcrun", "xcresulttool", "get", "test-results", "summary", "--path", str(bundle)],
        "test_cases": ["xcrun", "xcresulttool", "get", "test-results", "tests", "--path", str(bundle)],
        "coverage": ["xcrun", "xccov", "view", "--report", "--json", str(bundle)],
    }
    data = {}
    for kind, command in commands.items():
        path = run_dir / f"{name}.{kind}.json"
        result[kind + "_path"] = str(path)
        try:
            if invoke(command, path)["exit_code"] != 0:
                raise ValueError(f"{kind} extraction failed")
            data[kind] = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, ValueError) as error:
            result["errors"].append(str(error))
    summary = data.get("test_summary", {})
    counts = {key: summary.get(key) for key in
              ("totalTestCount", "passedTests", "failedTests", "skippedTests", "expectedFailures")}
    if any(type(value) is not int or value < 0 for value in counts.values()):
        result["errors"].append("Missing or invalid test counts")
    else:
        result["test_counts"] = counts
        result["test_failures"] = summary.get("testFailures", [])
        if counts["passedTests"] + counts["failedTests"] + counts["skippedTests"] + counts["expectedFailures"] != counts["totalTestCount"]:
            result["errors"].append("Inconsistent test counts")
        result["tests"] = ("passed" if result["exit_code"] == 0
                           and summary.get("result") == "Passed"
                           and counts["totalTestCount"] > 0
                           and counts["passedTests"] == counts["totalTestCount"]
                           and counts["failedTests"] == counts["skippedTests"] == counts["expectedFailures"] == 0
                           else "failed")
    bundles = []
    def visit(node):
        if node.get("nodeType") in ("Unit test bundle", "UI test bundle"):
            bundles.append(node.get("name"))
        for child in node.get("children", []):
            visit(child)
    for node in data.get("test_cases", {}).get("testNodes", []):
        visit(node)
    if bundles != [name + "Tests"]:
        result["errors"].append(f"Unexpected test bundles: {bundles}")
    try:
        result["coverage"] = validated_coverage(
            module, data.get("coverage", {}).get("targets", []), coverage_name)
    except ValueError as error:
        result["errors"].append(str(error))
    if result["errors"]:
        result["collection_status"] = "error"
        result["reason"] = "result_invalid"
    else:
        result["collection_status"] = "completed"
        result["reason"] = "collected" if result["tests"] == "passed" else "test_failed"


def execute_collection(args, report, selected):
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ") + "-" + uuid4().hex[:8]
    run_dir = (REPOSITORY_ROOT / args.results_dir / run_id).resolve()
    run_dir.mkdir(parents=True, exist_ok=False)
    derived_data = (REPOSITORY_ROOT / args.derived_data).resolve() if args.derived_data else run_dir / "DerivedData"
    report.update(run_id=run_id, result_directory=str(run_dir), started_at=timestamp(),
                  destination=args.destination, derived_data=str(derived_data),
                  collection_status="running", commands=[], commit=os.environ.get("GITHUB_SHA", "UNKNOWN"))
    publish_outputs(report)
    source = (REPOSITORY_ROOT / args.config).read_bytes()
    (run_dir / "configuration.json").write_bytes(source)
    report["configuration_sha256"] = hashlib.sha256(source).hexdigest()
    active = None
    failure_reason = "preparation_failed"
    def event(kind, **values):
        with (run_dir / "results.jsonl").open("a", encoding="utf-8") as stream:
            stream.write(json.dumps({"event": kind, "timestamp": timestamp(), "run_id": run_id,
                                    "commit": report["commit"], "deployment": report.get("deployment"),
                                    "demo_target": report["demo_target"],
                                    "configuration_sha256": report["configuration_sha256"], **values},
                                    allow_nan=False) + "\n")
    def invoke(command, log_path, env=None):
        outcome = run_command(command, log_path, args.command_timeout, env)
        report["commands"].append(outcome)
        event("command_finished", **outcome)
        return outcome
    def required(command, filename, env=None):
        outcome = invoke(command, run_dir / filename, env)
        if outcome["exit_code"] != 0:
            raise ValueError(f"Command failed ({outcome['exit_code']}): {command}; see {filename}")
    for module in report["modules"]:
        module.update(tests="not_run", collection_status="not_run")
        if module["reason"] == "selected":
            module["reason"] = "tests_not_completed"
    event("run_started", selected_modules=report["selected_modules"], decision="not_evaluated")
    write_json(run_dir / "summary.json", report)
    try:
        if selected:
            for command, filename in ((["xcodebuild", "-version"], "xcode-version.txt"),
                                      (["tuist", "version"], "tuist-version.txt"),
                                      (["xcrun", "simctl", "list", "runtimes", "-j"], "simulator-runtimes.json"),
                                      (["xcrun", "simctl", "list", "devices", "available", "-j"], "simulator-devices.json")):
                required(command, filename)
            invoke(["git", "rev-parse", "HEAD"], run_dir / "commit.txt")
            report["commit"] = (run_dir / "commit.txt").read_text().strip()
            invoke(["git", "status", "--short"], run_dir / "source-status.txt")
            if args.destination == "auto":
                report["destination"] = simulator_destination(run_dir / "simulator-devices.json")
            required(["tuist", "generate", "--no-open"], "generate.log",
                     {**os.environ, "TUIST_CONFIG_CACHE_MANIFESTS": "false"})
            coverage_names = verify_scheme(report, selected)
            base = (report["scheme"], report["destination"], derived_data)
            failure_reason = "build_failed"
            required(xcode_command("build-for-testing", *base), "build.log")
            failure_reason = "tests_not_completed"
            by_name = {module["name"]: module for module in report["modules"]}
            for module in selected:
                active = by_name[module["name"]]
                active.update(tests="error", collection_status="running", started_at=timestamp(),
                              log=str(run_dir / f"{module['name']}.log"),
                              xcresult=str(run_dir / f"{module['name']}.xcresult"))
                event("module_started", name=module["name"])
                write_json(run_dir / "summary.json", report)
                try:
                    outcome = invoke(xcode_command("test-without-building", *base) +
                                     [f"-only-testing:{module['name']}Tests", "-resultBundlePath",
                                      str(run_dir / f"{module['name']}.xcresult")],
                                     run_dir / f"{module['name']}.log")
                    active.update(exit_code=outcome["exit_code"], duration_seconds=outcome["duration_seconds"],
                                  log=outcome["log"])
                    collect_results(module, active, run_dir, invoke, coverage_names[module["name"]])
                except (OSError, ValueError, TypeError, AttributeError) as error:
                    active.update(collection_status="error", reason="result_invalid", errors=[str(error)])
                active["finished_at"] = timestamp()
                event("module_finished", module=active)
                write_json(run_dir / "summary.json", report)
                active = None
        failed = any(module["collection_status"] == "error" or module["tests"] in ("failed", "error")
                     for module in report["modules"])
        report["collection_status"] = "failed" if failed else "completed" if selected else "disabled"
    except KeyboardInterrupt:
        report["collection_status"] = "interrupted"
        failure_reason = "interrupted"
        if active is not None:
            active.update(collection_status="error", tests="error", reason="interrupted", finished_at=timestamp())
            event("module_finished", module=active)
    except (OSError, ValueError, TypeError, AttributeError, ET.ParseError) as error:
        report["collection_status"] = "failed"
        report["errors"].append(str(error))
    finally:
        for module in report["modules"]:
            if module["reason"] == "tests_not_completed":
                module["reason"] = failure_reason
                module["collection_status"] = "error"
        report["finished_at"] = timestamp()
        evaluate_gate(report)
        for module in report["modules"]:
            message = module_message(module)
            event("module_evaluated", module=module, message=message)
            print(f"timestamp={timestamp()} run_id={run_id} commit={report['commit']} "
                  f"deployment={report.get('deployment')} target={report['demo_target']} "
                  f"configuration_sha256={report['configuration_sha256']} {message}", flush=True)
        write_json(run_dir / "summary.json", report)
        rows = ["# Module test gate", "", f"Run: {run_id}; mode: {report['execution_mode']}",
                f"Commit: {report['commit']}; deployment: {report.get('deployment')}; target: {report['demo_target']}",
                f"Configuration SHA256: {report['configuration_sha256']}",
                f"Destination: {report['destination']}",
                f"Collection: {report['collection_status']}; deployment decision: {report['decision']}", "",
                "Counts: passed / failed / skipped / expected failures. Missing values mean NOT_RUN.", "",
                "| Module | Enabled | Tests | Counts | Exit | Seconds | Gate | Coverage comparison % (lines) | Minimum % | Coverage result | Reason |",
                "|---|---|---|---|---|---|---|---|---|---|---|"]
        for module in report["modules"]:
            measured = coverage_expression(module)
            counts = module.get("test_counts", {})
            count_text = " / ".join(str(counts.get(key, "NOT_RUN")) for key in
                                    ("passedTests", "failedTests", "skippedTests", "expectedFailures"))
            rows.append(f"| {module['name']} | {module.get('enabled')} | {module['tests']} | {count_text} | {module.get('exit_code', 'NOT_RUN')} | {module.get('duration_seconds', 'NOT_RUN')} | {module['gate']} | {measured} | {module.get('minimumCoverage', 'UNCONFIRMED')} | {module['coverage_result']} | {module['reason']} |")
        rows.extend(["", "## Results and failures", "",
                     "Artifact files: summary.json, results.jsonl, configuration.json; tool versions and simulator metadata are stored alongside them.", ""])
        for module in report["modules"]:
            if module["name"] in report["selected_modules"]:
                rows.append(f"- {module['name']}: log={module.get('log', 'NOT_RUN')}; xcresult={module.get('xcresult', 'NOT_RUN')}")
                for error in module.get("errors", []) + module.get("test_failures", []):
                    rows.append("  - " + json.dumps(error, ensure_ascii=False))
        rows.extend("- " + error.replace("\n", " ") for error in report["errors"])
        (run_dir / "summary.md").write_text("\n".join(rows) + "\n", encoding="utf-8")
        event("run_finished", collection_status=report["collection_status"], decision=report["decision"])
        publish_outputs(report)
    if report["collection_status"] == "interrupted":
        return 130
    return 0 if (report["collection_status"] in ("completed", "disabled")
                 and report["decision"] != "failed") else 1


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIGURATION)
    parser.add_argument("--deployment", choices=DEPLOYMENTS)
    parser.add_argument("--demo-target")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--collect-only", action="store_true", help="Execute and collect without a deployment gate")
    parser.add_argument("--destination", help="Explicit iOS Simulator destination, or auto for CI")
    parser.add_argument("--results-dir", type=Path, default=Path("Test/Result"))
    parser.add_argument("--derived-data", type=Path, help="Optional build cache; defaults to this run's DerivedData")
    parser.add_argument("--command-timeout", type=float, default=1800, help="Seconds per external command")
    args = parser.parse_args(argv)
    try:
        publish_outputs({"execution_mode": "dry_run" if args.dry_run else "collection" if args.collect_only else "execute",
                         "decision": "failed"})
        config = load_configuration(REPOSITORY_ROOT / args.config)
        deployment, target = resolve_deployment(args.deployment, args.demo_target)
        selected, modules = select_scope(config, deployment, target)
        errors = [] if args.collect_only else threshold_errors(selected)
        if not math.isfinite(args.command_timeout) or args.command_timeout <= 0:
            errors.append("--command-timeout must be a positive finite number")
        if not args.dry_run and selected:
            parts = (args.destination or "").split(",")
            if args.destination != "auto" and ("platform=iOS Simulator" not in parts or not any(p.startswith(("id=", "name=")) for p in parts)):
                errors.append("Collection requires --destination 'platform=iOS Simulator,id=<UDID>' or auto")
        report = {
            "execution_mode": "dry_run" if args.dry_run else "collection" if args.collect_only else "execute",
            "decision": "failed" if errors and not (args.dry_run or args.collect_only) else "not_evaluated",
            "deployment": deployment, "demo_target": target,
            "scheme": (target[:-4] + "Tests" if target else "ModyAllTests") if selected else None,
            "configuration_enabled": config["enabled"],
            "selected_modules": [module["name"] for module in selected], "modules": modules, "errors": errors,
        }
        if args.dry_run:
            report["generation_environment"] = {"TUIST_CONFIG_CACHE_MANIFESTS": "false"}
            report["command_plan"] = command_plan(report, args.destination or "<simulator-destination>",
                                                  args.derived_data or Path("<run-directory>/DerivedData"),
                                                  Path("<run-directory>"))
        status = 2 if errors else 0
        if not args.dry_run and not errors:
            def interrupted(signum, frame):
                raise KeyboardInterrupt()
            previous = signal.signal(signal.SIGTERM, interrupted)
            try:
                status = execute_collection(args, report, selected)
            finally:
                signal.signal(signal.SIGTERM, previous)
        print(json.dumps(report, indent=2, allow_nan=False))
        return status
    except (ConfigurationError, OSError, ValueError) as error:
        print(f"run_tests.py: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
