---
title: "htmx"
category: "frontend"
updated: "2026-06-04"
status: "active"
tags: ["htmx", "hypermedia", "server-rendered", "frontend"]
source_priority: "official-docs"
---

# htmx

htmx — hypermedia-first метод: сервер отдаёт HTML fragments, а браузер обновляет части страницы без тяжёлой SPA. Это сильная альтернатива React для CRUD, admin panels и internal tools.

Если вопрос звучит как "когда htmx лучше SPA", ответ: когда UI в основном server-rendered CRUD, forms, tables and admin actions, а rich offline/client-heavy interaction не является ключевой ценностью.

## Когда использовать

- UI в основном CRUD/forms/tables/modals, а не rich client app.
- Backend уже умеет хорошо рендерить HTML: Django, Laravel, Rails, FastAPI/Jinja, NestJS templates.
- Нужны progressive enhancement, low JS, быстрые формы и простая server-side authorization.
- Команда хочет держать state на сервере и не вводить JSON API только ради UI.

## Когда не использовать

- Нужен сложный offline-first UI, canvas, heavy client editor, realtime collaboration или rich drag-and-drop.
- Frontend/backend команды требуют отдельный API contract и independent deploy.
- SEO/content site проще статически сгенерировать через Astro/Nuxt/Next.

## Production-паттерны

- Каждый htmx endpoint возвращает фрагмент с понятным ownership и server-side validation.
- Full-page fallback работает без JavaScript для ключевых форм.
- Ошибки формы возвращаются как HTML с field-level messages.
- Используй CSRF protection, auth checks and rate limits так же, как для обычных POST.
- Cache policy различает public fragments, private fragments and no-cache form responses.

## Частые ошибки

- Начать собирать скрытую SPA без явной state model.
- Возвращать разные HTML contracts из одного endpoint.
- Не иметь fallback для full page navigation.
- Доверять client attributes вместо server authorization.

## Security risks

CSRF, XSS in rendered fragments, IDOR в fragment endpoints, over-posting forms and cache leakage private HTML. Все fragment endpoints должны проходить тот же security review, что API.

## Performance risks

Много мелких fragment requests может создать waterfall. Большие server-rendered таблицы требуют pagination/filtering. Out-of-band swaps могут вызывать layout shift.

## Testing strategy

Проверяй full-page fallback, htmx fragment response, validation errors, CSRF failure, permission denied, table pagination/filtering и Playwright journeys с включенным/выключенным JavaScript для критичных paths.

## Edge cases

Browser back/forward history, scroll/focus restoration, SSE/WebSocket extension, modal deep link, stale fragment после mutation, duplicate submit.

## Источники

- [htmx Docs](https://htmx.org/docs/)
- См. [Admin dashboard playbook](../13-playbooks/admin-dashboard.md), [Django](../03-backend/Django.md), [FastAPI](../03-backend/FastAPI.md), [NestJS](../03-backend/Nestjs.md), [Forms validation](Forms-validation.md).
