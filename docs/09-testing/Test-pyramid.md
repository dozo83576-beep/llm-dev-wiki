---
title: "Test pyramid"
category: "testing"
updated: "2026-05-24"
status: "active"
tags: ["test-strategy"]
source_priority: "internal"
---

# Test pyramid

Тесты должны соответствовать риску. Много быстрых unit tests, меньше integration tests, еще меньше E2E tests на критичные пути.

## Правила

- Unit: чистая логика и permissions.
- Integration: API + DB + external adapters.
- E2E: user journeys и production smoke.
- Contract: границы между frontend/backend/external clients.

Анти-паттерн: покрывать все E2E-тестами и получить медленную нестабильную suite.

