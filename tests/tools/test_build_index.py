from __future__ import annotations

import shutil
import subprocess
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
BUILD_INDEX_SCRIPT = REPO_ROOT / "tools" / "build-index.ps1"


def test_build_index_normalizes_line_endings_for_stable_output(tmp_path: Path) -> None:
    pwsh = shutil.which("pwsh")
    assert pwsh is not None, "pwsh is required for build-index tests"

    doc = tmp_path / "docs" / "crlf.md"
    doc.parent.mkdir(parents=True)
    content = (
        '---\r\n'
        'title: "CRLF Doc"\r\n'
        'category: "testing"\r\n'
        'updated: "2026-06-28"\r\n'
        'status: "active"\r\n'
        'source_priority: "internal"\r\n'
        '---\r\n'
        '\r\n'
        '# CRLF Doc\r\n'
        '\r\n'
        'Body line.\r\n'
    )
    doc.write_bytes(content.encode("utf-8"))

    result = subprocess.run(
        [
            pwsh,
            "-NoProfile",
            "-File",
            str(BUILD_INDEX_SCRIPT),
            "-Root",
            str(tmp_path),
        ],
        text=True,
        capture_output=True,
        check=False,
    )

    assert result.returncode == 0, result.stdout + result.stderr
    index_bytes = (tmp_path / "docs" / "INDEX.md").read_bytes()
    assert b"\r\n" not in index_bytes

    index = index_bytes.decode("utf-8")
    expected_chars = len(content.replace("\r\n", "\n"))
    assert f"| [docs/crlf.md](../docs/crlf.md) | CRLF Doc | testing | {expected_chars} |" in index
