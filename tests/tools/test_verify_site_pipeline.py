from __future__ import annotations

import json
import subprocess
from pathlib import Path

import pytest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "verify-site-pipeline.ps1"
CONTRACT = json.loads((ROOT / "resources" / "site-pipeline-contract.json").read_text(encoding="utf-8"))
PHASES = sorted(CONTRACT["phases"], key=lambda item: item["number"])


def run_verify(project: Path | None = None, *extra: str) -> subprocess.CompletedProcess[str]:
    args = ["pwsh", "-NoProfile", "-File", str(SCRIPT), "-Root", str(ROOT)]
    if project is not None:
        args.extend(["-ProjectRoot", str(project)])
    args.extend(extra)
    return subprocess.run(args, cwd=ROOT, text=True, encoding="utf-8", capture_output=True, check=False)


def write_project(
    project: Path,
    *,
    playbook: str = "landing",
    profile: str = "public-fullstack",
    guides: list[str] | None = None,
    status_overrides: dict[str, str] | None = None,
    artifact_overrides: dict[str, str] | None = None,
    date_overrides: dict[str, str] | None = None,
    include_reasons: bool = True,
) -> Path:
    project.mkdir(parents=True, exist_ok=True)
    guides = guides or []
    status_overrides = status_overrides or {}
    artifact_overrides = artifact_overrides or {}
    date_overrides = date_overrides or {}
    profile_entry = next((item for item in CONTRACT["deliveryProfiles"] if item["id"] == profile), None)
    not_applicable = set(profile_entry["notApplicablePhases"] if profile_entry else [])
    rows: list[str] = []
    na_reasons: list[str] = []
    skip_reasons: list[str] = []

    for phase in PHASES:
        phase_id = phase["id"]
        default_status = "not-applicable" if phase_id in not_applicable else "done"
        status = status_overrides.get(phase_id, default_status)
        date = date_overrides.get(phase_id, "—" if status == "pending" else "2026-07-21")
        artifact = artifact_overrides.get(phase_id, f"`{phase['artifact']}`")
        if status == "not-applicable":
            artifact = "— (delivery-profile test)"
            if include_reasons:
                na_reasons.append(f"- {phase_id}: not-applicable — delivery-profile {profile}")
        if status == "skipped" and include_reasons:
            skip_reasons.append(f"- {phase_id}: skipped — test reason")
        rows.append(f"| {phase['number']} | {phase_id} | {status} | {date} | {artifact} |")

        if status == "done" and phase_id != "playbook" and artifact.startswith("`"):
            token = artifact.strip("`")
            artifact_path = project / token
            artifact_path.parent.mkdir(parents=True, exist_ok=True)
            content = phase_id
            if playbook == "marketplace" and phase_id in {"site-design", "site-frontend"}:
                content += "\n\n## Public storefront\nOK\n\n## Private console\nOK\n"
            artifact_path.write_text(content, encoding="utf-8")

    status_path = project / "_pipeline-status.md"
    status_path.write_text(
        "\n".join(
            [
                "# Pipeline status — Fixture",
                "",
                f"Contract-Version: {CONTRACT['contractVersion']}",
                f"Playbook: {playbook}",
                f"Supporting-Guides: {', '.join(guides) if guides else '—'}",
                f"Delivery-Profile: {profile}",
                "Обновлено: 2026-07-21",
                "",
                "| # | Фаза | Статус | Дата | Артефакт |",
                "|---|------|--------|------|----------|",
                *rows,
                "",
                "## Неприменимые фазы",
                "",
                *(na_reasons or ["- нет"]),
                "",
                "## Пропуски и причины",
                "",
                *(skip_reasons or ["- нет"]),
                "",
                "## Открытые вопросы",
                "",
                "- нет",
            ]
        ),
        encoding="utf-8",
    )
    return status_path


def test_canonical_contract_and_docs_are_consistent() -> None:
    result = run_verify()

    assert result.returncode == 0, result.stdout + result.stderr
    assert "Expected phases: 17" in result.stdout
    assert "Failures: 0" in result.stdout


@pytest.mark.parametrize(
    ("playbook", "profile"),
    [
        ("landing", "public-static"),
        ("landing", "public-fullstack"),
        ("admin-dashboard", "private-app"),
        ("api-only-backend", "api-only"),
    ],
)
def test_delivery_profiles_complete_successfully(tmp_path: Path, playbook: str, profile: str) -> None:
    project = tmp_path / "project"
    write_project(project, playbook=playbook, profile=profile)

    result = run_verify(project, "-RequireComplete")

    assert result.returncode == 0, result.stdout + result.stderr


def test_marketplace_requires_both_artifact_sections(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project, playbook="marketplace", profile="public-fullstack")
    (project / "DESIGN-DIRECTION.md").write_text("Public storefront only", encoding="utf-8")

    result = run_verify(project)

    assert result.returncode == 1
    assert "missing marker for marketplace: Private console" in result.stdout


def test_backend_can_complete_while_design_is_in_progress(tmp_path: Path) -> None:
    project = tmp_path / "project"
    downstream = {
        "site-design": "in-progress",
        "site-frontend": "pending",
        "site-seo": "pending",
        "site-review": "pending",
        "site-deploy": "pending",
        "site-handoff": "pending",
        "post-release": "pending",
        "capture-learnings": "pending",
    }
    write_project(project, status_overrides=downstream)

    result = run_verify(project, "-RequirePhase", "site-backend")

    assert result.returncode == 0, result.stdout + result.stderr


