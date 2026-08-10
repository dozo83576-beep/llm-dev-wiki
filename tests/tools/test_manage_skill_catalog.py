from __future__ import annotations

import json
import os
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "manage-skill-catalog.ps1"


def write_skill(root: Path, name: str, content: str | None = None) -> None:
    skill = root / name
    skill.mkdir(parents=True)
    (skill / "SKILL.md").write_text(
        content or f"---\nname: {name}\ndescription: Demo.\n---\n",
        encoding="utf-8",
    )


def write_policy(path: Path) -> None:
    path.write_text(
        json.dumps(
            {
                "catalog": {
                    "activeSkills": ["keep-me"],
                    "quarantineSkills": ["move-me"],
                }
            }
        ),
        encoding="utf-8",
    )


def run_catalog(*args: str) -> subprocess.CompletedProcess[str]:
    pwsh = shutil.which("pwsh")
    assert pwsh
    return subprocess.run(
        [pwsh, "-NoProfile", "-File", str(SCRIPT), *args],
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )


def make_junction(link: Path, target: Path) -> None:
    pwsh = shutil.which("pwsh")
    assert pwsh
    link.parent.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    env["SKILL_TEST_LINK"] = str(link)
    env["SKILL_TEST_TARGET"] = str(target)
    result = subprocess.run(
        [
            pwsh,
            "-NoProfile",
            "-Command",
            "New-Item -ItemType Junction -Path $env:SKILL_TEST_LINK -Target $env:SKILL_TEST_TARGET | Out-Null",
        ],
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
        env=env,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def test_audit_groups_identical_runtime_copies(tmp_path: Path) -> None:
    first, second = tmp_path / "codex", tmp_path / "claude"
    write_skill(first, "move-me")
    write_skill(second, "move-me")
    policy = tmp_path / "policy.json"
    write_policy(policy)

    result = run_catalog(
        "-Roots", f"{first},{second}", "-PolicyPath", str(policy), "-OutputJson"
    )

    assert result.returncode == 0, result.stdout + result.stderr
    payload = json.loads(result.stdout)
    item = next(item for item in payload["skills"] if item["name"] == "move-me")
    assert item["classification"] == "quarantine"
    assert item["variants"] == 1
    assert len(item["occurrences"]) == 2


def test_quarantine_is_dry_run_without_apply(tmp_path: Path) -> None:
    runtime = tmp_path / "runtime"
    write_skill(runtime, "move-me")
    policy = tmp_path / "policy.json"
    write_policy(policy)
    quarantine = tmp_path / "quarantine"

    result = run_catalog(
        "-Roots", str(runtime), "-PolicyPath", str(policy),
        "-Quarantine", "-QuarantineRoot", str(quarantine), "-OutputJson",
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert (runtime / "move-me").exists()
    assert not quarantine.exists()


def test_apply_then_restore_round_trip(tmp_path: Path) -> None:
    runtime = tmp_path / "runtime"
    write_skill(runtime, "move-me")
    write_skill(runtime, "keep-me")
    policy = tmp_path / "policy.json"
    write_policy(policy)
    quarantine = tmp_path / "quarantine"

    applied = run_catalog(
        "-Roots", str(runtime), "-PolicyPath", str(policy), "-Quarantine",
        "-QuarantineRoot", str(quarantine), "-Apply", "-OutputJson",
    )
    assert applied.returncode == 0, applied.stdout + applied.stderr
    payload = json.loads(applied.stdout)
    manifest = Path(payload["manifestPath"])
    assert manifest.exists()
    manifest_payload = json.loads(manifest.read_text(encoding="utf-8-sig"))
    entry = manifest_payload["entries"][0]
    assert entry["name"] == "move-me"
    assert entry["previousRuntimePath"].endswith("move-me")
    assert entry["reason"] == "generic-capability-overlap"
    assert entry["version"] == "unknown"
    assert "-Restore" in manifest_payload["restoreCommand"]
    assert not (runtime / "move-me").exists()
    assert (runtime / "keep-me").exists()

    restored = run_catalog(
        "-Restore", "-ManifestPath", str(manifest), "-Apply", "-OutputJson"
    )
    assert restored.returncode == 0, restored.stdout + restored.stderr
    assert (runtime / "move-me" / "SKILL.md").exists()


def test_provider_quarantine_keeps_claude_copy_but_removes_shared_agents_alias(
    tmp_path: Path,
) -> None:
    claude = tmp_path / ".claude" / "skills"
    agents = tmp_path / ".agents" / "skills"
    write_skill(claude, "vercel-react-best-practices")
    write_skill(agents, "vercel-react-best-practices")
    policy = tmp_path / "policy.json"
    policy.write_text(
        json.dumps(
            {
                "catalog": {
                    "activeSkills": ["vercel-react-best-practices"],
                    "quarantineSkills": [],
                    "providerQuarantine": {
                        "agents": ["vercel-react-best-practices"]
                    },
                }
            }
        ),
        encoding="utf-8",
    )

    result = run_catalog(
        "-Roots", f"{claude},{agents}", "-PolicyPath", str(policy),
        "-Quarantine", "-QuarantineRoot", str(tmp_path / "quarantine"),
        "-OutputJson",
    )

    assert result.returncode == 0, result.stdout + result.stderr
    payload = json.loads(result.stdout)
    assert len(payload["actions"]) == 1
    action = payload["actions"][0]
    assert action["name"] == "vercel-react-best-practices"
    assert ".agents" in action["source"]
    assert action["reason"] == "provider-capability-overlap"


def test_provider_quarantine_materializes_allowed_junction_before_moving_target(
    tmp_path: Path,
) -> None:
    agents = tmp_path / ".agents" / "skills"
    claude = tmp_path / ".claude" / "skills"
    shared_skill = agents / "vercel-react-best-practices"
    write_skill(agents, "vercel-react-best-practices")
    claude_link = claude / "vercel-react-best-practices"
    make_junction(claude_link, shared_skill)
    policy = tmp_path / "policy.json"
    policy.write_text(
        json.dumps(
            {
                "catalog": {
                    "activeSkills": ["vercel-react-best-practices"],
                    "quarantineSkills": [],
                    "providerQuarantine": {
                        "agents": ["vercel-react-best-practices"]
                    },
                }
            }
        ),
        encoding="utf-8",
    )

    result = run_catalog(
        "-Roots", f"{claude},{agents}", "-PolicyPath", str(policy),
        "-Quarantine", "-QuarantineRoot", str(tmp_path / "quarantine"),
        "-Apply", "-OutputJson",
    )

    assert result.returncode == 0, result.stdout + result.stderr
    assert not shared_skill.exists()
    assert (claude_link / "SKILL.md").is_file()
    assert claude_link.resolve() == claude_link.absolute()
