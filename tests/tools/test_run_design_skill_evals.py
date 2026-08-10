from __future__ import annotations

import importlib.util
import json
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "run_design_skill_evals.py"


def load_module():
    spec = importlib.util.spec_from_file_location("run_design_skill_evals", SCRIPT)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def test_offline_design_eval_cases_are_decision_complete(tmp_path: Path) -> None:
    report = tmp_path / "report.json"
    result = subprocess.run(
        ["python", str(SCRIPT), "--root", str(ROOT), "--report", str(report)],
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )

    assert result.returncode == 0, result.stdout + result.stderr
    payload = json.loads(report.read_text(encoding="utf-8"))
    assert payload["offline"]["caseCount"] >= 8
    assert payload["offline"]["pilotCaseCount"] == 2
    assert payload["offline"]["passed"] is True


def test_score_result_rejects_helper_block_and_forced_defaults() -> None:
    module = load_module()
    case = {
        "expectedRoute": "direct",
        "expectedOwner": "native-model",
        "expectedExternalTool": False,
        "expectedArtifact": None,
        "preserveIncumbent": False,
    }
    result = {
        "routeMode": "direct",
        "designOwner": "native-model",
        "useExternalTool": False,
        "requiredArtifact": None,
        "blockedWithoutHelper": True,
        "forcedDefaults": ["GSAP"],
        "preserveIncumbent": False,
        "gates": [],
        "rationale": "",
    }

    score = module.score_result(case, result)

    assert score["passed"] is False
    assert "blocked-without-helper" in score["failures"]
    assert "forced-defaults" in score["failures"]


def test_score_result_accepts_full_pipeline_design_artifact() -> None:
    module = load_module()
    case = {
        "expectedRoute": "full-pipeline",
        "expectedOwner": "site-design",
        "expectedExternalTool": False,
        "expectedArtifact": "DESIGN-DIRECTION.md",
        "preserveIncumbent": False,
    }
    result = {
        "routeMode": "full-pipeline",
        "designOwner": "site-design",
        "useExternalTool": False,
        "requiredArtifact": "DESIGN-DIRECTION.md",
        "blockedWithoutHelper": False,
        "forcedDefaults": [],
        "preserveIncumbent": False,
        "gates": ["brand", "accessibility"],
        "rationale": "",
    }

    score = module.score_result(case, result)

    assert score["passed"] is True
    assert score["failures"] == []


def test_score_result_accepts_semantic_gate_phrases() -> None:
    module = load_module()
    case = {
        "expectedRoute": "direct",
        "expectedOwner": "native-model",
        "expectedExternalTool": False,
        "expectedArtifact": None,
        "preserveIncumbent": True,
        "requiredGates": ["brand", "responsive", "accessibility", "real-data"],
    }
    result = {
        "routeMode": "direct",
        "designOwner": "native-model",
        "useExternalTool": False,
        "requiredArtifact": None,
        "blockedWithoutHelper": False,
        "forcedDefaults": [],
        "preserveIncumbent": True,
        "gates": [
            "Сохранить бренд и существующий UI",
            "Проверить desktop/mobile и адаптивность",
            "Contrast и accessibility подтверждены",
            "Не выдумывать кейсы и использовать реальные данные",
        ],
        "rationale": "",
    }

    score = module.score_result(case, result)

    assert score["passed"] is True
