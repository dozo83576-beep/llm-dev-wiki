import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "update-local-preferences.ps1"


def run_updater(*args):
    return subprocess.run(
        ["pwsh", "-NoProfile", "-File", str(SCRIPT), *args],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )


def base_args(preference_file: Path):
    return [
        "-PreferenceFile",
        str(preference_file),
        "-AllowCustomPath",
        "-Title",
        "Premium landing typography",
        "-Scope",
        "frontend",
        "-Preference",
        "Prefer expressive display font paired with readable body font.",
        "-Avoid",
        "Avoid generic AI purple gradients.",
        "-Evidence",
        "Approved by user after landing page review.",
        "-ReviewAfter",
        "2026-12-31",
        "-Links",
        "https://example.com/reference",
    ]


def test_dry_run_does_not_write_file(tmp_path):
    preference_file = tmp_path / "prefs.md"
    result = run_updater(*base_args(preference_file), "-DryRun")

    assert result.returncode == 0, result.stderr
    assert "Mode: dry-run" in result.stdout
    assert "Dry run only" in result.stdout
    assert not preference_file.exists()


def test_apply_appends_entry_without_overwriting(tmp_path):
    preference_file = tmp_path / "prefs.md"
    preference_file.write_text("# Existing\n\nKeep this.\n", encoding="utf-8")

    result = run_updater(*base_args(preference_file), "-Apply")

    assert result.returncode == 0, result.stderr
    content = preference_file.read_text(encoding="utf-8")
    assert "# Existing" in content
    assert "Keep this." in content
    assert "### Premium landing typography" in content
    assert "Prefer expressive display font" in content


def test_secret_like_input_is_blocked(tmp_path):
    preference_file = tmp_path / "prefs.md"
    args = base_args(preference_file)
    args[args.index("-Preference") + 1] = "Use api_key=super-secret-value in screenshots."

    result = run_updater(*args, "-Apply")

    assert result.returncode == 1
    assert "Status: blocked" in result.stdout
    assert "Unsafe preference content detected" in result.stdout
    assert not preference_file.exists()


def test_raw_openai_key_is_blocked(tmp_path):
    preference_file = tmp_path / "prefs.md"
    args = base_args(preference_file)
    args[args.index("-Preference") + 1] = (
        "Reference contains sk-1234567890abcdef1234567890abcdef1234567890abcdef."
    )

    result = run_updater(*args, "-Apply")

    assert result.returncode == 1
    assert "Unsafe preference content detected: openai-key" in result.stdout
    assert not preference_file.exists()


def test_github_token_is_blocked(tmp_path):
    preference_file = tmp_path / "prefs.md"
    args = base_args(preference_file)
    args[args.index("-Evidence") + 1] = "Approved with ghp_1234567890abcdef1234567890abcdef123456."

    result = run_updater(*args, "-Apply")

    assert result.returncode == 1
    assert "Unsafe preference content detected: github-token" in result.stdout
    assert not preference_file.exists()


def test_jwt_like_token_is_blocked(tmp_path):
    preference_file = tmp_path / "prefs.md"
    args = base_args(preference_file)
    args[args.index("-Links") + 1] = (
        "https://example.com/#eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.signaturetoken"
    )

    result = run_updater(*args, "-Apply")

    assert result.returncode == 1
    assert "Unsafe preference content detected: jwt" in result.stdout
    assert not preference_file.exists()


def test_harmless_date_and_public_url_are_allowed(tmp_path):
    preference_file = tmp_path / "prefs.md"
    args = base_args(preference_file)
    args[args.index("-ReviewAfter") + 1] = "2027-01-15"
    args[args.index("-Links") + 1] = "https://example.com/public-reference"

    result = run_updater(*args, "-DryRun")

    assert result.returncode == 0, result.stderr
    assert "Status: ok" in result.stdout
    assert not preference_file.exists()


def test_custom_preference_file_requires_explicit_allow(tmp_path):
    preference_file = tmp_path / "prefs.md"
    args = base_args(preference_file)
    args.remove("-AllowCustomPath")

    result = run_updater(*args, "-DryRun")

    assert result.returncode == 1
    assert "Custom PreferenceFile requires -AllowCustomPath" in result.stdout
    assert not preference_file.exists()


def test_default_preference_file_does_not_require_custom_path_flag():
    result = run_updater(
        "-Title",
        "Default path dry run",
        "-Scope",
        "frontend",
        "-Preference",
        "Prefer readable typography.",
        "-Evidence",
        "Review test.",
        "-ReviewAfter",
        "2027-01-15",
        "-DryRun",
    )

    assert result.returncode == 0, result.stderr
    assert "Preference file: D:\\Work\\AGENT-PREFERENCES.local.md" in result.stdout


def test_missing_required_field_fails(tmp_path):
    preference_file = tmp_path / "prefs.md"
    result = run_updater(
        "-PreferenceFile",
        str(preference_file),
        "-AllowCustomPath",
        "-Title",
        "Missing scope",
        "-Preference",
        "Prefer calm UI.",
        "-Evidence",
        "User approval.",
        "-ReviewAfter",
        "2026-12-31",
    )

    assert result.returncode == 1
    assert "Missing required field: Scope" in result.stdout