def test_phase_cannot_complete_before_graph_dependency(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project, status_overrides={"site-design": "pending"})

    result = run_verify(project)

    assert result.returncode == 1
    assert "site-frontend has incomplete dependency: site-design" in result.stdout


def test_require_complete_rejects_pending_phase(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project, status_overrides={"capture-learnings": "pending"})

    result = run_verify(project, "-RequireComplete")

    assert result.returncode == 1
    assert "Project pipeline is not complete: capture-learnings" in result.stdout


def test_unknown_primary_playbook_fails(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project, playbook="landing + saas")

    result = run_verify(project)

    assert result.returncode == 1
    assert "unsupported primary playbook" in result.stdout


def test_invalid_playbook_profile_pair_fails(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project, playbook="saas", profile="public-static")

    result = run_verify(project)

    assert result.returncode == 1
    assert "does not allow delivery profile" in result.stdout


def test_unknown_supporting_guide_fails(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project, guides=["made-up-guide"])

    result = run_verify(project)

    assert result.returncode == 1
    assert "unsupported supporting guide" in result.stdout


def test_primary_playbook_id_is_not_a_supporting_guide(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project, guides=["ai-rag-app"])

    result = run_verify(project)

    assert result.returncode == 1
    assert "unsupported supporting guide: ai-rag-app" in result.stdout


def test_profile_requires_exact_not_applicable_set(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project, playbook="api-only-backend", profile="api-only", status_overrides={"site-seo": "done"})

    result = run_verify(project)

    assert result.returncode == 1
    assert "requires not-applicable phase: site-seo" in result.stdout


def test_non_optional_phase_cannot_be_skipped(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project, status_overrides={"site-content": "skipped"})

    result = run_verify(project)

    assert result.returncode == 1
    assert "cannot skip required phase: site-content" in result.stdout


def test_post_release_may_be_skipped_with_reason(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project, status_overrides={"post-release": "skipped"})

    result = run_verify(project, "-RequireComplete")

    assert result.returncode == 0, result.stdout + result.stderr


def test_not_applicable_and_skipped_require_structured_reasons(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(
        project,
        playbook="api-only-backend",
        profile="api-only",
        status_overrides={"post-release": "skipped"},
        include_reasons=False,
    )

    result = run_verify(project)

    assert result.returncode == 1
    assert "not-applicable phase has no reason" in result.stdout
    assert "skipped phase has no reason" in result.stdout


@pytest.mark.parametrize("bad_date", ["21.07.2026", "2026-02-31"])
def test_non_pending_phase_requires_real_iso_date(tmp_path: Path, bad_date: str) -> None:
    project = tmp_path / "project"
    write_project(project, date_overrides={"site-design": bad_date})

    result = run_verify(project)

    assert result.returncode == 1
    assert "site-design must use YYYY-MM-DD date" in result.stdout


def test_duplicate_phase_number_fails(tmp_path: Path) -> None:
    project = tmp_path / "project"
    status = write_project(project)
    text = status.read_text(encoding="utf-8").replace(
        "| 17 | capture-learnings |", "| 16 | capture-learnings |"
    )
    status.write_text(text, encoding="utf-8")

    result = run_verify(project)

    assert result.returncode == 1
    assert "duplicate phase number: 16" in result.stdout


def test_done_phase_requires_canonical_nonempty_artifact(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project, artifact_overrides={"site-design": "`../outside.md`"})
    (tmp_path / "outside.md").write_text("outside", encoding="utf-8")

    result = run_verify(project)

    assert result.returncode == 1
    assert "must use canonical artifact: DESIGN-DIRECTION.md" in result.stdout

    write_project(project, status_overrides={"site-design": "done"})
    (project / "DESIGN-DIRECTION.md").write_text("", encoding="utf-8")
    result = run_verify(project)
    assert result.returncode == 1
    assert "artifact is empty: site-design" in result.stdout


def test_canonical_artifact_symlink_outside_project_fails(tmp_path: Path) -> None:
    project = tmp_path / "project"
    write_project(project)
    outside = tmp_path / "outside.md"
    outside.write_text("outside", encoding="utf-8")
    design = project / "DESIGN-DIRECTION.md"
    design.unlink()
    try:
        design.symlink_to(outside)
    except OSError as error:
        pytest.skip(f"Creating a file symlink is unavailable: {error}")

    result = run_verify(project)

    assert result.returncode == 1
    assert "artifact must stay inside ProjectRoot: site-design" in result.stdout


@pytest.mark.skipif(__import__("os").name != "nt", reason="Windows junction regression")
def test_project_root_junction_to_real_project_passes(tmp_path: Path) -> None:
    project = tmp_path / "real-project"
    write_project(project)
    junction = tmp_path / "project-junction"
    junction_arg = str(junction).replace("'", "''")
    project_arg = str(project).replace("'", "''")
    created = subprocess.run(
        [
            "pwsh", "-NoProfile", "-Command",
            f"New-Item -ItemType Junction -Path '{junction_arg}' -Target '{project_arg}' | Out-Null",
        ],
        text=True, encoding="utf-8", capture_output=True, check=False,
    )
    if created.returncode != 0:
        pytest.skip(f"Creating a junction is unavailable: {created.stderr}")

    result = run_verify(junction, "-RequireComplete")

    assert result.returncode == 0, result.stdout + result.stderr


def test_require_phase_needs_project_root() -> None:
    result = run_verify(None, "-RequirePhase", "site-review")

    assert result.returncode == 1
    assert "requires -ProjectRoot" in result.stdout
