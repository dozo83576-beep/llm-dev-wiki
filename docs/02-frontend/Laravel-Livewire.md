---
title: "Laravel Livewire"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["laravel", "livewire", "php", "hypermedia"]
source_priority: "official-docs"
---

# Laravel Livewire

Laravel Livewire — full-stack UI layer для Laravel: dynamic interfaces без отдельной SPA, с server-owned state and PHP-first development.

## Когда использовать

- Команда сильна в Laravel/PHP и хочет CRUD/admin/internal tools быстрее, чем React SPA.
- UI строится вокруг forms, tables, filters, modals and server validation.
- SEO не требует отдельного React/Vue app, а server-rendered pages достаточно.
- Нужны Laravel auth, policies, queues, notifications, Eloquent and Blade ecosystem.

## Когда не использовать

- Нужен rich offline/client-heavy UI, complex canvas/editor, realtime collaboration.
- Команда стандартизирована на TypeScript frontend and shared component system.
- Требуется mobile/web shared UI.
- Backend не Laravel.

## Production-паттерны

- State ownership остаётся на сервере; browser хранит минимум transient state.
- Laravel policies/authorization проверяются на server action, не только в template.
- Components дробятся по use-case, а не становятся “god component”.
- Validation и error state используют Laravel validation rules.
- Expensive lists требуют pagination, debounced filters and query optimization.

## Частые ошибки

- Строить Livewire как SPA replacement для сложного frontend domain.
- Забывать authorization в component actions.
- Не тестировать race между form submit, validation and redirects.
- Перегружать страницу мелкими Livewire requests без performance budget.

## Проверка

Проверь form validation, permission denied, pagination/filter URLs, file uploads, optimistic UI expectations, loading/error states, database queries and browser smoke.

## Источники

- [Laravel Livewire Docs](https://livewire.laravel.com/)
- [Laravel Docs](https://laravel.com/docs)
- См. [htmx](HTMX.md), [Forms validation](Forms-validation.md), [Laravel stack](../../stacks/laravel.md).
