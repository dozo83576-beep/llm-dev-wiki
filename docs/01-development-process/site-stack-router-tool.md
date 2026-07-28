---
title: "Site stack router tool"
category: "process"
updated: "2026-07-21"
status: "active"
tags: ["stack", "router", "site", "tooling", "contract-v2"]
source_priority: "internal"
---

# Site stack router tool

`tools/site-stack-router.ps1` — deterministic offline classifier перед discovery/scaffold. Он не
использует LLM/API и разделяет решение на две оси:

Практический ответ на вопрос «как автоматически определить стек сайта по сырому запросу»: запустить
router, принять его product/profile/platform classification как preflight hint, затем подтвердить
ограничения в discovery и выбрать стек в `site-stack`.

1. Тип продукта → один `recommendedPlaybook`.
2. Явные platform/runtime constraints → `supportingGuides` и stack hints.

Отдельно выбирается `recommendedDeliveryProfile`. Допустимые значения проверяются по
`resources/site-pipeline-contract.json`.

## Команды

```powershell
pwsh tools/site-stack-router.ps1 -Request "Корпоративный каталог услуг" -OutputJson
pwsh tools/site-stack-router.ps1 -Request "Интернет-магазин на Shopify Hydrogen" -OutputJson
pwsh tools/site-stack-router.ps1 -Request "Сделай сайт" -FailOnLowConfidence
```

## Output contract

- `confidence`: `high`, `medium`, `low`, `blocker`.
- `classification.productSignals` и `classification.platformSignals`.
- `recommendedPlaybook`, `recommendedDeliveryProfile`, `supportingGuides`.
- `recommendedRoute`, `recommendedStack`, assumptions, questions, gates и wiki links.

Primary playbooks: landing, content-site, saas, ecommerce, admin-dashboard, marketplace,
ai-rag-app, api-only-backend, real-time-app. Platform constraint не заменяет продукт: например,
WordPress/WooCommerce marketplace остаётся `marketplace` + guide `wordpress-woocommerce`.

## Правила

- Generic/неопределённый запрос → `low`, без playbook/stack.
- Одновременные payments + PII без security details → `blocker`.
- Shopify/Hydrogen guide активируется только явным положительным упоминанием. Отрицания вида
  «Shopify не используется» и обычные слова «каталог/товар» не являются Shopify-сигналом.
- `content-site` покрывает corporate/catalog services/blog/docs/CMS без checkout.
- Router не заменяет discovery, stack comparison или security approval.

## Частые ошибки

- Смешивать несколько primary playbook вместо одного primary + guides.
- Делать platform keyword продуктовым типом.
- Повторно запускать preflight из `site-stack` и получать второе решение.
- Добавлять широкое keyword-правило без negative/negation tests.

## Проверка и источники

Тесты: `tests/tools/test_site_stack_router.py`; полный gate:
`pwsh tools/ci-local.ps1 -IncludeToolTests`.

- [Pipeline contract](../../resources/site-pipeline-contract.json)
- [Architecture decision router](site-architecture-decision-router.md)
- [New site preflight](new-site-preflight-tool.md)
