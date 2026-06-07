from __future__ import annotations

import json
import shutil
import subprocess
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
CHECK_UPDATES = REPO_ROOT / "tools" / "check-updates.ps1"
WIKI_AUDIT = REPO_ROOT / "tools" / "wiki-audit.ps1"


def run_pwsh(script: Path, *args: str, env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    pwsh = shutil.which("pwsh")
    assert pwsh is not None, "pwsh is required for PowerShell tooling tests"
    return subprocess.run(
        [pwsh, "-NoProfile", "-File", str(script), *args],
        text=True,
        capture_output=True,
        check=False,
        env=env,
    )


def write_watchlist(root: Path, entries: list[dict[str, str]]) -> None:
    resources_dir = root / "resources"
    resources_dir.mkdir(parents=True, exist_ok=True)
    (resources_dir / "technology-watchlist.json").write_text(
        json.dumps(entries, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def check_updates(root: Path, entries: list[dict[str, str]], latest: dict[str, str]) -> subprocess.CompletedProcess[str]:
    write_watchlist(root, entries)
    env = {
        **dict(__import__("os").environ),
        "LLM_DEV_WIKI_UPDATE_FIXTURES_JSON": json.dumps(latest),
    }
    return run_pwsh(CHECK_UPDATES, "-Root", str(root), env=env)


def base_entry(**overrides: str) -> dict[str, str]:
    entry = {
        "name": "Example",
        "ecosystem": "npm",
        "package": "example",
        "currentVersion": "1.0.0",
        "docsUrl": "https://example.com/docs",
        "notes": "Fixture entry for update checker tests.",
    }
    entry.update(overrides)
    return entry


def test_stable_policy_ignores_prerelease_latest(tmp_path: Path) -> None:
    result = check_updates(
        tmp_path,
        [base_entry()],
        {"npm:example": "2.0.0-rc.1"},
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "- Updates found: 0" in result.stdout
    assert "| Example | npm | example | 1.0.0 | 2.0.0-rc.1 | prerelease-ignored |" in result.stdout


def test_stable_policy_ignores_github_tag_like_rc(tmp_path: Path) -> None:
    result = check_updates(
        tmp_path,
        [
            {
                "name": "Example",
                "ecosystem": "github-tags",
                "repository": "example/specification",
                "currentVersion": "2026-06-01",
                "docsUrl": "https://example.com/docs",
                "notes": "Fixture entry for GitHub tag update checker tests.",
            }
        ],
        {"github-tags:example/specification": "2026-07-28-RC"},
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "- Updates found: 0" in result.stdout
    assert (
        "| Example | github-tags | example/specification | 2026-06-01 | 2026-07-28-RC | prerelease-ignored |"
        in result.stdout
    )


def test_allow_prerelease_counts_prerelease_update(tmp_path: Path) -> None:
    result = check_updates(
        tmp_path,
        [base_entry(versionPolicy="allow-prerelease")],
        {"npm:example": "2.0.0-rc.1"},
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "- Updates found: 1" in result.stdout
    assert "| Example | npm | example | 1.0.0 | 2.0.0-rc.1 | update-available |" in result.stdout


def test_stable_latest_counts_update(tmp_path: Path) -> None:
    result = check_updates(
        tmp_path,
        [base_entry()],
        {"npm:example": "1.0.1"},
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "- Updates found: 1" in result.stdout
    assert "| Example | npm | example | 1.0.0 | 1.0.1 | update-available |" in result.stdout


def write_minimal_audit_fixture(root: Path, watchlist_entry: dict[str, str]) -> None:
    write_watchlist(root, [watchlist_entry])
    required_paths = [
        "README.md",
        "AGENTS.md",
        "llms.txt",
        "docs/00-start-here/overview.md",
        "docs/01-development-process/stack-selection.md",
        "docs/05-auth-security/MCP-security.md",
        "docs/09-testing/Unit-testing.md",
        "docs/13-playbooks/index.md",
        "docs/14-llm-indexing/index.md",
        "case-studies/successes/_template.md",
        "case-studies/failures/_template.md",
    ]
    markdown = "\n".join(
        [
            "---",
            'title: "Fixture"',
            'category: "process"',
            'updated: "2026-06-06"',
            'status: "active"',
            'tags: ["fixture"]',
            'source_priority: "internal"',
            "---",
            "",
            "# Fixture",
            "",
            "Minimal audit fixture.",
        ]
    )
    for relative_path in required_paths:
        path = root / relative_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(markdown, encoding="utf-8")

    checklist = root / "checklists" / "fixture.md"
    checklist.parent.mkdir(parents=True, exist_ok=True)
    checklist.write_text(markdown + "\n\n- [ ] Check fixture\n", encoding="utf-8")

    resource = root / "resources" / "links.md"
    resource.write_text(markdown + "\n\nhttps://example.com\n", encoding="utf-8")


def test_invalid_version_policy_fails_wiki_audit(tmp_path: Path) -> None:
    write_minimal_audit_fixture(tmp_path, base_entry(versionPolicy="release-candidates"))

    result = run_pwsh(WIKI_AUDIT, "-Root", str(tmp_path))

    assert result.returncode == 1
    assert "unsupported versionPolicy" in result.stdout
