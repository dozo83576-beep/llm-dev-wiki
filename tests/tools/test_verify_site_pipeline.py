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


def write_project_fixture(
    project: Path,
    *,
    playbook: str = "landing",
    skip_phase: str | None = None,
    skip_reason: bool = True,
    missing_artifact: str | None = None,
    pending_phase: str | None = None,
) -> None:
    project.mkdir(parents=True)
    artifact_by_phase = {
        "site-discovery": "_discovery.md",
        "site-competitive-analysis": "_competitive-analysis.md",
        "site-stack": "_stack.md",
        "site-architecture": "_architecture.md",
        "project-agents": "AGENTS.md",
        "site-content": "_content-model.md",
        "site-design": "DESIGN-DIRECTION.md",
        "site-handoff": "handoff.md",
    }

    rows = []
    for index, phase in enumerate(PHASES, start=1):
        status = "done"
        if phase == skip_phase:
            status = "skipped"
        if phase == pending_phase:
            status = "pending"
        artifact = f"`{artifact_by_phase[phase]}`" if phase in artifact_by_phase else "—"
        rows.append(f"| {index} | {phase} | {status} | 2026-07-05 | {artifact} |")
        if status == "done" and phase in artifact_by_phase and phase != missing_artifact:
            (project / artifact_by_phase[phase]).write_text(phase, encoding="utf-8")

    skip_lines = []
    if skip_phase and skip_reason:
        skip_lines.append(f"- {skip_phase}: skipped — documented test reason")

    (project / "_pipeline-status.md").write_text(
        "\n".join(
            [
                "# Pipeline status — Fixture",
                "",
                f"Playbook: {playbook}",
                "Обновлено: 2026-07-05",
                "",
                "| # | Фаза | Статус | Дата | Артефакт |",
                "|---|------|--------|------|----------|",
                *rows,
                "",
                "## Пропуски и причины",
                "",
                *(skip_lines or ["- нет"]),
                "",
                "## Открытые вопросы",
                "",
                "- нет",
            ]
        ),
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


def test_full_project_pipeline_fixture_passes(tmp_path: Path) -> None:
    write_fixture(tmp_path)
    project = tmp_path / "project"
    write_project_fixture(project)

    result = run_verify_project(tmp_path, project)

    assert result.returncode == 0, result.stdout + result.stderr
    assert "ProjectRoot:" in result.stdout


def test_required_project_phase_skip_fails_for_non_api_project(tmp_path: Path) -> None:
    write_fixture(tmp_path)
    project = tmp_path / "project"
    write_project_fixture(project, skip_phase="site-content")

    result = run_verify_project(tmp_path, project)

    assert result.returncode == 1
    assert "Non-api project cannot skip required phase: site-content" in result.stdout


def test_done_project_phase_without_artifact_fails(tmp_path: Path) -> None:
    write_fixture(tmp_path)
    project = tmp_path / "project"
    write_project_fixture(project, missing_artifact="site-design")

    result = run_verify_project(tmp_path, project)

    assert result.returncode == 1
    assert "site-design -> DESIGN-DIRECTION.md" in result.stdout


def test_skipped_project_phase_without_reason_fails(tmp_path: Path) -> None:
    write_fixture(tmp_path)
    project = tmp_path / "project"
    write_project_fixture(project, skip_phase="site-seo", skip_reason=False)

    result = run_verify_project(tmp_path, project)

    assert result.returncode == 1
    assert "skipped phase has no reason: site-seo" in result.stdout


def test_done_project_phase_after_pending_fails(tmp_path: Path) -> None:
    write_fixture(tmp_path)
    project = tmp_path / "project"
    write_project_fixture(project, pending_phase="site-content")

    result = run_verify_project(tmp_path, project)

    assert result.returncode == 1
    assert "done phase after incomplete phase: site-design" in result.stdout


def test_api_only_backend_allows_documented_content_skip(tmp_path: Path) -> None:
    write_fixture(tmp_path)
    project = tmp_path / "project"
    write_project_fixture(project, playbook="api-only-backend", skip_phase="site-content")

    result = run_verify_project(tmp_path, project)

    assert result.returncode == 0, result.stdout + result.stderr


def run_verify_project(root: Path, project: Path) -> subprocess.CompletedProcess[str]:
    pwsh = shutil.which("pwsh")
    assert pwsh is not None, "pwsh is required for site pipeline verification tests"
    return subprocess.run(
        [
            pwsh,
            "-NoProfile",
            "-File",
            str(SCRIPT),
            "-Root",
            str(root),
            "-ProjectRoot",
            str(project),
        ],
        text=True,
        capture_output=True,
        check=False,
    )
