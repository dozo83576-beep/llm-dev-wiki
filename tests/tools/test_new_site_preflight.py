import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "new-site-preflight.ps1"


def run_preflight(*args, cwd=ROOT):
    return subprocess.run(
        ["pwsh", "-NoProfile", "-File", str(SCRIPT), *args],
        cwd=cwd,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )


def preflight_json(request, *extra_args, cwd=ROOT):
    result = run_preflight("-Request", request, "-OutputJson", *extra_args, cwd=cwd)
    assert result.returncode == 0, result.stderr
    return json.loads(result.stdout)


def test_saas_preflight_includes_router_docs_and_audit_template():
    payload = preflight_json("Хочу SaaS с подписками и личным кабинетом")

    assert payload["status"] == "ready"
    assert payload["confidence"] in {"medium", "high"}
    assert "SaaS" in payload["recommendedRoute"]
    assert "stacks/nextjs-fullstack.md" in payload["requiredWikiDocs"]
    assert payload["siteAuditCommand"].endswith("-Url '<dev-or-staging-url>'")
    assert payload["router"]["recommendedStack"] == payload["recommendedStack"]


def test_landing_preflight_with_url_and_routes_prints_concrete_audit_command(tmp_path):
    payload = preflight_json(
        "Нужен лендинг с SEO и формой заявки",
        "-Url",
        "http://localhost:3000",
        "-Routes",
        "/pricing,/contact",
        cwd=tmp_path,
    )

    assert payload["status"] == "ready"
    assert payload["recommendedRoute"] == "Landing"
    assert "site-audit.ps1 -Url http://localhost:3000" in payload["siteAuditCommand"]
    assert "-Routes /pricing,/contact" in payload["siteAuditCommand"]
    assert not (tmp_path / "site-audit-report.json").exists()
    assert not (tmp_path / "site-audit-report.md").exists()


def test_generic_request_fails_when_fail_on_low_confidence_enabled():
    result = run_preflight("-Request", "Сделай сайт", "-FailOnLowConfidence")

    assert result.returncode == 1
    assert "Preflight status: needs-discovery" in result.stdout
    assert "Decision confidence: low" in result.stdout


def test_output_json_is_parseable_and_contains_next_steps():
    payload = preflight_json("Shopify storefront с checkout")

    assert payload["recommendedRoute"] == "Shopify-first commerce"
    assert isinstance(payload["nextSteps"], list)
    assert payload["siteAuditCommand"]
