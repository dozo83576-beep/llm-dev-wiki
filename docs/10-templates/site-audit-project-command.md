---
title: "Site audit project command"
category: "templates"
updated: "2026-06-10"
status: "active"
tags: ["site-audit", "template", "handoff"]
source_priority: "internal"
---

# Site audit project command

Шаблон подключения lightweight site audit в проекты из `D:\Work`. Команда не меняет сайт: она читает URL, проверяет headers and Lighthouse, пишет local-only reports.

## PowerShell handoff

```powershell
pwsh D:\Work\llm-dev-wiki\tools\site-audit.ps1 -Url http://localhost:3000
```

Для быстрого security headers smoke без Lighthouse:

```powershell
pwsh D:\Work\llm-dev-wiki\tools\site-audit.ps1 -Url http://localhost:3000 -SkipLighthouse -FailOnMedium
```

## package.json script

```json
{
  "scripts": {
    "audit:site": "pwsh D:\\Work\\llm-dev-wiki\\tools\\site-audit.ps1 -Url http://localhost:3000"
  }
}
```

Если порт меняется, не hardcode production URL. Передай URL через project-local wrapper или README команду.

## Release/handoff rule

- Public routes: запускать полный audit перед handoff.
- Preview/staging: добавлять `-Routes /pricing,/checkout,/login,/contact` для ключевых страниц.
- CI smoke: использовать `-SkipLighthouse -FailOnMedium`, чтобы не запускать браузер.
- Reports `site-audit-report.*` и `lighthouse-*` не коммитить.

## Источники

- См. [Site audit tooling](../09-testing/Site-audit-tooling.md), [Frontend review checklist](../../checklists/frontend-review.md), [Release readiness](../../checklists/release-readiness.md).
