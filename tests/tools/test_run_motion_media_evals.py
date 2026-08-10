from __future__ import annotations

import importlib.util
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "run_motion_media_evals.py"
SPEC = importlib.util.spec_from_file_location("run_motion_media_evals", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(MODULE)


def test_motion_media_case_set_has_two_pilots_and_required_scenarios() -> None:
    cases = MODULE.load_cases(ROOT)
    assert len(cases) >= 10
    assert sum(case["pilot"] is True for case in cases) == 2
    ids = {case["id"] for case in cases}
    assert {"direct-remotion-hero", "full-site-animated-hero", "sora-paid-opt-in", "meaningful-product-video"}.issubset(ids)


def test_score_accepts_exact_expected_result() -> None:
    case = MODULE.load_cases(ROOT)[1]
    result = {
        "routeMode": case["expectedRoute"],
        "interactionTier": case["expectedTier"],
        "mediaMode": case["expectedMediaMode"],
        "generator": case["expectedGenerator"],
        "artifacts": case["expectedArtifacts"],
        "useExternalTool": case["expectedExternalTool"],
        "blockedWithoutHelper": False,
        "libraries": case["expectedLibraries"],
        "gates": case["requiredGates"],
        "rationale": "ok",
    }
    assert MODULE.score(case, result) == []


def test_score_rejects_forced_helper_and_wrong_library() -> None:
    case = MODULE.load_cases(ROOT)[0]
    result = {
        "routeMode": "full-pipeline",
        "interactionTier": "cinematic",
        "mediaMode": "decorative",
        "generator": "sora",
        "artifacts": ["DESIGN-DIRECTION.md"],
        "useExternalTool": True,
        "blockedWithoutHelper": True,
        "libraries": ["gsap"],
        "gates": [],
    }
    failures = MODULE.score(case, result)
    assert "blockedWithoutHelper" in failures
    assert "libraries" in failures
    assert "routeMode" in failures


def test_prompt_links_browser_evidence_to_external_tool() -> None:
    case = MODULE.load_cases(ROOT)[1]
    text = MODULE.prompt_for(case, "updated", "context")
    assert "browser-evidence" in text
    assert "useExternalTool=true" in text
