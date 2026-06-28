---
title: "Playwright"
category: "testing"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["playwright", "e2e", "smoke", "browser"]
source_priority: "official-docs"
---

# Playwright

Playwright — основной инструмент для browser E2E и smoke-тестов, когда нужно проверить реальный пользовательский путь. Он должен покрывать критичные flows, а не заменять unit/integration тесты.

## Когда использовать

- Login/signup, checkout, tenant switch, permission boundary, create/edit/delete ключевого объекта.
- Smoke после preview/production deploy.
- Regression test после реального UI/backend incident.

## Когда не использовать

- Проверка чистой бизнес-логики, API contracts или всех вариантов компонента.
- Массовое покрытие edge cases, которые дешевле проверить unit/integration tests.
- Тесты против production с mutating actions без отдельного safe environment.

## Production-паттерны

- Auth state создаётся один раз в setup и переиспользуется через storage state.
- Test data изолирована по worker/test run; cleanup не зависит от порядка тестов.
- Locators устойчивые: role/name или test id, без brittle CSS selectors.
- Trace/video/screenshot включены на failure и доступны из CI artifacts.
- Flaky test policy: quarantined только временно, owner и срок исправления обязательны.

## Частые ошибки

- `waitForTimeout` вместо ожидания состояния UI/API.
- Один тест создаёт данные, другой молча зависит от них.
- Скриншоты/trace содержат PII, tokens или production credentials.
- Тесты проверяют implementation details, а не user-visible behavior.

## Проверка

- Smoke pack: 5-10 тестов, login + critical path, < 5 минут.
- Regression pack: ключевые сценарии на main/preview.
- Cross-browser: минимальный smoke для релизов.
- CI artifacts: trace, screenshot и video доступны для каждого fail.

## Источники

- [Playwright Authentication](https://playwright.dev/docs/auth) — проверено 2026-05-24.
- [Playwright Trace Viewer](https://playwright.dev/docs/trace-viewer) — проверено 2026-05-24.
- [Playwright Docs](https://playwright.dev/docs/intro) — проверено 2026-05-24.
