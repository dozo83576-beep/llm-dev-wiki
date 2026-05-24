---
title: "Fixtures"
category: "testing"
updated: "2026-05-24"
status: "active"
tags: ["fixtures", "test-data"]
source_priority: "internal"
---

# Fixtures

Fixtures должны создавать минимальные данные для конкретного теста.

## Production-паттерны

- Factory functions с явными overrides.
- Отдельные tenants/users/roles для permission tests.
- Cleanup после тестов.
- Нет production PII.

## Частые ошибки

- Один общий fixture на все тесты.
- Скрытые зависимости между тестами.
- Случайные даты и non-deterministic ids без причины.

