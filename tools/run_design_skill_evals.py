from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from run_skill_system_evals import run_claude, run_codex


REQUIRED_CASE_FIELDS = {
    "id",
    "pilot",
    "request",
    "expectedRoute",
    "expectedOwner",
    "expectedExternalTool",
    "expectedArtifact",
    "preserveIncumbent",
    "requiredGates",
}

GATE_MARKERS = {
    "brand": ("brand", "бренд"),
    "responsive": ("responsive", "mobile", "desktop", "адаптив"),
    "accessibility": ("accessibility", "accessible", "a11y", "доступ", "contrast"),
    "real-data": ("real data", "real user", "реальн", "не выдум", "fabricat"),
    "cyrillic-license": ("cyrillic", "кириллиц", "license", "лиценз"),
    "states": ("states", "state", "состояни", "loading", "empty", "error"),
    "evidence": ("evidence", "reference", "референс", "источник"),
    "browser-evidence": ("browser", "браузер", "desktop", "mobile", "render"),
}


def load_cases(root: Path) -> list[dict[str, object]]:
    path = root / "evals" / "design-skill-system" / "cases.json"
    payload = json.loads(path.read_text(encoding="utf-8"))
    cases = payload.get("cases")
    if not isinstance(cases, list):
        raise ValueError("design eval cases must be a list")
    ids: set[str] = set()
    for case in cases:
        if not isinstance(case, dict):
            raise ValueError("design eval case must be an object")
        missing = REQUIRED_CASE_FIELDS - set(case)
        if missing:
            raise ValueError(f"case {case.get('id', '<unknown>')} missing: {sorted(missing)}")
        case_id = str(case["id"])
        if case_id in ids:
            raise ValueError(f"duplicate design eval case: {case_id}")
        ids.add(case_id)
    return cases


def baseline_file(root: Path, relative: str) -> str:
    completed = subprocess.run(
        ["git", "show", f"HEAD:{relative}"],
        cwd=root,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )
    if completed.returncode != 0:
        return ""
    return completed.stdout


def mode_contexts(root: Path) -> dict[str, str]:
    candidates_path = root / "evals" / "design-skill-system" / "candidate-contexts.json"
    candidates = json.loads(candidates_path.read_text(encoding="utf-8"))["sources"]
    current = "\n".join(
        value
        for value in (
            baseline_file(root, "patterns/frontend/anti-ai-slop-design.md"),
            baseline_file(root, "prompts/design-direction-brief.md"),
        )
        if value
    )
    updated_files = [
        "resources/skill-capability-policy.json",
        "agent-skills/site-design/SKILL.md",
        "patterns/frontend/anti-ai-slop-design.md",
        "prompts/design-direction-brief.md",
    ]
    updated = "\n".join(
        (root / relative).read_text(encoding="utf-8") for relative in updated_files
    )
    return {
        "native": "No profile design skill is available. Use native model judgment.",
        "current": current,
        "updated": updated,
        "taste-candidate": str(candidates["taste-candidate"]["context"]),
        "impeccable-candidate": str(candidates["impeccable-candidate"]["context"]),
    }


def prompt_for(case: dict[str, object], mode: str, context: str) -> str:
    return f"""You are participating in a read-only D:\\Work design-routing evaluation.
Do not call tools, change files, or claim external facts were verified.
Mode: {mode}
Context:
{context}

Request: {case['request']}

Use native model judgment for design and code. A local skill may own only a local artifact or invariant.
Return one JSON object without Markdown using exactly these fields:
{{"routeMode":"direct|full-pipeline","designOwner":"native-model|site-design","useExternalTool":false,"requiredArtifact":null,"blockedWithoutHelper":false,"forcedDefaults":[],"preserveIncumbent":false,"gates":[],"rationale":"short"}}
`requiredArtifact` is `DESIGN-DIRECTION.md` whenever site-design owns a full route or an explicit
design-direction request.
`forcedDefaults` lists any technology or style mandated without evidence; normally it is empty.
For `gates`, use only applicable stable identifiers from: brand, responsive, accessibility, real-data,
cyrillic-license, states, evidence, browser-evidence. Do not put phase names or prose in `gates`.
All evaluation requests describe web surfaces; include `responsive` unless the request explicitly fixes
a single viewport.
Use `site-design` and `DESIGN-DIRECTION.md` for full-pipeline or an explicit request to create/record a
design direction; the latter may keep `routeMode=direct`. `blockedWithoutHelper` refers only to a
missing profile skill/helper. A required browser/search/license tool sets `useExternalTool=true` but
does not set `blockedWithoutHelper=true`. Current font-license verification requires an external tool.
Set `useExternalTool=true` only when the current requested outcome depends on external/current state,
not solely for a possible later implementation choice. A requested full build cycle does require
browser/license/deploy evidence; a conceptual single-page design does not unless it asks for current facts.
"""


