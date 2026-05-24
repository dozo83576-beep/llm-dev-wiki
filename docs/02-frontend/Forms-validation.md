---
title: "Forms and validation"
category: "frontend"
updated: "2026-05-24"
status: "active"
tags: ["forms", "validation"]
source_priority: "official-docs"
---

# Forms and validation

Для сложных форм используй React Hook Form + Zod. Клиентская валидация улучшает UX, но не заменяет серверную.

Правила: schema-first validation, единые сообщения ошибок, disabled/loading states, защита от double submit, серверная проверка прав и бизнес-инвариантов.

Источники: [React Hook Form Docs](https://react-hook-form.com/), [Zod Docs](https://zod.dev/).

## Когда использовать

Используй schema-based validation для signup, login, checkout, profile, CRUD, filters с shareable state и любых форм, которые меняют данные.

## Когда не использовать

Не строь тяжелую form architecture для одного простого поля поиска, если сервер безопасно нормализует ввод.

## Production-паттерны

Схема описывает границу данных, client validation улучшает UX, server validation защищает инварианты. Submit должен иметь loading state, disabled state, обработку double submit и server errors.

## Частые ошибки

Доверять клиентской валидации, не показывать server errors, терять введенные данные после ошибки, не нормализовать email/phone, не тестировать пустые и длинные значения.

## Проверка

Unit tests для schemas, integration tests для server validation, E2E для happy path, validation errors и repeated submit.

