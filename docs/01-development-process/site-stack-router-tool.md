---
title: "Site stack router tool"
category: "process"
updated: "2026-06-10"
status: "active"
tags: ["stack", "router", "site", "tooling"]
source_priority: "internal"
---

# Site stack router tool

`tools/site-stack-router.ps1` — локальный deterministic preflight для выбора архитектуры сайта по сырому запросу. Он не использует LLM/API и не заменяет discovery; его задача — быстро поймать low confidence, high-risk blockers and obvious stack routes.

## Когда использовать

- Перед `prompts/create-new-project.md`, если пользователь написал свободный запрос: "сделай сайт", "нужен SaaS", "лендинг с формой", "магазин на Shopify".
- Перед сравнением стеков в `prompts/choose-stack.md`.
- Для ревью агентского решения: проверить, что выбранный stack не противоречит router policy.

## Когда не использовать

- Как единственный источник требований. Router не знает бизнес-контекст, бюджет, hosting policy, legal constraints and team skill.
- Для security/compliance approval. Если request содержит payments, PII, SSO, tenant isolation или production data, нужен discovery/security review.
- Для генерации кода: перед реализацией всё равно нужно читать linked wiki docs.

## Команды

```powershell
pwsh tools/site-stack-router.ps1 -Request "Хочу SaaS с подписками"
pwsh tools/site-stack-router.ps1 -Request "Нужен лендинг с SEO и формой" -OutputJson
pwsh tools/site-stack-router.ps1 -Request "Сделай сайт" -FailOnLowConfidence
```

## Output contract

- `confidence`: `high`, `medium`, `low` или `blocker`.
- `classification`: найденные product/risk signals.
- `recommendedRoute` и `recommendedStack`: пустые при `low`, stack пустой при `blocker`.
- `assumptions`: что принято без подтверждения.
- `openQuestions`: максимум 3 вопроса, которые меняют архитектуру.
- `rejectedAlternatives`: почему не выбраны другие стеки.
- `acceptanceGates`: проверки, которые должны попасть в план.
- `wikiLinks`: документы, которые агент обязан прочитать перед реализацией.

## Production-паттерны

- При `low` не выбирать стек; сначала задать вопросы из результата.
- При `blocker` не начинать реализацию без security/compliance discovery.
- При `medium` можно предложить default, но assumptions and open questions должны быть в ответе.
- При `high` всё равно перечислить rejected alternatives and gates.

## Частые ошибки

- Использовать router как "магический выбор стека" без чтения wiki docs.
- Игнорировать `blocker`, потому что пользователь попросил "сразу сделать".
- Добавлять правила без tests: это ломает retrieval и будущий выбор архитектуры.
- Делать keyword rules слишком широкими, из-за чего "сделай сайт" получает stack.

## Проверка

Tool покрыт `tests/tools/test_site_stack_router.py` и входит в `python -m pytest tests/tools`, а через `pwsh tools/ci-local.ps1 -IncludeToolTests` — в обязательный локальный gate.

## Источники

- См. [Site architecture decision router](site-architecture-decision-router.md), [Stack selection](stack-selection.md), [Create new project prompt](../../prompts/create-new-project.md), [Choose stack prompt](../../prompts/choose-stack.md).