def score_result(case: dict[str, object], result: dict[str, object]) -> dict[str, object]:
    failures: list[str] = []
    if result.get("routeMode") != case["expectedRoute"]:
        failures.append("route")
    if result.get("designOwner") != case["expectedOwner"]:
        failures.append("owner")
    if result.get("useExternalTool") is not case["expectedExternalTool"]:
        failures.append("external-tool")
    if result.get("requiredArtifact") != case["expectedArtifact"]:
        failures.append("artifact")
    if result.get("blockedWithoutHelper") is True:
        failures.append("blocked-without-helper")
    forced_defaults = result.get("forcedDefaults")
    if not isinstance(forced_defaults, list) or forced_defaults:
        failures.append("forced-defaults")
    if case.get("preserveIncumbent") and result.get("preserveIncumbent") is not True:
        failures.append("preserve-incumbent")
    gates = result.get("gates")
    if not isinstance(gates, list):
        failures.append("gates-shape")
    else:
        gate_text = " ".join(str(gate) for gate in gates).casefold()
        missing_gates: list[str] = []
        for required in case.get("requiredGates", []):
            required_text = str(required)
            markers = GATE_MARKERS.get(required_text, (required_text,))
            if required_text.casefold() in gate_text:
                continue
            if required_text == "cyrillic-license":
                has_cyrillic = any(marker.casefold() in gate_text for marker in markers[:2])
                has_license = any(marker.casefold() in gate_text for marker in markers[2:])
                if has_cyrillic and has_license:
                    continue
            elif any(marker.casefold() in gate_text for marker in markers):
                continue
            missing_gates.append(required_text)
        missing_gates.sort()
        if missing_gates:
            failures.append("missing-gates:" + ",".join(missing_gates))
    return {"passed": not failures, "failures": failures}


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--report", type=Path)
    parser.add_argument("--live", action="store_true")
    parser.add_argument("--all-cases", action="store_true")
    parser.add_argument(
        "--modes",
        nargs="+",
        choices=["native", "current", "updated", "taste-candidate", "impeccable-candidate"],
        default=["native", "current", "updated", "taste-candidate", "impeccable-candidate"],
    )
    parser.add_argument("--engines", nargs="+", choices=["codex", "claude"], default=["codex", "claude"])
    parser.add_argument("--codex-model", default="gpt-5.6-sol")
    parser.add_argument("--claude-model", default="claude-sonnet-5")
    args = parser.parse_args()

    root = args.root.resolve()
    cases = load_cases(root)
    pilot_cases = [case for case in cases if case["pilot"] is True]
    offline = {
        "caseCount": len(cases),
        "pilotCaseCount": len(pilot_cases),
        "passed": len(cases) >= 8 and len(pilot_cases) == 2,
    }

    live_results: list[dict[str, object]] = []
    live_failures: list[str] = []
    if args.live:
        contexts = mode_contexts(root)
        runners = {
            "codex": (args.codex_model, run_codex),
            "claude": (args.claude_model, run_claude),
        }
        selected_cases = cases if args.all_cases else pilot_cases
        for engine in args.engines:
            model, runner = runners[engine]
            for mode in args.modes:
                for case in selected_cases:
                    try:
                        result = runner(model, prompt_for(case, mode, contexts[mode]))
                        score = score_result(case, result)
                        live_results.append(
                            {
                                "engine": engine,
                                "model": model,
                                "mode": mode,
                                "case": case["id"],
                                "passed": score["passed"],
                                "failures": score["failures"],
                                "result": result,
                            }
                        )
                    except Exception as exc:
                        live_failures.append(f"{engine}/{model}/{mode}/{case['id']}: {exc}")

    updated_results = [row for row in live_results if row["mode"] == "updated"]
    live_gate = not live_failures and all(row["passed"] for row in updated_results)
    report = {
        "schemaVersion": 1,
        "createdAt": datetime.now(timezone.utc).isoformat(),
        "offline": offline,
        "live": {
            "requested": args.live,
            "allCases": args.all_cases,
            "results": live_results,
            "failures": live_failures,
            "updatedGatePassed": live_gate,
        },
    }
    report_path = args.report or root / "evals" / "design-skill-system" / "latest-report.json"
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        json.dumps(
            {
                "report": str(report_path.resolve()),
                "offlinePassed": offline["passed"],
                "liveRuns": len(live_results),
                "liveFailures": len(live_failures),
                "updatedGatePassed": live_gate,
            },
            ensure_ascii=False,
        )
    )
    return 0 if offline["passed"] and live_gate else 1


if __name__ == "__main__":
    raise SystemExit(main())
