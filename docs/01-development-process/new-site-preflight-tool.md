---
title: "New site preflight tool"
category: "process"
updated: "2026-06-10"
status: "active"
tags: ["site", "preflight", "stack", "audit"]
source_priority: "internal"
---

# New site preflight tool

`tools/new-site-preflight.ps1` — единая offline-команда перед созданием сайта. Она запускает rule-based stack router, возвращает confidence, docs to read и готовую команду `site-audit.ps1` для handoff. Скрипт не использует LLM/API, не ходит в сеть, не запускает Lighthouse и не меняет проект.

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
- `recommendedRoute` и `recommendedStack`.
- `openQuestions`, `assumptions`, `rejectedAlternatives`, `acceptanceGates`.
- `requiredWikiDocs`: документы, которые агент обязан прочитать перед coding.
- `siteAuditCommand`: команда для handoff/release smoke; не запускается автоматически.

## Правила

- При `needs-discovery` не scaffolding: сначала задать вопросы из результата.
- При `blocker` не начинать код до security/compliance discovery.
- Wrapper не должен дублировать routing rules из `site-stack-router.ps1`.
- Site audit запускается отдельно, потому что Lighthouse через `npx --yes lighthouse` является network/supply-chain шагом.

## Проверка

Tool покрыт `tests/tools/test_new_site_preflight.py` и входит в `python -m pytest tests/tools`.

## Источники

- [Site stack router tool](site-stack-router-tool.md)
- [Site architecture decision router](site-architecture-decision-router.md)
- [Site audit project command](../10-templates/site-audit-project-command.md)
