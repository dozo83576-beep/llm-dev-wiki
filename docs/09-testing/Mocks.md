---
title: "Mocks"
category: "testing"
updated: "2026-05-24"
status: "active"
tags: ["mocks", "testing"]
source_priority: "internal"
---

# Mocks

Mocks полезны для внешних сервисов, времени, случайности и дорогих зависимостей. Мок доменной логики часто скрывает баги.

## Правила

- Mock external boundary, not internal behavior.
- Для API-контрактов используй contract tests или MSW.
- Проверяй failure modes: timeout, 429, 500, invalid payload.

