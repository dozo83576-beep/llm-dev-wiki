---
title: "TypeScript"
category: "frontend"
updated: "2026-05-24"
status: "active"
tags: ["typescript"]
source_priority: "official-docs"
---

# TypeScript

TypeScript обязателен для production frontend/backend на JavaScript-экосистеме. Цель: ловить ошибки контрактов до runtime.

Правила: `strict: true`, явные типы на публичных API, вывод типов внутри функций, Zod/Valibot для runtime validation, запрет широкого `any` без локального обоснования.

Источник: [TypeScript Docs](https://www.typescriptlang.org/docs/).

## Когда использовать

Используй TypeScript во всех production web-проектах на JavaScript-стеке: frontend, backend, scripts, shared contracts.

## Когда не использовать

Не отключай строгие проверки ради скорости. Для одноразового throwaway script можно упростить типы, но не переносить этот стиль в приложение.

## Production-паттерны

`strict: true`, typed public interfaces, inferred local types, runtime validation на IO boundaries, discriminated unions для состояний и ошибок.

## Частые ошибки

`any` на границе API, type assertions вместо validation, нестрогий tsconfig, дублирование типов между frontend/backend без генерации или shared package.

## Проверка

`tsc --noEmit`, type-level coverage для публичных contracts, negative tests для runtime validation.

