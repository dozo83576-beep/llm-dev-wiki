import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "scan-local-preferences.ps1"


def run_scanner(*args):
    return subprocess.run(
        ["pwsh", "-NoProfile", "-File", str(SCRIPT), *args],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )


def test_clean_file_passes(tmp_path):
    preference_file = tmp_path / "prefs.md"
    preference_file.write_text(
        "# Preferences\n\nPrefer editorial typography and compact navigation.\n",
        encoding="utf-8",
    )

    result = run_scanner("-PreferenceFile", str(preference_file), "-AllowCustomPath")

    assert result.returncode == 0, result.stderr
    assert "Status: ok" in result.stdout
    assert "Findings: 0" in result.stdout


def test_raw_token_fails_when_fail_on_finding(tmp_path):
    preference_file = tmp_path / "prefs.md"
    preference_file.write_text(
        "Do not store sk-1234567890abcdef1234567890abcdef1234567890abcdef.\n",
        encoding="utf-8",
    )

    result = run_scanner(
        "-PreferenceFile",
        str(preference_file),
        "-AllowCustomPath",
        "-FailOnFinding",
    )

    assert result.returncode == 1
    assert "Status: findings" in result.stdout
    assert "openai-key" in result.stdout


def test_custom_path_requires_allow_custom_path(tmp_path):
    preference_file = tmp_path / "prefs.md"
    preference_file.write_text("Clean.\n", encoding="utf-8")

    result = run_scanner("-PreferenceFile", str(preference_file))

    assert result.returncode == 1
    assert "Status: blocked" in result.stdout
    assert "Custom PreferenceFile requires -AllowCustomPath" in result.stdout


def test_json_output_is_parseable(tmp_path):
    preference_file = tmp_path / "prefs.md"
    preference_file.write_text("Clean reference: https://example.com/public.\n", encoding="utf-8")

    result = run_scanner(
        "-PreferenceFile",
        str(preference_file),
        "-AllowCustomPath",
        "-OutputJson",
    )

    assert result.returncode == 0, result.stderr
    payload = json.loads(result.stdout)
    assert payload["status"] == "ok"
    assert payload["findingCount"] == 0
    assert Path(payload["preferenceFile"]).name == preference_file.name
