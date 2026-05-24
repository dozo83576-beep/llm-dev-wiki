---
title: "Unit testing"
category: "testing"
updated: "2026-05-24"
status: "active"
tags: ["unit-tests", "testing"]
source_priority: "internal"
---

# Unit testing

Unit-тесты — фундамент пирамиды. Они проверяют чистую логику изолированно, выполняются за миллисекунды и являются основным каналом отлова регрессий в коде, где нет внешних зависимостей.

## Когда использовать

- Чистая бизнес-логика (pricing, validators, mappers, calculators).
- State reducers / store slices.
- Permission / authorization rules как функции.
- Edge cases с понятной математикой / правилами.
- Парсеры / форматтеры / time-zone утилиты.

## Когда не использовать

- Тестирование getter/setter без логики — пустые тесты.
- Code, где основная сложность — взаимодействие с БД (это integration).
- UI rendering — это component test, не unit.

## Production-паттерны

- **Arrange / Act / Assert**: явная структура, тест читается как сценарий.
- **One behavior per test** — один assert на одно поведение.
- **Detirministic**: frozen time, seeded random, нет сети, нет файловой системы.
- **Fast**: < 100ms на тест; вся suite — секунды.
- **Naming**: `describe("calculatePrice")` → `it("applies discount when quantity > 10")`.
- **Coverage-aware**: target 80%+ на critical logic, не охота на 100% per se.
- **Mutation testing** (Stryker) для критичных модулей — проверяет, что тесты реально ловят регрессии.

## Частые ошибки

- Тестировать private методы напрямую — переписывание ломает все тесты.
- Использовать реальные `Date.now()` / `Math.random()` — flaky.
- Один тест проверяет 5 вещей через 5 assert'ов — при падении непонятно, что сломалось.
- Mocking внутренних модулей — теряется ценность теста.
- Snapshot-тесты на 200 строк JSON — никто их не ревьюит, обновляются "вслепую".

## Performance risks

Медленные unit-тесты (синхронные IO, тяжёлые setup) — разрушают feedback loop. Параллельный run должен быть безопасным (нет shared state).

## Testing strategy

- TDD для критичной логики (pricing, permission).
- Поведенческое именование, не имплементационное.
- Mutation testing на критичные модули перед major release.
- Coverage gate в CI: не падать ниже baseline.

## Инструменты

- **JS/TS**: Vitest (рекомендуется для Vite-проектов), Jest, node:test для библиотек.
- **Python**: pytest + pytest-cov + pytest-mock.
- **Go**: стандартный `testing` + `testify`.

## Edge cases

- Floating-point comparisons — `expect().toBeCloseTo()`.
- Async ошибки — `await expect(...).rejects.toThrow()`.
- Тесты, использующие `setTimeout` — fake timers, не реальное ожидание.

## Источники

- [Vitest Docs](https://vitest.dev/) — проверено 2026-05-24.
- [pytest Docs](https://docs.pytest.org/) — проверено 2026-05-24.
- См. [Test pyramid](Test-pyramid.md), [Mocks](Mocks.md), [Fixtures](Fixtures.md).
