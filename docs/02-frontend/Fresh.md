---
title: "Fresh"
category: "frontend"
updated: "2026-07-21"
status: "active"
tags: ["fresh", "deno", "islands", "frontend"]
source_priority: "official-docs"
---

# Fresh

Fresh — Deno full-stack framework with server-side rendering and islands of interactivity. В wiki это специализированный вариант для Deno/edge проектов, не default для Node/React teams.

Fresh `2.3.3` проверен как latest stable 2026-07-21. Patch release не меняет архитектурную рекомендацию: Deno/runtime compatibility и deploy smoke остаются обязательными.

## Когда использовать

- Команда осознанно выбирает Deno runtime and permissions model.
- Нужен SSR site with small interactive islands.
- Проект деплоится на Deno Deploy или совместимое окружение.
- Важны простая server rendering модель и low client JavaScript.

## Когда не использовать

- Команда стандартизирована на Node/npm/Next/Vite.
- Нужны React ecosystem packages or Node-only libraries.
- Требуется mature enterprise ecosystem, hiring pool or vendor integrations.
- Static content site проще сделать на Astro.

## Production-паттерны

- Islands используются только для интерактива; основной контент рендерится на сервере.
- Runtime permissions, secrets and deploy target фиксируются в проектном blueprint.
- External APIs and database clients проверяются на Deno compatibility.
- Routes, handlers and middleware share error/security conventions.
- Static assets and images have explicit cache and optimization strategy.

## Частые ошибки

- Предполагать Node compatibility without testing.
- Делать каждую секцию island and lose simplicity.
- Не проверять deploy target until release.
- Игнорировать Deno permission/security model.

## Security risks

Permissions, environment secrets, server handlers auth, CSRF and user input sanitization must be reviewed like any server-rendered app.

## Performance risks

Islands still ship JavaScript. Slow external API calls, images and third-party tags dominate if not measured.

## Testing strategy

Deno checks/tests, route smoke, island interactivity tests, SSR metadata check, Lighthouse for public pages, deploy preview validation.

## Edge cases

Deno/npm compatibility, import maps, deploy region, islands hydration mismatch, file upload support, adapter/runtime API drift.

## Источники

- [Fresh Docs](https://fresh.deno.dev/docs/introduction)
- [Deno Fresh Tutorial](https://docs.deno.com/examples/fresh_tutorial/)
- См. [Runtime selection](../01-development-process/runtime-selection.md), [Performance](Performance.md), [Astro](Astro.md).
