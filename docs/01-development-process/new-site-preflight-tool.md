---
title: "New site preflight tool"
category: "process"
updated: "2026-08-10"
status: "active"
tags: ["site", "preflight", "stack", "audit"]
source_priority: "internal"
---

# New site preflight tool

`tools/new-site-preflight.ps1` — единая offline-команда перед созданием сайта. Router классифицирует
две независимые оси: продукт → primary playbook; platform constraints → supporting guides/stack.
Также выбирается delivery profile. Скрипт не использует LLM/API, не ходит в сеть и не меняет проект.
Отдельно он возвращает режим выполнения: короткий `direct` или контрактный `full-pipeline`.

Это **канонический источник** триггер-фразы raw request: скиллы (`build-modern-site`, `site-stack`) её не переопределяют, а ссылаются сюда.

## Когда использовать

- Когда пользователь пишет `Я хочу создать сайт <описание сайта>`: текст после фразы считается raw request для preflight.
- Перед `prompts/create-new-project.md` для любого raw request про сайт.
- Перед scaffold, чтобы не выбрать стек при `low` или `blocker`.
- Перед handoff, чтобы зафиксировать site audit command для dev/staging URL.
- В Claude Code и Codex skills как первый executable preflight.

## Команды

```powershell
pwsh D:\Work\llm-dev-wiki\tools\new-site-preflight.ps1 -Request "Хочу SaaS с подписками"
pwsh D:\Work\llm-dev-wiki\tools\new-site-preflight.ps1 -Request "<описание сайта после фразы 'Я хочу создать сайт'>"
pwsh D:\Work\llm-dev-wiki\tools\new-site-preflight.ps1 -Request "Нужен лендинг с SEO и формой" -Url http://localhost:3000 -Routes /pricing,/contact
pwsh D:\Work\llm-dev-wiki\tools\new-site-preflight.ps1 -Request "Сделай сайт" -FailOnLowConfidence
```

## Output contract

- `status`: `ready` или `needs-discovery`.
- `confidence`: значение из stack router.
- `routeMode`: `direct` или `full-pipeline`.
- `routeReasons`: сработавшие критерии маршрута.
- `recommendedPlaybook`, `recommendedDeliveryProfile`, `supportingGuides`.
- `recommendedRoute` и `recommendedStack` — человекочитаемое объяснение решения.
- `openQuestions`, `assumptions`, `rejectedAlternatives`, `acceptanceGates`.
- `requiredWikiDocs`: документы, которые агент обязан прочитать перед coding.
- `siteAuditCommand`: команда для handoff/release smoke; не запускается автоматически.

## Правила

- При `needs-discovery` не scaffolding: сначала задать вопросы из результата.
- При `direct` не создавать `_pipeline-status.md`; выполнить только применимые legal, visual и verification gates.
- `full-pipeline` выбирать для сложного нового сайта с auth/ролями, CMS/сложными данными, платежами,
  серверными интеграциями, миграциями, несколькими пользовательскими контурами или явным полным циклом.
- При `blocker` не начинать код до security/compliance discovery.
- Wrapper не должен дублировать routing rules из `site-stack-router.ps1`.
- Shopify/Hydrogen выбирается только по явному положительному ограничению; слова «каталог» и
  «товар» сами по себе не являются платформенным сигналом, отрицания учитываются.
- Site audit запускается отдельно, потому что Lighthouse через `npx --yes lighthouse` является network/supply-chain шагом.

## Проверка

Tool покрыт `tests/tools/test_new_site_preflight.py` и входит в `python -m pytest tests/tools`.

## Источники

- [Site stack router tool](site-stack-router-tool.md)
- [Site architecture decision router](site-architecture-decision-router.md)
- [Site audit project command](../10-templates/site-audit-project-command.md)
