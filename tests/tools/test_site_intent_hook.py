from __future__ import annotations

import json
import shutil
import subprocess
import tempfile
import uuid
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
HOOK = REPO_ROOT / "agent-skills" / "hooks" / "userpromptsubmit-site-intent.ps1"


def run_hook(prompt: str, session_id: str) -> subprocess.CompletedProcess[str]:
    pwsh = shutil.which("pwsh")
    assert pwsh is not None, "pwsh is required for hook tests"
    payload = json.dumps(
        {"prompt": prompt, "session_id": session_id},
        ensure_ascii=False,
    )
    return subprocess.run(
        [pwsh, "-NoProfile", "-File", str(HOOK)],
        input=payload,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )


def cleanup_markers(session_id: str) -> None:
    for marker in Path(tempfile.gettempdir()).glob(f"site-intent-{session_id}-*.flag"):
        marker.unlink(missing_ok=True)


def marker_paths(session_id: str) -> list[Path]:
    return list(Path(tempfile.gettempdir()).glob(f"site-intent-{session_id}-*.flag"))


def test_russian_utf8_site_intent_injects_context() -> None:
    session_id = f"pytest-{uuid.uuid4().hex}"
    try:
        result = run_hook("Я хочу создать сайт для клиники с формой записи", session_id)

        assert result.returncode == 0, result.stderr
        body = json.loads(result.stdout)
        context = body["hookSpecificOutput"]["additionalContext"]
        assert "build-modern-site" in context
        assert "routeMode" in context
        assert "все 17 фаз" not in context
        assert len(marker_paths(session_id)) == 1
    finally:
        cleanup_markers(session_id)


def test_meta_review_prompt_does_not_inject_context() -> None:
    session_id = f"pytest-{uuid.uuid4().hex}"
    try:
        result = run_hook("Сделай ревью системы создания сайтов", session_id)

        assert result.returncode == 0
        assert result.stdout == ""
    finally:
        cleanup_markers(session_id)


def test_same_site_intent_injects_once_per_session_and_hash() -> None:
    session_id = f"pytest-{uuid.uuid4().hex}"
    prompt = "Я хочу создать сайт для стоматологии"
    try:
        first = run_hook(prompt, session_id)
        second = run_hook(prompt, session_id)

        assert first.returncode == 0, first.stderr
        assert json.loads(first.stdout)["hookSpecificOutput"]["hookEventName"] == "UserPromptSubmit"
        assert second.returncode == 0
        assert second.stdout == ""
    finally:
        cleanup_markers(session_id)


def test_second_site_intent_in_same_session_uses_different_hash() -> None:
    session_id = f"pytest-{uuid.uuid4().hex}"
    try:
        first = run_hook("Я хочу создать сайт для клиники", session_id)
        second = run_hook("Я хочу создать сайт для юридической фирмы", session_id)

        assert first.returncode == 0, first.stderr
        assert second.returncode == 0, second.stderr
        assert json.loads(first.stdout)["hookSpecificOutput"]["hookEventName"] == "UserPromptSubmit"
        assert json.loads(second.stdout)["hookSpecificOutput"]["hookEventName"] == "UserPromptSubmit"
    finally:
        cleanup_markers(session_id)
