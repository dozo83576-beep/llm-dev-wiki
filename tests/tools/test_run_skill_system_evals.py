from __future__ import annotations

import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "run_skill_system_evals.py"


def test_offline_routing_eval_meets_gate(tmp_path: Path) -> None:
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
    assert payload["routing"]["directFalseFull"] == 0
    assert payload["routing"]["directTotal"] == 6
    assert payload["routing"]["fullCorrect"] == 4
    assert payload["routing"]["fullTotal"] == 4
    assert payload["routing"]["passed"] is True
