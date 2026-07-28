from __future__ import annotations

import json
import shutil
import subprocess
from pathlib import Path
from typing import Any

import pytest


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


def write_watchlist(root: Path, entries: list[dict[str, Any]]) -> None:
    resources_dir = root / "resources"
    resources_dir.mkdir(parents=True, exist_ok=True)
    (resources_dir / "technology-watchlist.json").write_text(
        json.dumps(entries, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def check_updates(
    root: Path,
    entries: list[dict[str, Any]],
    latest: dict[str, Any],
    *,
    use_fixtures: bool = True,
) -> subprocess.CompletedProcess[str]:
    write_watchlist(root, entries)
    env = {
        **dict(__import__("os").environ),
        "LLM_DEV_WIKI_UPDATE_FIXTURES_JSON": json.dumps(latest),
    }
    args = ["-Root", str(root)]
    if use_fixtures:
        args.append("-UseFixtureVersions")
    return run_pwsh(CHECK_UPDATES, *args, env=env)


def base_entry(**overrides: str) -> dict[str, Any]:
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
    assert "| Example | npm | example | 1.0.0 | 2.0.0-rc.1 |  | prerelease-ignored |" in result.stdout


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
        "| Example | github-tags | example/specification | 2026-06-01 | 2026-07-28-RC |  | prerelease-ignored |"
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
    assert "| Example | npm | example | 1.0.0 | 2.0.0-rc.1 |  | update-available |" in result.stdout


def test_stable_latest_counts_update(tmp_path: Path) -> None:
    result = check_updates(
        tmp_path,
        [base_entry()],
        {"npm:example": "1.0.1"},
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "- Updates found: 1" in result.stdout
    assert "| Example | npm | example | 1.0.0 | 1.0.1 |  | update-available |" in result.stdout


def test_fixture_versions_are_ignored_without_explicit_flag(tmp_path: Path) -> None:
    result = check_updates(
        tmp_path,
        [base_entry(ecosystem="manual", currentVersion="")],
        {"manual:example": "fixture-version"},
        use_fixtures=False,
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "| Example | manual | example |  | manual-check |  | manual |" in result.stdout


def test_check_unavailable_counts_as_check_failure(tmp_path: Path) -> None:
    result = check_updates(
        tmp_path,
        [base_entry()],
        {"npm:example": "__ERROR__"},
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "- Updates found: 0" in result.stdout
    assert "- Check failures: 1" in result.stdout
    assert "| Example | npm | example | 1.0.0 | 1.0.0 |  | check-unavailable |" in result.stdout


def source_entry(name: str, ecosystem: str, current_version: str) -> dict[str, Any]:
    return {
        "name": name,
        "ecosystem": ecosystem,
        "currentVersion": current_version,
        "docsUrl": "https://example.com/docs",
        "notes": "Fixture entry for official release source tests.",
    }


def test_recommended_baseline_is_reported_without_counting_as_update(tmp_path: Path) -> None:
    entry = base_entry(currentVersion="2.0.0", recommendedBaseline="1.9.9")
    result = check_updates(tmp_path, [entry], {"npm:example": "2.0.0"})

    assert result.returncode == 0, result.stdout + result.stderr
    assert "- Updates found: 0" in result.stdout
    assert "- Baseline holds: 1" in result.stdout
    assert "| Example | npm | example | 2.0.0 | 2.0.0 | 1.9.9 | baseline-hold |" in result.stdout


def test_node_lts_ignores_newer_current_release(tmp_path: Path) -> None:
    entry = source_entry("Node.js", "nodejs-lts", "24.18.0")
    result = check_updates(
        tmp_path,
        [entry],
        {
            "nodejs-lts:Node.js": [
                {"version": "v26.5.0", "lts": False},
                {"version": "v24.18.0", "lts": "Krypton"},
            ]
        },
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "| Node.js | nodejs-lts | nodejs.org/dist/index.json | 24.18.0 | 24.18.0 |  | ok |" in result.stdout


def test_python_stable_ignores_prerelease_tags(tmp_path: Path) -> None:
    entry = source_entry("Python", "python-stable", "3.14.6")
    result = check_updates(
        tmp_path,
        [entry],
        {"python-stable:Python": ["v3.15.0b4", "v3.14.5", "v3.14.6"]},
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "| Python | python-stable | python/cpython | 3.14.6 | 3.14.6 |  | ok |" in result.stdout


def test_php_stable_selects_highest_stable_release(tmp_path: Path) -> None:
    entry = source_entry("PHP", "php-stable", "8.5.8")
    result = check_updates(
        tmp_path,
        [entry],
        {"php-stable:PHP": {"8.5.8": {}, "8.4.23": {}, "8.6.0RC1": {}}},
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "| PHP | php-stable | php.net/releases | 8.5.8 | 8.5.8 |  | ok |" in result.stdout


def test_wordpress_and_postgresql_official_payloads(tmp_path: Path) -> None:
    entries = [
        source_entry("WordPress", "wordpress-core", "7.0.2"),
        source_entry("PostgreSQL", "postgresql-stable", "18.4"),
    ]
    result = check_updates(
        tmp_path,
        entries,
        {
            "wordpress-core:WordPress": {
                "offers": [
                    {"version": "7.1-beta1"},
                    {"version": "7.0.2"},
                ]
            },
            "postgresql-stable:PostgreSQL": [
                {"major": 17, "latestMinor": 10, "supported": True},
                {"major": 19, "latestMinor": 0, "supported": False},
                {"major": 18, "latestMinor": 4, "supported": True},
            ],
        },
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "| WordPress | wordpress-core | api.wordpress.org/core/version-check | 7.0.2 | 7.0.2 |  | ok |" in result.stdout
    assert "| PostgreSQL | postgresql-stable | postgresql.org/versions.json | 18.4 | 18.4 |  | ok |" in result.stdout


def test_github_tags_skips_rc_before_stable_tag(tmp_path: Path) -> None:
    entry = {
        **source_entry("Docker", "github-tags", "v29.6.2"),
        "repository": "docker/cli",
    }
    result = check_updates(
        tmp_path,
        [entry],
        {"github-tags:docker/cli": ["v29.7.0-rc.1", "v29.6.2"]},
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "| Docker | github-tags | docker/cli | v29.6.2 | v29.6.2 |  | ok |" in result.stdout


def test_github_release_fixture_remains_backward_compatible(tmp_path: Path) -> None:
    entry = {
        **source_entry("Fresh", "github-releases", "2.3.3"),
        "repository": "freshframework/fresh",
    }
    result = check_updates(
        tmp_path,
        [entry],
        {"github-releases:freshframework/fresh": "2.3.3"},
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert "| Fresh | github-releases | freshframework/fresh | 2.3.3 | 2.3.3 |  | ok |" in result.stdout


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


def test_empty_recommended_baseline_fails_wiki_audit(tmp_path: Path) -> None:
    write_minimal_audit_fixture(tmp_path, base_entry(recommendedBaseline=""))

    result = run_pwsh(WIKI_AUDIT, "-Root", str(tmp_path))

    assert result.returncode == 1
    assert "empty recommendedBaseline" in result.stdout


def test_prerelease_recommended_baseline_fails_wiki_audit(tmp_path: Path) -> None:
    write_minimal_audit_fixture(tmp_path, base_entry(recommendedBaseline="2.0.0-rc.1"))

    result = run_pwsh(WIKI_AUDIT, "-Root", str(tmp_path))

    assert result.returncode == 1
    assert "recommendedBaseline must be stable" in result.stdout


@pytest.mark.parametrize(
    "ecosystem",
    ["nodejs-lts", "python-stable", "php-stable", "wordpress-core", "postgresql-stable"],
)
def test_official_source_ecosystems_are_accepted_by_wiki_audit(
    tmp_path: Path, ecosystem: str
) -> None:
    write_minimal_audit_fixture(
        tmp_path, source_entry("Official source", ecosystem, "1.0.0")
    )

    result = run_pwsh(WIKI_AUDIT, "-Root", str(tmp_path))

    assert result.returncode == 0, result.stdout + result.stderr


def test_new_ecosystem_still_requires_common_watchlist_fields(tmp_path: Path) -> None:
    entry = source_entry("Node.js", "nodejs-lts", "24.18.0")
    del entry["notes"]
    write_minimal_audit_fixture(tmp_path, entry)

    result = run_pwsh(WIKI_AUDIT, "-Root", str(tmp_path))

    assert result.returncode == 1
    assert "missing required field: notes" in result.stdout


def test_recommended_baseline_requires_current_version(tmp_path: Path) -> None:
    write_minimal_audit_fixture(
        tmp_path, base_entry(currentVersion="", recommendedBaseline="1.9.0")
    )

    result = run_pwsh(WIKI_AUDIT, "-Root", str(tmp_path))

    assert result.returncode == 1
    assert "recommendedBaseline requires currentVersion" in result.stdout
