import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "site-stack-router.ps1"


def run_router(*args):
    return subprocess.run(
        ["pwsh", "-NoProfile", "-File", str(SCRIPT), *args],
        cwd=ROOT,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )


def route_json(request, *extra_args):
    result = run_router("-Request", request, "-OutputJson", *extra_args)
    assert result.returncode == 0, result.stderr
    return json.loads(result.stdout)


def test_saas_subscription_routes_to_nextjs_fullstack():
    payload = route_json("Хочу SaaS с подписками и личным кабинетом")

    assert payload["confidence"] in {"medium", "high"}
    assert "SaaS" in payload["recommendedRoute"]
    assert "Next.js" in payload["recommendedStack"]
    assert "docs/13-playbooks/saas.md" in payload["wikiLinks"]
    assert "stacks/nextjs-fullstack.md" in payload["wikiLinks"]


def test_landing_seo_form_routes_to_astro_and_site_audit():
    payload = route_json("Нужен лендинг с SEO и формой заявки")

    assert payload["confidence"] in {"medium", "high"}
    assert payload["recommendedRoute"] == "Landing"
    assert "Astro" in payload["recommendedStack"]
    assert "docs/09-testing/Site-audit-tooling.md" in payload["wikiLinks"]
    assert any("site audit" in gate.lower() for gate in payload["acceptanceGates"])


def test_wordpress_editorial_route():
    payload = route_json("Сайт на WordPress для редакторов и публикаций")

    assert payload["confidence"] in {"medium", "high"}
    assert "WordPress" in payload["recommendedRoute"]
    assert "docs/02-frontend/WordPress.md" in payload["wikiLinks"]


def test_shopify_storefront_route():
    payload = route_json("Shopify storefront с cart, products и checkout")

    assert payload["confidence"] in {"medium", "high"}
    assert "Shopify" in payload["recommendedRoute"]
    assert "Hydrogen" in payload["recommendedStack"]
    assert "docs/13-playbooks/shopify-hydrogen.md" in payload["wikiLinks"]


def test_generic_site_request_is_low_confidence_without_stack():
    payload = route_json("Сделай сайт")

    assert payload["confidence"] == "low"
    assert payload["recommendedRoute"] == ""
    assert payload["recommendedStack"] == ""
    assert 2 <= len(payload["openQuestions"]) <= 3


def test_high_risk_request_blocks_without_constraints():
    payload = route_json("SaaS с платежами и персональными данными")

    assert payload["confidence"] == "blocker"
    assert payload["recommendedStack"] == ""
    assert any("security" in link.lower() for link in payload["wikiLinks"])
    assert 1 <= len(payload["openQuestions"]) <= 3


def test_output_json_is_parseable():
    payload = route_json("React Router framework app with loaders and actions")

    assert isinstance(payload["classification"]["signals"], list)
    assert "React Router" in payload["recommendedRoute"]


def test_fail_on_low_confidence_exits_nonzero():
    result = run_router("-Request", "Нужен сайт", "-FailOnLowConfidence")

    assert result.returncode == 1
    assert "Decision confidence: low" in result.stdout
