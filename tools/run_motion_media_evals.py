from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from run_skill_system_evals import run_claude, run_codex


REQUIRED_FIELDS = {
    "id", "pilot", "request", "expectedRoute", "expectedTier", "expectedMediaMode",
    "expectedGenerator", "expectedArtifacts", "expectedExternalTool", "expectedLibraries", "requiredGates",
}


def load_cases(root: Path) -> list[dict]:
    payload = json.loads((root / "evals/motion-media-system/cases.json").read_text(encoding="utf-8"))
    cases = payload.get("cases")
    if not isinstance(cases, list):
        raise ValueError("motion media cases must be a list")
    ids: set[str] = set()
    for case in cases:
        if not isinstance(case, dict) or REQUIRED_FIELDS - set(case):
            raise ValueError(f"invalid motion media case: {case.get('id', '<unknown>') if isinstance(case, dict) else case}")
        if case["id"] in ids:
            raise ValueError(f"duplicate motion media case: {case['id']}")
        ids.add(case["id"])
    return cases


def baseline(root: Path, relative: str) -> str:
    result = subprocess.run(
        ["git", "show", f"HEAD:{relative}"], cwd=root, text=True, encoding="utf-8", capture_output=True, check=False
    )
    return result.stdout if result.returncode == 0 else ""


def contexts(root: Path) -> dict[str, str]:
    current = "\n".join(
        filter(None, [baseline(root, "docs/02-frontend/Motion.md"), baseline(root, "patterns/frontend/purposeful-motion.md")])
    )
    updated = "\n".join(
        (root / relative).read_text(encoding="utf-8")
        for relative in (
            "resources/skill-capability-policy.json",
            "docs/02-frontend/Animated-sites-and-hero-media.md",
            "patterns/frontend/hero-video-delivery.md",
            "agent-skills/site-design/SKILL.md",
            "agent-skills/site-frontend/SKILL.md",
            "agent-skills/site-review/SKILL.md",
        )
    )
    return {
        "native": "No profile animation skill is available. Use native model judgment.",
        "current": current,
        "updated": updated,
    }


def prompt_for(case: dict, mode: str, context: str) -> str:
    return f"""You are in a read-only D:\\Work motion/media routing evaluation. Do not call tools or change files.
Mode: {mode}
Context:
{context}

Request: {case['request']}

Return one JSON object without Markdown using exactly these fields:
{{"routeMode":"direct|full-pipeline","interactionTier":"base|cinematic|specialized","mediaMode":"none|decorative|meaningful|synchronized","generator":"none|remotion|supplied|sora","artifacts":[],"useExternalTool":false,"blockedWithoutHelper":false,"libraries":[],"gates":[],"rationale":"short"}}
Use only justified libraries: gsap, rive or three. Native CSS/WAAPI/Motion judgment does not require listing a library.
ExternalTool means current web/provider/browser evidence, not local Remotion/FFmpeg runtime.
If the requested finished result requires browser-evidence, set useExternalTool=true even when media generation is local.
Artifact names may be DESIGN-DIRECTION.md, hero-media-brief.json and media-manifest.json.
Gate identifiers: brand, responsive, accessibility, reduced-motion, performance, provenance, browser-evidence,
license, fallback, captions, transcript, paid-approval, privacy, sunset.
No helper skill is required. A direct task must not create _pipeline-status.md.
"""


def score(case: dict, result: dict) -> list[str]:
    failures: list[str] = []
    mapping = {
        "routeMode": "expectedRoute",
        "interactionTier": "expectedTier",
        "mediaMode": "expectedMediaMode",
        "generator": "expectedGenerator",
        "useExternalTool": "expectedExternalTool",
    }
    for actual, expected in mapping.items():
        if result.get(actual) != case[expected]:
            failures.append(actual)
    if result.get("blockedWithoutHelper") is not False:
        failures.append("blockedWithoutHelper")
    for field, expected in (("artifacts", case["expectedArtifacts"]), ("libraries", case["expectedLibraries"])):
        value = result.get(field)
        if not isinstance(value, list) or sorted(map(str, value)) != sorted(map(str, expected)):
            failures.append(field)
    gates = result.get("gates")
    if not isinstance(gates, list) or not set(case["requiredGates"]).issubset(set(map(str, gates))):
        failures.append("gates")
    return failures


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--report", type=Path)
    parser.add_argument("--live", action="store_true")
    parser.add_argument("--all-cases", action="store_true")
    parser.add_argument("--modes", nargs="+", choices=["native", "current", "updated"], default=["native", "current", "updated"])
    parser.add_argument("--engines", nargs="+", choices=["codex", "claude"], default=["codex", "claude"])
    parser.add_argument("--codex-model", default="gpt-5.6-sol")
    parser.add_argument("--claude-model", default="claude-sonnet-5")
    args = parser.parse_args()

    root = args.root.resolve()
    cases = load_cases(root)
    pilots = [case for case in cases if case["pilot"] is True]
    offline_passed = len(cases) >= 10 and len(pilots) == 2
    rows: list[dict] = []
    errors: list[str] = []
    if args.live:
        context_map = contexts(root)
        runners = {"codex": (args.codex_model, run_codex), "claude": (args.claude_model, run_claude)}
        selected = cases if args.all_cases else pilots
        for engine in args.engines:
            model, runner = runners[engine]
            for mode in args.modes:
                for case in selected:
                    try:
                        result = runner(model, prompt_for(case, mode, context_map[mode]))
                        failures = score(case, result)
                        rows.append({"engine": engine, "model": model, "mode": mode, "case": case["id"], "passed": not failures, "failures": failures, "result": result})
                    except Exception as error:
                        errors.append(f"{engine}/{model}/{mode}/{case['id']}: {error}")
    updated_rows = [row for row in rows if row["mode"] == "updated"]
    live_passed = not errors and all(row["passed"] for row in updated_rows)
    report = {
        "schemaVersion": 1,
        "createdAt": datetime.now(timezone.utc).isoformat(),
        "offline": {"caseCount": len(cases), "pilotCaseCount": len(pilots), "passed": offline_passed},
        "live": {"requested": args.live, "results": rows, "errors": errors, "updatedGatePassed": live_passed},
    }
    report_path = args.report or root / "evals/motion-media-system/latest-report.json"
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"report": str(report_path), "offlinePassed": offline_passed, "liveRuns": len(rows), "liveErrors": len(errors), "updatedGatePassed": live_passed}, ensure_ascii=False))
    return 0 if offline_passed and live_passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
