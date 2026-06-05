from __future__ import annotations

import shutil
import subprocess
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = REPO_ROOT / "tools" / "verify-workflows.ps1"


def write_fixture(root: Path, *, wiki_audit: str | None = None, technology_updates: str | None = None) -> None:
    workflow_dir = root / ".github" / "workflows"
    workflow_dir.mkdir(parents=True)
    tools_dir = root / "tools"
    tools_dir.mkdir()

    (tools_dir / "ci-local.ps1").write_text("", encoding="utf-8")
    (tools_dir / "technology-update-issue.js").write_text("", encoding="utf-8")
    (workflow_dir / "wiki-audit.yml").write_text(
        wiki_audit
        if wiki_audit is not None
        else "run: ./tools/ci-local.ps1 -IncludeToolTests -WriteGithubSummary\n",
        encoding="utf-8",
    )
    (workflow_dir / "technology-updates.yml").write_text(
        technology_updates
        if technology_updates is not None
        else "\n".join(
            [
                "run: ./tools/ci-local.ps1 -UpdateCheckOnly -IncludeUpdateCheck -WriteGithubSummary",
                "const { handleTechnologyUpdateIssue } = require('./tools/technology-update-issue.js');",
            ]
        ),
        encoding="utf-8",
    )


def run_verify(root: Path) -> subprocess.CompletedProcess[str]:
    pwsh = shutil.which("pwsh")
    assert pwsh is not None, "pwsh is required for workflow verification tests"
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


def test_inline_issue_mutation_fails(tmp_path: Path) -> None:
    write_fixture(
        tmp_path,
        technology_updates="\n".join(
            [
                "run: ./tools/ci-local.ps1 -UpdateCheckOnly -IncludeUpdateCheck -WriteGithubSummary",
                "const { handleTechnologyUpdateIssue } = require('./tools/technology-update-issue.js');",
                "await github.rest.issues.create({});",
            ]
        ),
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "inline GitHub issue mutation" in result.stdout


def test_direct_embeddings_in_wiki_audit_fails(tmp_path: Path) -> None:
    write_fixture(
        tmp_path,
        wiki_audit="\n".join(
            [
                "run: ./tools/ci-local.ps1 -IncludeToolTests -WriteGithubSummary",
                "run: python tools/build_embeddings.py --mode offline-text",
            ]
        ),
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "ci-local.ps1 owns that order" in result.stdout


def test_full_wiki_ci_in_technology_updates_fails(tmp_path: Path) -> None:
    write_fixture(
        tmp_path,
        technology_updates="\n".join(
            [
                "run: ./tools/ci-local.ps1 -UpdateCheckOnly -IncludeUpdateCheck -WriteGithubSummary",
                "const { handleTechnologyUpdateIssue } = require('./tools/technology-update-issue.js');",
                "run: pwsh ./tools/wiki-quality.ps1",
            ]
        ),
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "full blocking wiki CI" in result.stdout
