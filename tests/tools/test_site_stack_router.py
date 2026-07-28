import json
import subprocess
from pathlib import Path

import pytest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "site-stack-router.ps1"


def run_router(*args):
    return subprocess.run(
        ["pwsh", "-NoProfile", "-File", str(SCRIPT), *args], cwd=ROOT,
        text=True, encoding="utf-8", capture_output=True, check=False,
    )


def route_json(request, *extra_args):
    result = run_router("-Request", request, "-OutputJson", *extra_args)
    assert result.returncode == 0, result.stdout + result.stderr
    return json.loads(result.stdout)


@pytest.mark.parametrize(
    ("request_text", "playbook", "profile"),
    [
        ("Лендинг для услуги", "landing", "public-fullstack"),
        ("Корпоративный сайт компании и блог", "content-site", "public-static"),
        ("SaaS с подписками и личным кабинетом", "saas", "public-fullstack"),
        ("Интернет-магазин с корзиной и доставкой", "ecommerce", "public-fullstack"),
        ("Внутренняя админ-панель для операторов", "admin-dashboard", "private-app"),
        ("Маркетплейс с несколькими продавцами", "marketplace", "public-fullstack"),
        ("RAG приложение с векторным поиском", "ai-rag-app", "public-fullstack"),
        ("Только API без frontend", "api-only-backend", "api-only"),
        ("Real-time приложение с WebSocket", "real-time-app", "public-fullstack"),
    ],
)
def test_all_primary_playbooks(request_text, playbook, profile):
    payload = route_json(request_text)
    assert payload["recommendedPlaybook"] == playbook
    assert payload["recommendedDeliveryProfile"] == profile


def test_landing_with_server_form_is_fullstack():
    payload = route_json("Нужен лендинг с SEO и формой заявки")
    assert payload["recommendedPlaybook"] == "landing"
    assert payload["recommendedDeliveryProfile"] == "public-fullstack"


def test_service_catalog_is_content_site_not_shopify():
    payload = route_json("Корпоративный каталог услуг и статьи")
    assert payload["recommendedPlaybook"] == "content-site"
    assert "shopify-hydrogen" not in payload["supportingGuides"]


def test_shopify_requires_explicit_positive_constraint():
    positive = route_json("Интернет-магазин на Shopify Hydrogen с checkout")
    negative = route_json("Интернет-магазин с каталогом, Shopify не используется")
    assert positive["recommendedPlaybook"] == "ecommerce"
    assert "shopify-hydrogen" in positive["supportingGuides"]
    assert "headless-commerce" in positive["supportingGuides"]
    assert "shopify-hydrogen" not in negative["supportingGuides"]


def test_wordpress_and_woocommerce_are_supporting_guides():
    payload = route_json("Интернет-магазин на WordPress WooCommerce")
    assert payload["recommendedPlaybook"] == "ecommerce"
    assert payload["supportingGuides"] == ["wordpress-woocommerce"]


def test_private_ai_and_realtime_profiles():
    ai = route_json("Внутреннее RAG приложение для сотрудников")
    realtime = route_json("Внутренняя real-time система с WebSocket")
    assert ai["recommendedDeliveryProfile"] == "private-app"
    assert realtime["recommendedDeliveryProfile"] == "private-app"


def test_framework_constraint_does_not_replace_primary_product():
    payload = route_json("SaaS на React Router с подписками")
    assert payload["recommendedPlaybook"] == "saas"
    assert "react-router" in payload["classification"]["platformSignals"]
    assert "React Router" in payload["recommendedStack"]


def test_generic_request_is_low_confidence():
    payload = route_json("Сделай сайт")
    assert payload["confidence"] == "low"
    assert payload["recommendedPlaybook"] == ""
    assert 2 <= len(payload["openQuestions"]) <= 3


def test_combined_payment_and_pii_risk_blocks_without_details():
    payload = route_json("SaaS с платежами и персональными данными")
    assert payload["confidence"] == "blocker"
    assert payload["recommendedStack"] == ""


def test_fail_on_low_confidence_exits_nonzero():
    result = run_router("-Request", "Нужен сайт", "-FailOnLowConfidence")
    assert result.returncode == 1
    assert "Decision confidence: low" in result.stdout
