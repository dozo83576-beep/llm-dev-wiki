---
title: "TypeScript"
category: "frontend"
updated: "2026-07-21"
reviewed: "2026-07-21"
status: "active"
tags: ["typescript"]
source_priority: "official-docs"
---

# TypeScript

TypeScript обязателен для production frontend/backend на JavaScript-экосистеме. Цель: ловить ошибки контрактов до runtime.

**Версионное решение:** latest stable изучен на `7.0.2`, но production baseline для новых проектов остаётся `6.0.3`. TypeScript 7 использует native Go compiler и заметно ускоряет проверку/сборку, однако в 7.0 отсутствует compiler API. Инструменты, которые встраивают TypeScript — Angular, Vue, Astro, Svelte, MDX и часть lint/build плагинов — требуют отдельной проверки совместимости.

Для migration smoke запускай TypeScript 7 рядом с TypeScript 6 (`@typescript/typescript6`), а не заменяй baseline глобально. Сравни diagnostics/build output и проверь editor service, ESLint, framework compiler, codegen и библиотеки, использующие compiler API. Перевод конкретного production-проекта разрешён только после такого smoke и плана отката.

Правила: `strict: true`, явные типы на публичных API, вывод типов внутри функций, Zod/Valibot для runtime validation, запрет широкого `any` без локального обоснования.

Источники: [TypeScript Docs](https://www.typescriptlang.org/docs/) и [Announcing TypeScript 7.0](https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/) — проверено 2026-07-21.

## Когда использовать

Используй TypeScript во всех production web-проектах на JavaScript-стеке: frontend, backend, scripts, shared contracts.

## Когда не использовать

Не отключай строгие проверки ради скорости. Для одноразового throwaway script можно упростить типы, но не переносить этот стиль в приложение.

## Production-паттерны

`strict: true`, typed public interfaces, inferred local types, runtime validation на IO boundaries, discriminated unions для состояний и ошибок.

## Частые ошибки

`any` на границе API, type assertions вместо validation, нестрогий tsconfig, дублирование типов между frontend/backend без генерации или shared package.

## Проверка

`tsc --noEmit`, type-level coverage для публичных contracts, negative tests для runtime validation. При оценке TypeScript 7 повтори build/typecheck на 6.0.3 и 7.0.2 и зафиксируй несовместимости framework/tooling до смены baseline.

