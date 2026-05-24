---
title: "Pattern: Form validation boundary"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["frontend", "forms", "validation"]
---

# Form validation boundary

Форма должна валидироваться на клиенте для UX и на сервере для безопасности.

## Когда использовать

Любая форма, которая меняет данные, создает аккаунт, отправляет платеж или вызывает API.

## Когда не использовать

Не делай тяжелую client validation для read-only фильтра, если сервер все равно безопасно нормализует запрос.

## Production-паттерны

Единая schema, client-side feedback, server-side enforcement, disabled/loading states, защита от double submit.

## Частые ошибки

- Верить client validation.
- Не отображать server validation errors.
- Отправлять форму повторно при медленном ответе.

## Проверка

Unit tests для schema, integration tests для server validation, E2E для happy/error states.

Источники: [[../../docs/02-frontend/Forms-validation|Forms and validation]].

