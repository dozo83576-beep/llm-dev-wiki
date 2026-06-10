---
title: "Lesson: Lighthouse EPERM на Windows при site-audit"
category: "lesson"
updated: "2026-06-11"
status: "active"
tags: ["lighthouse", "site-audit", "windows", "chrome-launcher", "testing"]
source_priority: "internal"
date: "2026-06-11"
project_type: "content-site"
---

# Lesson: Lighthouse EPERM на Windows при site-audit

## TL;DR

Если `site-audit.ps1` падает на Windows с `EPERM` при удалении временной папки `lighthouse.*`, это может быть сбой `chrome-launcher` cleanup, а не дефект сайта. В таком случае отдельно прогоняй `-SkipLighthouse -FailOnMedium` и документируй, что полный Lighthouse перенесён на другую среду.

## Контекст

При handoff CMS/content site на Next.js + Payload полный `site-audit.ps1` запускал Lighthouse через pinned package, но падал на cleanup временной директории. Повтор с `TEMP`/`TMP` внутри проекта дал тот же симптом.

## Что произошло

Security headers и public routes работали, build/test/lint проходили, Playwright smoke проходил. Полный audit завершался ошибкой вида `EPERM, Permission denied: ... lighthouse.<id>` в `chrome-launcher.destroyTmp`.

## Корень

Ошибка возникала после работы Chrome/Lighthouse на этапе удаления временной папки. Смена временной директории не устранила проблему, значит это environment/tooling blocker, а не достаточное доказательство проблемы сайта.

## Новое правило

Когда полный `site-audit.ps1` падает на Windows с `chrome-launcher` cleanup `EPERM` → запусти `pwsh tools/site-audit.ps1 -Url <url> -SkipLighthouse -FailOnMedium`, сохрани результат headers smoke и перенеси полный Lighthouse на staging, другую машину или CI-среду с устойчивым Chrome.

## Применимость

Работает для локального Windows handoff, где Lighthouse не успевает корректно очистить temp-профиль. Не применяй как excuse для пропуска Lighthouse перед production: это documented exception, а не замена performance/a11y/SEO проверки.

## Обновлённые документы

- [docs/09-testing/Site-audit-tooling.md](../docs/09-testing/Site-audit-tooling.md) — добавлен troubleshooting для Windows EPERM.
- [case-studies/successes/2026-06-11-accounting-legal-cms.md](../case-studies/successes/2026-06-11-accounting-legal-cms.md) — зафиксирован проверенный handoff flow.

## Ссылки

- [Site audit tooling](../docs/09-testing/Site-audit-tooling.md)
- [Security testing](../docs/09-testing/Security-testing.md)
