import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "add-layout-consistency-smoke.ps1"


def run_script(project_root: Path, *args: str) -> subprocess.CompletedProcess[str]:
    pwsh = shutil.which("pwsh")
    assert pwsh is not None, "pwsh is required for PowerShell tool tests"
    return subprocess.run(
        [pwsh, "-NoProfile", "-File", str(SCRIPT), "-ProjectRoot", str(project_root), *args],
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )


def test_add_layout_consistency_smoke_creates_default_spec(tmp_path: Path) -> None:
    result = run_script(tmp_path)

    spec_path = tmp_path / "tests" / "layout-consistency.smoke.spec.ts"
    assert result.returncode == 0, result.stdout + result.stderr
    assert spec_path.exists()
    content = spec_path.read_text(encoding="utf-8")
    assert "layout consistency smoke" in content
    assert "scrollWidth" in content
    assert "getBoundingClientRect" in content
    assert "content gutters are consistent" in content
    assert "footer .mx-auto" not in content


def test_add_layout_consistency_smoke_does_not_overwrite_without_force(tmp_path: Path) -> None:
    spec_path = tmp_path / "tests" / "layout-consistency.smoke.spec.ts"
    spec_path.parent.mkdir()
    spec_path.write_text("custom", encoding="utf-8")

    result = run_script(tmp_path)

    assert result.returncode != 0
    assert "-Force" in result.stderr
    assert "overwrite" in result.stderr
    assert spec_path.read_text(encoding="utf-8") == "custom"


def test_add_layout_consistency_smoke_force_overwrites(tmp_path: Path) -> None:
    spec_path = tmp_path / "tests" / "layout-consistency.smoke.spec.ts"
    spec_path.parent.mkdir()
    spec_path.write_text("custom", encoding="utf-8")

    result = run_script(tmp_path, "-Force")

    assert result.returncode == 0, result.stdout + result.stderr
    assert "layout consistency smoke" in spec_path.read_text(encoding="utf-8")
