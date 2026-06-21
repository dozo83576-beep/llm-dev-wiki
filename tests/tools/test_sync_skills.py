from __future__ import annotations

import shutil
import subprocess
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
SYNC_SCRIPT = REPO_ROOT / "agent-skills" / "sync-skills.ps1"
VERIFY_SCRIPT = REPO_ROOT / "tools" / "verify-agent-skills.ps1"


def test_sync_skills_updates_runtime_cache_for_verifier(tmp_path: Path) -> None:
    pwsh = shutil.which("pwsh")
    assert pwsh is not None, "pwsh is required for sync-skills tests"

    fixture = tmp_path / "wiki"
    source = fixture / "agent-skills"
    tools = fixture / "tools"
    skill = source / "demo-skill"
    runtime = tmp_path / "runtime-cache"

    skill.mkdir(parents=True)
    tools.mkdir(parents=True)
    (skill / "SKILL.md").write_text(
        "---\nname: demo-skill\ndescription: Demo skill for sync test.\n---\n\n# Demo\n",
        encoding="utf-8",
    )
    shutil.copy2(SYNC_SCRIPT, source / "sync-skills.ps1")
    shutil.copy2(VERIFY_SCRIPT, tools / "verify-agent-skills.ps1")

    sync = subprocess.run(
        [
            pwsh,
            "-NoProfile",
            "-File",
            str(source / "sync-skills.ps1"),
            "-RuntimeCache",
            "-RuntimeRoot",
            str(runtime),
        ],
        text=True,
        capture_output=True,
        check=False,
    )
    assert sync.returncode == 0, sync.stdout + sync.stderr
    assert (runtime / "demo-skill" / "SKILL.md").read_text(encoding="utf-8").startswith("---")

    verify = subprocess.run(
        [
            pwsh,
            "-NoProfile",
            "-File",
            str(tools / "verify-agent-skills.ps1"),
            "-Root",
            str(fixture),
            "-RuntimeRoot",
            str(runtime),
        ],
        text=True,
        capture_output=True,
        check=False,
    )
    assert verify.returncode == 0, verify.stdout + verify.stderr
    assert "Failures: 0" in verify.stdout


def test_verify_agent_skills_fails_when_runtime_cache_differs(tmp_path: Path) -> None:
    pwsh = shutil.which("pwsh")
    assert pwsh is not None, "pwsh is required for sync-skills tests"

    fixture = tmp_path / "wiki"
    source_skill = fixture / "agent-skills" / "demo-skill"
    runtime_skill = tmp_path / "runtime-cache" / "demo-skill"
    tools = fixture / "tools"

    source_skill.mkdir(parents=True)
    runtime_skill.mkdir(parents=True)
    tools.mkdir(parents=True)
    (source_skill / "SKILL.md").write_text(
        "---\nname: demo-skill\ndescription: Source version.\n---\n\n# Demo\n",
        encoding="utf-8",
    )
    (runtime_skill / "SKILL.md").write_text(
        "---\nname: demo-skill\ndescription: Stale runtime version.\n---\n\n# Demo\n",
        encoding="utf-8",
    )
    shutil.copy2(VERIFY_SCRIPT, tools / "verify-agent-skills.ps1")

    verify = subprocess.run(
        [
            pwsh,
            "-NoProfile",
            "-File",
            str(tools / "verify-agent-skills.ps1"),
            "-Root",
            str(fixture),
            "-RuntimeRoot",
            str(tmp_path / "runtime-cache"),
        ],
        text=True,
        capture_output=True,
        check=False,
    )

    assert verify.returncode == 1
    assert "Runtime differs from tracked source: demo-skill\\SKILL.md" in verify.stdout
