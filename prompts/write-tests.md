---
title: "Prompt: write tests"
category: "prompt"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["testing", "qa"]
source_priority: "internal"
---

# Prompt: write tests

## Role

Engineer, пишущий тесты для существующего изменения по [test pyramid](../docs/09-testing/Test-pyramid.md).

## Context

Изменение реализовано (или почти). Нужны тесты, покрывающие happy path, ошибки, граничные случаи, race conditions. Уровень тестов выбирается по природе кода, не по привычке "всё через E2E".

## Inputs

- `{{diff}}` — diff или ссылка на PR.
- `{{component_type}}` — pure function / service / API / UI / job.
- `{{existing_tests}}` — что уже покрыто.
- `{{test_stack}}` — Vitest / Jest / pytest / Playwright.

## Steps

1. **Classify**: какой уровень нужен — unit / integration / E2E / component / contract.
2. **List cases**: happy path, validation errors, permission denied, not found, conflict, external dep failure, race/double submit, edge cases (empty, max length, unicode, edge numeric).
3. **Pick fixtures**: factory functions / MSW handlers / DB seed.
4. **Write tests** в выбранном фреймворке.
5. **Run** локально — все зелёные.
6. **Coverage check**: новая логика покрыта (gap → объяснить почему OK или добавить тест).
7. **Naming**: `describe("<unit>")` → `it("<behavior> when <condition>")`.

## Output schema

```
## Level chosen + why

## Cases
- happy: ...
- validation: ...
- permission: ...
- not found: ...
- conflict / race: ...
- external failure: ...
- edge: ...

## Code

```language
// test files content
```

## Coverage delta
- Lines added: ...
- Uncovered intentionally: ...
```

## Refusal rules

- Не покрывать private реализации напрямую — тестируй behavior.
- Не использовать `sleep()` / реальный `Date.now()` — frozen clock, polling.
- Не зависеть от порядка тестов / shared state.
- Не делать snapshot тесты на огромные blob'ы.
- Если уровень тест-стенда не позволяет integration test (нет docker), отметь как блокер, не подделывай моком.

## Related

- [Test pyramid](../docs/09-testing/Test-pyramid.md)
- [Unit testing](../docs/09-testing/Unit-testing.md)
- [Integration testing](../docs/09-testing/Integration-testing.md)
- [E2E testing](../docs/09-testing/E2E-testing.md)
- [Fixtures](../docs/09-testing/Fixtures.md)
