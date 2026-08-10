import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "new-site-preflight.ps1"


def run_preflight(*args, cwd=ROOT):
    return subprocess.run(
        ["pwsh", "-NoProfile", "-File", str(SCRIPT), *args], cwd=cwd,
        text=True, encoding="utf-8", capture_output=True, check=False,
    )


def preflight_json(request, *extra_args, cwd=ROOT):
    result = run_preflight("-Request", request, "-OutputJson", *extra_args, cwd=cwd)
    assert result.returncode == 0, result.stdout + result.stderr
    return json.loads(result.stdout)


def test_preflight_exposes_both_router_axes():
    payload = preflight_json("Интернет-магазин на Shopify Hydrogen с checkout")
    assert payload["status"] == "ready"
    assert payload["recommendedPlaybook"] == "ecommerce"
    assert payload["recommendedDeliveryProfile"] == "public-fullstack"
    assert payload["supportingGuides"] == ["shopify-hydrogen", "headless-commerce"]
    assert "docs/13-playbooks/ecommerce.md" in payload["requiredWikiDocs"]
    assert payload["routeMode"] == "full-pipeline"
    assert payload["routeReasons"]


def test_api_only_and_ai_rag_are_recognized():
    api = preflight_json("Только API без frontend")
    rag = preflight_json("RAG приложение с векторным поиском")
    assert (api["recommendedPlaybook"], api["recommendedDeliveryProfile"]) == ("api-only-backend", "api-only")
    assert rag["recommendedPlaybook"] == "ai-rag-app"


def test_landing_audit_command_is_read_only(tmp_path):
    payload = preflight_json(
        "Нужен лендинг с SEO и формой заявки", "-Url", "http://localhost:3000",
        "-Routes", "/pricing,/contact", cwd=tmp_path,
    )
    assert "site-audit.ps1 -Url http://localhost:3000" in payload["siteAuditCommand"]
    assert "-Routes /pricing,/contact" in payload["siteAuditCommand"]
    assert not (tmp_path / "site-audit-report.json").exists()


def test_static_landing_uses_direct_route_without_pipeline_status():
    payload = preflight_json(
        "Простой статический лендинг на HTML и CSS, без backend, CMS, оплаты и авторизации"
    )
    assert payload["status"] == "ready"
    assert payload["recommendedPlaybook"] == "landing"
    assert payload["routeMode"] == "direct"
    assert "_pipeline-status.md" not in " ".join(payload["nextSteps"])


def test_local_page_edit_uses_direct_route_even_without_product_playbook():
    payload = preflight_json("Поправить текст и отступы в hero-блоке существующей страницы")
    assert payload["status"] == "ready"
    assert payload["routeMode"] == "direct"
    assert payload["routeReasons"]


def test_auth_and_payment_require_full_pipeline():
    payload = preflight_json("Новый SaaS: регистрация, роли, PostgreSQL и платежи")
    assert payload["routeMode"] == "full-pipeline"
    assert any("payment" in reason or "auth" in reason for reason in payload["routeReasons"])


def test_generic_request_fails_when_requested():
    result = run_preflight("-Request", "Сделай сайт", "-FailOnLowConfidence")
    assert result.returncode == 1
    assert "Preflight status: needs-discovery" in result.stdout
