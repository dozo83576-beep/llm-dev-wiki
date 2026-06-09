---
title: "SolidStart"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["solid", "solidstart", "fullstack", "performance"]
source_priority: "official-docs"
---

# SolidStart

SolidStart — full-stack framework для SolidJS. Это niche-вариант для команд, которые осознанно выбирают fine-grained reactivity and smaller runtime вместо React ecosystem.

## Когда использовать

- Команда уже владеет SolidJS или готова инвестировать в него.
- Performance/runtime size критичны, а React ecosystem не является требованием.
- Нужны Solid routing, SSR and deploy adapters.
- Проект не зависит от shadcn/ui, React-only SDKs or React hiring pool.

## Когда не использовать

- Типовой SaaS/commerce/dashboard, где React/Next ecosystem ускорит delivery.
- Команда не готова к меньшему ecosystem and hiring pool.
- Нужны React-only component libraries, auth widgets, analytics SDKs.
- Требуется самый консервативный production default.

## Production-паттерны

- Проверяй availability SDKs/components до выбора стека.
- SSR/deploy adapter тестируется early.
- Design system строится на Solid-compatible primitives.
- Data fetching, auth and forms фиксируются в project blueprint.
- Performance decision должен иметь measured budget, а не taste-based аргумент.

## Частые ошибки

- Выбирать SolidStart только ради benchmark.
- Недооценить ecosystem gap для UI libraries and third-party integrations.
- Нет fallback strategy, если нужный SDK React-only.
- Нечёткие boundaries между server/client code.

## Проверка

Проверь SSR, hydration, routes, forms, auth integration, component library compatibility, bundle size and site audit.

## Источники

- [SolidStart Docs](https://start.solidjs.com/)
- [SolidJS](https://www.solidjs.com/)
- См. [Frontend blueprints](Frontend-blueprints.md), [Performance](Performance.md), [Vike](Vike.md).
