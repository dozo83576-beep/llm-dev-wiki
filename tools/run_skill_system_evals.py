from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path


def run_preflight(root: Path, request: str) -> dict[str, object]:
    completed = subprocess.run(
        [
            "pwsh", "-NoProfile", "-File", str(root / "tools" / "new-site-preflight.ps1"),
            "-Request", request, "-OutputJson", "-Root", str(root),
        ],
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )
    if completed.returncode != 0:
        raise RuntimeError(completed.stdout + completed.stderr)
    return json.loads(completed.stdout)


def baseline_skill(root: Path) -> str:
    completed = subprocess.run(
        ["git", "show", "HEAD:agent-skills/build-modern-site/SKILL.md"],
        cwd=root,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )
    if completed.returncode != 0:
        raise RuntimeError("Cannot load baseline skill from git HEAD")
    return completed.stdout


def mode_contexts(root: Path) -> dict[str, str]:
    return {
        "no-skills": "Профильные skills отсутствуют. Реши задачу нативно.",
        "current": "Текущая до обновления инструкция:\n" + baseline_skill(root),
        "updated": (
            "Обновлённая инструкция:\n"
            + (root / "agent-skills" / "build-modern-site" / "SKILL.md").read_text(encoding="utf-8")
            + "\nCapability policy:\n"
            + (root / "resources" / "skill-capability-policy.json").read_text(encoding="utf-8")
        ),
    }


def prompt_for(case: dict[str, str], mode: str, context: str) -> str:
    return f"""Ты участвуешь в read-only eval маршрутизации D:\\Work. Не вызывай инструменты и не меняй файлы.
Режим: {mode}
{context}

Запрос: {case['request']}

Верни только JSON-объект без markdown:
{{"routeMode":"direct|full-pipeline","useExternalTool":false,"requiresProductionApproval":false,"blockedWithoutHelper":false,"rationale":"кратко"}}
Выбирай full-pipeline только для сложного нового проекта с auth/ролями, CMS/сложными данными, платежами, серверными интеграциями, миграциями, несколькими контурами или явным полным циклом. Короткая правка и простой static идут direct."""


def extract_object(text: str) -> dict[str, object]:
    text = text.strip()
    try:
        value = json.loads(text)
        if isinstance(value, dict):
            return value
    except json.JSONDecodeError:
        pass
    matches = list(re.finditer(r"\{.*?\}", text, re.DOTALL))
    for match in reversed(matches):
        try:
            value = json.loads(match.group(0))
        except json.JSONDecodeError:
            continue
        if isinstance(value, dict):
            return value
    raise ValueError(f"No JSON object in model output: {text[-500:]}")


def cli_command(name: str) -> str:
    if os.name == "nt":
        wrapper = Path(os.environ.get("APPDATA", "")) / "npm" / f"{name}.cmd"
        if wrapper.is_file():
            return str(wrapper)
    resolved = shutil.which(name)
    if not resolved:
        raise FileNotFoundError(f"CLI not found: {name}")
    return resolved


def run_codex(model: str, prompt: str) -> dict[str, object]:
    with tempfile.TemporaryDirectory(prefix="skill-eval-") as temp_dir:
        output = Path(temp_dir) / "last.txt"
        completed = subprocess.run(
            [
                cli_command("codex"), "exec", "--model", model, "--sandbox", "read-only",
                "--ephemeral", "--ignore-user-config", "--ignore-rules",
                "--skip-git-repo-check", "--cd", temp_dir,
                "--output-last-message", str(output), "-",
            ],
            input=prompt,
            text=True,
            encoding="utf-8",
            capture_output=True,
            check=False,
            timeout=240,
        )
        if completed.returncode != 0 or not output.is_file():
            raise RuntimeError((completed.stdout + completed.stderr)[-1200:])
        return extract_object(output.read_text(encoding="utf-8"))


def run_claude(model: str, prompt: str) -> dict[str, object]:
    completed = subprocess.run(
        [
            cli_command("claude"), "--print", "--model", model, "--effort", "high",
            "--tools", "", "--disable-slash-commands", "--no-session-persistence",
            "--strict-mcp-config", "--mcp-config", '{"mcpServers":{}}',
            "--output-format", "json",
        ],
        input=prompt,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
        timeout=240,
    )
    if completed.returncode != 0:
        raise RuntimeError((completed.stdout + completed.stderr)[-1200:])
    wrapper = json.loads(completed.stdout)
    return extract_object(str(wrapper.get("result", "")))


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--report", type=Path)
    parser.add_argument("--live", action="store_true")
    parser.add_argument("--engines", nargs="+", choices=["codex", "claude"], default=["codex", "claude"])
    parser.add_argument("--codex-model", default="gpt-5.6-sol")
    parser.add_argument("--claude-model", default="claude-sonnet-5")
    args = parser.parse_args()

    root = args.root.resolve()
    cases = json.loads((root / "evals" / "skill-system" / "cases.json").read_text(encoding="utf-8"))
    routing_results: list[dict[str, object]] = []
    for case in cases["routingCases"]:
        result = run_preflight(root, case["request"])
        actual = result["routeMode"]
        routing_results.append({
            "id": case["id"], "expected": case["expectedRoute"], "actual": actual,
            "passed": actual == case["expectedRoute"], "routeReasons": result["routeReasons"],
        })
    direct = [row for row in routing_results if row["expected"] == "direct"]
    full = [row for row in routing_results if row["expected"] == "full-pipeline"]
    routing = {
        "directFalseFull": sum(row["actual"] == "full-pipeline" for row in direct),
        "directTotal": len(direct),
        "fullCorrect": sum(row["actual"] == "full-pipeline" for row in full),
        "fullTotal": len(full),
        "passed": all(row["passed"] for row in routing_results),
        "results": routing_results,
    }

    live_results: list[dict[str, object]] = []
    live_failures: list[str] = []
    if args.live:
        contexts = mode_contexts(root)
        runners = {
            "codex": (args.codex_model, run_codex),
            "claude": (args.claude_model, run_claude),
        }
        for engine in args.engines:
            model, runner = runners[engine]
            for mode, context in contexts.items():
                for case in cases["pilotCases"]:
                    try:
                        result = runner(model, prompt_for(case, mode, context))
                        passed = (
                            result.get("routeMode") == case["expectedRoute"]
                            and result.get("blockedWithoutHelper") is not True
                        )
                        live_results.append({
                            "engine": engine, "model": model, "mode": mode,
                            "case": case["id"], "expected": case["expectedRoute"],
                            "passed": passed, "result": result,
                        })
                    except Exception as exc:  # report unavailable model/runtime without hiding it
                        message = f"{engine}/{model}/{mode}/{case['id']}: {exc}"
                        live_failures.append(message)

    report = {
        "schemaVersion": 1,
        "createdAt": datetime.now(timezone.utc).isoformat(),
        "routing": routing,
        "live": {"requested": args.live, "results": live_results, "failures": live_failures},
    }
    report_path = args.report or (root / "evals" / "skill-system" / "latest-report.json")
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({
        "report": str(report_path.resolve()),
        "routingPassed": routing["passed"],
        "liveRuns": len(live_results),
        "liveFailures": len(live_failures),
    }, ensure_ascii=False))
    return 0 if routing["passed"] and not live_failures and all(row["passed"] for row in live_results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
