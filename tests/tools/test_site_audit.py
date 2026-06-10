import json
import subprocess
import threading
from contextlib import contextmanager
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "site-audit.ps1"


def run_site_audit(*args):
    return subprocess.run(
        ["pwsh", "-NoProfile", "-File", str(SCRIPT), *args],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )


@contextmanager
def mock_site(headers):
    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            for name, value in headers.items():
                self.send_header(name, value)
            self.end_headers()
            self.wfile.write(b"<!doctype html><title>Mock</title><main>OK</main>")

        def log_message(self, format, *args):
            return

    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        yield f"http://127.0.0.1:{server.server_port}"
    finally:
        server.shutdown()
        server.server_close()
        thread.join(timeout=5)


def read_report(output_dir):
    return json.loads((output_dir / "site-audit-report.json").read_text(encoding="utf-8-sig"))


def test_lighthouse_package_is_pinned():
    source = SCRIPT.read_text(encoding="utf-8")

    assert '$LighthousePackage = "lighthouse@13.4.0"' in source
    assert "npx --yes lighthouse " not in source


def test_missing_headers_create_medium_findings_and_reports(tmp_path):
    output_dir = tmp_path / "audit"
    with mock_site({}) as url:
        result = run_site_audit(
            "-Url",
            url,
            "-OutputDir",
            str(output_dir),
            "-SkipLighthouse",
        )

    assert result.returncode == 0, result.stderr
    assert "Status: medium-findings" in result.stdout
    assert (output_dir / "site-audit-report.json").exists()
    assert (output_dir / "site-audit-report.md").exists()
    report = read_report(output_dir)
    assert report["findingCounts"]["medium"] >= 2
    checks = {finding["check"] for finding in report["findings"]}
    assert "csp" in checks
    assert "frame-protection" in checks


def test_fail_on_medium_exits_nonzero(tmp_path):
    with mock_site({}) as url:
        result = run_site_audit(
            "-Url",
            url,
            "-OutputDir",
            str(tmp_path / "audit"),
            "-SkipLighthouse",
            "-FailOnMedium",
        )

    assert result.returncode == 1
    assert "medium=" in result.stdout


def test_clean_headers_pass(tmp_path):
    headers = {
        "Content-Security-Policy": "default-src 'self'; frame-ancestors 'none'",
        "X-Frame-Options": "DENY",
        "Referrer-Policy": "strict-origin-when-cross-origin",
        "Permissions-Policy": "camera=(), microphone=(), geolocation=()",
    }
    output_dir = tmp_path / "audit"
    with mock_site(headers) as url:
        result = run_site_audit(
            "-Url",
            url,
            "-OutputDir",
            str(output_dir),
            "-SkipLighthouse",
            "-FailOnMedium",
        )

    assert result.returncode == 0, result.stderr
    report = read_report(output_dir)
    assert report["status"] == "ok"
    assert report["findingCounts"] == {"high": 0, "medium": 0, "low": 0}


def test_wildcard_cors_with_credentials_is_high(tmp_path):
    headers = {
        "Content-Security-Policy": "default-src 'self'; frame-ancestors 'none'",
        "X-Frame-Options": "DENY",
        "Referrer-Policy": "strict-origin-when-cross-origin",
        "Permissions-Policy": "camera=(), microphone=(), geolocation=()",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": "true",
    }
    output_dir = tmp_path / "audit"
    with mock_site(headers) as url:
        result = run_site_audit(
            "-Url",
            url,
            "-OutputDir",
            str(output_dir),
            "-SkipLighthouse",
            "-FailOnHigh",
        )

    assert result.returncode == 1
    report = read_report(output_dir)
    assert report["findingCounts"]["high"] == 1
    assert report["findings"][0]["check"] == "cors"
