from __future__ import annotations

import shutil
import subprocess
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = REPO_ROOT / "tools" / "verify-site-pipeline.ps1"

PHASES = [
    "preflight",
    "site-discovery",
    "playbook",
    "site-competitive-analysis",
    "site-stack",
    "site-architecture",
    "project-agents",
    "site-content",
    "site-design",
    "site-backend",
    "site-frontend",
    "site-seo",
    "site-review",
    "site-deploy",
    "site-handoff",
    "post-release",
    "capture-learnings",
]


def write_fixture(root: Path, *, omit_phase: str | None = None) -> None:
    (root / "docs" / "01-development-process").mkdir(parents=True)
    (root / "docs" / "10-templates").mkdir(parents=True)
    (root / "agent-skills" / "build-modern-site" / "agents").mkdir(parents=True)
    (root / "agent-skills" / "hooks").mkdir(parents=True)

    rows = [
        f"| {index} | {phase} | x | x | x | x |"
        for index, phase in enumerate(PHASES, start=1)
        if phase != omit_phase
    ]
    table = "\n".join(rows)

    (root / "docs" / "01-development-process" / "site-pipeline-map.md").write_text(
        f"# Site pipeline map\n\nКанонические 17 фаз.\n\n{table}\n",
        encoding="utf-8",
    )
    (root / "docs" / "10-templates" / "pipeline-status.md").write_text(
        f"# Pipeline status\n\n{table}\n",
        encoding="utf-8",
    )
    (root / "docs" / "01-development-process" / "full-cycle.md").write_text(
        "13. Тестирование\n14. Security review\n",
        encoding="utf-8",
    )
    (root / "agent-skills" / "build-modern-site" / "SKILL.md").write_text(
        "17 фаз docs/01-development-process/site-pipeline-map.md\n"
        + "\n".join(PHASES),
        encoding="utf-8",
    )
    (root / "agent-skills" / "hooks" / "userpromptsubmit-site-intent.ps1").write_text(
        "17 фаз docs\\01-development-process\\site-pipeline-map.md\n",
        encoding="utf-8",
    )
    (root / "agent-skills" / "build-modern-site" / "agents" / "openai.yaml").write_text(
        "default_prompt: 17 phases docs/01-development-process/site-pipeline-map.md\n",
        encoding="utf-8",
    )


def run_verify(root: Path) -> subprocess.CompletedProcess[str]:
    pwsh = shutil.which("pwsh")
    assert pwsh is not None, "pwsh is required for site pipeline verification tests"
    return subprocess.run(
        [pwsh, "-NoProfile", "-File", str(SCRIPT), "-Root", str(root)],
        text=True,
        capture_output=True,
        check=False,
    )


def test_valid_fixture_passes(tmp_path: Path) -> None:
    write_fixture(tmp_path)

    result = run_verify(tmp_path)

    assert result.returncode == 0, result.stdout + result.stderr
    assert "Failures: 0" in result.stdout


def test_missing_phase_fails(tmp_path: Path) -> None:
    write_fixture(tmp_path, omit_phase="site-handoff")

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "site-handoff" in result.stdout
