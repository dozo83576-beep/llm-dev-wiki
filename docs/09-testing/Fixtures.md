---
title: "Fixtures"
category: "testing"
updated: "2026-05-24"
status: "active"
tags: ["fixtures", "test-data", "factories"]
source_priority: "internal"
---

# Fixtures

Fixtures — это входные данные тестов. Они должны делать тест читабельным ("какие данные → какое поведение") и не превращаться в скрытый глобальный state.

## Когда использовать

- Любой тест, требующий объект > 2–3 поля.
- Permission tests с разными ролями и tenants.
- Тесты, где важны конкретные комбинации полей (edge cases).

## Когда не использовать

- Тривиальная unit-функция, где inline-литералы понятнее.
- Snapshot-тесты с большим фикстур-blob, который никто не ревьюит.

## Подходы

- **Factory functions** (`buildUser({ role: "admin" })`) — лучший вариант для большинства проектов. Прозрачные overrides, минимум магии.
- **Builders** (`new UserBuilder().withRole("admin").build()`) — для очень сложных доменных объектов.
- **Шаблонные JSON-фикстуры** — для contract / response тестов, когда нужен фиксированный snapshot.
- **DB seeds** — только для shared dev-окружения, не для unit/integration.

## Production-паттерны

- Один factory модуль на доменную сущность (`factories/user.ts`, `factories/order.ts`).
- Явные overrides перекрывают только нужные поля, остальные — sensible defaults.
- Детерминированные ids: `uuid` с seeded RNG или счётчик в рамках теста.
- Изолированные tenants/users на тест, cleanup в `afterEach`.
- Faker / faker-js с seeded random для воспроизводимости.

## Частые ошибки

- Один глобальный fixture-объект, используемый везде — изменение поля ломает 50 тестов.
- Скрытая зависимость между тестами через shared state (DB rows, in-memory cache).
- Случайные даты / ids без seed — flaky тесты.
- Загрузка production-дампа в тестовую БД — PII + не воспроизводимо.
- Фикстуры используются в production-коде (`if (NODE_ENV === "test") { ... }`).

## Security risks

PII в фикстурах (даже фейк), коммит реальных credentials в шаблоны, утечка фикстур в production seed-скрипты.

## Performance risks

Тяжёлые DB-фикстуры в integration suite — каждый тест ждёт seed. Альтернатива: transactional rollback или ephemeral schema.

## Testing strategy

- Lint factory-модулей: не используют глобальный state, не пишут в БД сами.
- Smoke-тест на factory: возвращает валидный объект, проходит schema validation.
- Coverage: factory покрыт хотя бы одним тестом, который проверяет defaults.

## Edge cases

- Полиморфные объекты (user может быть admin/customer/vendor) — отдельные factories или discriminator.
- Связанные сущности (user → orders → items) — factory компонует, не дублирует.
- Time-sensitive fixtures: явный `frozen-time` через библиотеку (sinon, vi.useFakeTimers).

## Источники

- См. [Test data](Test-data.md), [Mocks](Mocks.md), [Integration testing](Integration-testing.md).
