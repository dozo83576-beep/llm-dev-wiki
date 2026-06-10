---
title: "Site audit project command"
category: "templates"
updated: "2026-06-10"
status: "active"
tags: ["site-audit", "template", "handoff"]
source_priority: "internal"
---

# Site audit project command

Шаблон подключения lightweight site audit в проекты из `D:\Work`. Команда не меняет сайт: она читает URL, проверяет headers and Lighthouse, пишет local-only reports. Lighthouse закреплён как `lighthouse@13.4.0`; обновление версии делать отдельным review.

## New site preflight

Перед созданием проекта проверь сырой запрос и сразу получи команду handoff-аудита:

```powershell
pwsh D:\Work\llm-dev-wiki\tools\new-site-preflight.ps1 -Request "Хочу SaaS с подписками" -Url http://localhost:3000 -OutputJson
```

Если confidence `low` или `blocker`, не начинай генерацию проекта: сначала задай вопросы из `openQuestions`.

## PowerShell handoff

```powershell
pwsh D:\Work\llm-dev-wiki\tools\site-audit.ps1 -Url http://localhost:3000
```

Для быстрого security headers smoke без Lighthouse:

```powershell
pwsh D:\Work\llm-dev-wiki\tools\site-audit.ps1 -Url http://localhost:3000 -SkipLighthouse -FailOnMedium
```

## package.json script

Для новых JS/TS сайтов добавляй этот script при scaffold:

```json
{
  "scripts": {
    "audit:site": "pwsh D:\\Work\\llm-dev-wiki\\tools\\site-audit.ps1 -Url http://localhost:3000"
  }
}
```

Если порт меняется, не hardcode production URL. Передай URL через project-local wrapper или README команду.
Если у проекта нет `package.json`, добавь эквивалентную команду в README или Makefile.

## Release/handoff rule

- Public routes: запускать полный audit перед handoff.
- Preview/staging: добавлять `-Routes /pricing,/checkout,/login,/contact` для ключевых страниц.
- CI smoke: использовать `-SkipLighthouse -FailOnMedium`, чтобы не запускать браузер.
- Reports `site-audit-report.*` и `lighthouse-*` не коммитить.

## Источники

- См. [Site audit tooling](../09-testing/Site-audit-tooling.md), [Frontend review checklist](../../checklists/frontend-review.md), [Release readiness](../../checklists/release-readiness.md).
