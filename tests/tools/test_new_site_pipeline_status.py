import concurrent.futures
import subprocess
from pathlib import Path

import pytest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "new-site-pipeline-status.ps1"


def run_status(project: Path, playbook="landing", *args):
    return subprocess.run(
        ["pwsh", "-NoProfile", "-File", str(SCRIPT), "-ProjectRoot", str(project),
         "-ProjectName", "Test", "-Playbook", playbook, *args],
        cwd=ROOT, text=True, encoding="utf-8", capture_output=True, check=False,
    )


def test_dry_run_does_not_write_and_prints_v2(tmp_path):
    result = run_status(tmp_path)
    assert result.returncode == 0, result.stdout + result.stderr
    assert not (tmp_path / "_pipeline-status.md").exists()
    assert "Contract-Version: 2" in result.stdout
    assert "Delivery-Profile: public-fullstack" in result.stdout


@pytest.mark.parametrize(
    ("playbook", "profile", "not_applicable"),
    [
        ("landing", "public-static", {"site-backend"}),
        ("landing", "public-fullstack", set()),
        ("admin-dashboard", "private-app", set()),
        ("api-only-backend", "api-only", {"site-content", "site-design", "site-frontend", "site-seo"}),
    ],
)
def test_apply_creates_profile_accurate_v2(tmp_path, playbook, profile, not_applicable):
    result = run_status(tmp_path, playbook, "-DeliveryProfile", profile, "-Apply")
    assert result.returncode == 0, result.stdout + result.stderr
    text = (tmp_path / "_pipeline-status.md").read_text(encoding="utf-8")
    assert text.count("| pending |") + text.count("| not-applicable |") == 17
    for phase in not_applicable:
        assert f"| {phase} | not-applicable |" in text


def test_supporting_guide_is_recorded(tmp_path):
    result = run_status(tmp_path, "ecommerce", "-SupportingGuides", "shopify-hydrogen", "-Apply")
    assert result.returncode == 0, result.stdout + result.stderr
    assert "Supporting-Guides: shopify-hydrogen" in (tmp_path / "_pipeline-status.md").read_text(encoding="utf-8")


def test_invalid_playbook_profile_pair_fails(tmp_path):
    result = run_status(tmp_path, "api-only-backend", "-DeliveryProfile", "public-fullstack")
    assert result.returncode != 0


def test_primary_playbook_cannot_be_smuggled_as_supporting_guide(tmp_path):
    result = run_status(tmp_path, "saas", "-SupportingGuides", "ai-rag-app")
    assert result.returncode != 0
    assert "Unsupported supporting guide" in result.stderr


def test_existing_status_is_never_overwritten(tmp_path):
    target = tmp_path / "_pipeline-status.md"
    target.write_text("keep", encoding="utf-8")
    result = run_status(tmp_path, "landing", "-Apply")
    assert result.returncode != 0
    assert target.read_text(encoding="utf-8") == "keep"


def test_concurrent_apply_has_single_winner(tmp_path):
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        results = list(pool.map(lambda _: run_status(tmp_path, "landing", "-Apply"), range(2)))
    assert sorted(result.returncode for result in results) == [0, 1]
    assert (tmp_path / "_pipeline-status.md").exists()
