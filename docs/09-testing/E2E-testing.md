---
title: "E2E testing"
category: "testing"
updated: "2026-05-24"
status: "active"
tags: ["e2e", "playwright"]
source_priority: "official-docs"
---

# E2E testing

E2E-тесты проверяют критичные пользовательские пути целиком: реальный браузер, реальный backend, реальная БД. Они дорогие (медленные, flaky), поэтому покрывают только то, что нельзя проверить дешевле.

## Когда использовать

- Критичные user-journey: signup, login, checkout, create/edit/delete основного объекта, permission boundary.
- Smoke-тесты после production deploy.
- Регрессионные сценарии после реальных инцидентов.

## Когда не использовать

- Покрытие бизнес-логики — это unit/integration уровень.
- Проверка вариантов одного компонента — это component-tests.
- "Тест по любому поводу" — suite станет медленной и flaky.

## Production-паттерны

- [Playwright](Playwright.md) или **Cypress** как основные инструменты; Playwright предпочтительнее для multi-browser и parallel.
- Тесты пишутся под user-journey, а не под endpoint.
- Test data isolation: каждый тест создаёт свои данные, не зависит от seed.
- Authentication: единоразовый login → reuse storage state, не login в каждом тесте.
- Network: реальные backend-вызовы, только сторонние сервисы мокаем (Stripe sandbox / MSW).
- Параллельный run в CI с разделением shard'ов.
- Артефакты: screenshots / video / trace на каждый fail, retention 7–14 дней.

## Частые ошибки

- Жёсткие waits (`waitForTimeout(2000)`) вместо `waitFor` по условию.
- Зависимость тестов друг от друга (`test1` создаёт user, `test2` ожидает его).
- Локаторы по CSS / тексту без data-testid — ломаются при ребрендинге.
- Run против shared staging без изоляции данных — flaky.
- Считать pass/fail по последнему run без анализа flakiness rate.

## Security risks

Тестовые credentials с production-правами, test data с реальным PII, leak'и screenshots с чувствительной информацией в артефактах CI.

## Performance risks

Suite > 30 мин блокирует CI; нестабильные тесты приучают команду игнорировать красное.

## Testing strategy

- Smoke pack: 5–10 тестов, < 5 мин, прогон после каждого deploy.
- Regression pack: 30–80 тестов, < 30 мин, прогон на main.
- Cross-browser smoke на релизы.
- Flakiness budget: > 1% — починить или удалить тест.

## Edge cases

- Multi-tenant: cleanup между запусками, изоляция tenant.
- File uploads / downloads — особенности Playwright API.
- iframe / OAuth-popup сценарии.
- Service workers / push notifications.

## Источники

- [Playwright](Playwright.md), [Playwright Docs](https://playwright.dev/) — проверено 2026-05-24.
- [Cypress Best Practices](https://docs.cypress.io/guides/references/best-practices) — проверено 2026-05-24.
- См. [Frontend testing](../02-frontend/Frontend-testing.md), [Test pyramid](Test-pyramid.md), [Visual testing](Visual-testing.md).
