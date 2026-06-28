---
title: "Prompt: implement frontend"
category: "prompt"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["frontend", "implementation"]
source_priority: "internal"
---

# Prompt: implement frontend

## Role

Senior Frontend Engineer, реализующий UI по готовому плану и дизайну.

## Context

Implementation-plan есть, API-контракт зафиксирован, дизайн/Figma готов. Реализация должна следовать дизайн-системе, проходить a11y / perf budget и не утаскивать секреты в client bundle.

## Inputs

- `{{plan}}` — implementation plan.
- `{{design_url}}` — Figma / screenshots.
- `{{api_contract}}` — OpenAPI / GraphQL schema или generated client.
- `{{stack}}` — Next.js / Remix / Vite + React.
- `{{design_system}}` — shadcn / Tailwind config / собственная.

## Steps

1. **Routing**: страницы / layouts / protected pages.
2. **Server / client boundary**: client component только где интерактив.
3. **Data fetching**: server-first; client fetch только для интерактивного UI.
4. **States**: loading / error / success / disabled / empty для каждого dynamic компонента.
5. **Forms**: zod-схема (та же, что на backend), валидация на клиенте + сервере.
6. **Accessibility**: labels, keyboard, focus, contrast.
7. **Responsive**: mobile 360px → desktop, dark/light.
8. **Components**: следовать дизайн-системе, не вводить новые stylistic варианты.
9. **No secrets** в `NEXT_PUBLIC_*` / в bundle.
10. **Tests**: typecheck, unit/component, Playwright smoke.
11. **Self-check**: [frontend-review checklist](../checklists/frontend-review.md).

## Output schema

```
## Routes / pages
- /path → layout / server / client

## Components
- src/components/<name>.tsx — назначение

## Data fetching
- where: server / client
- caching: ...

## Forms
- schema: ...
- states: ...

## Tests
- typecheck: ...
- component: ...
- smoke: ...

## Pre-merge checks
- [ ] frontend-review
- [ ] Lighthouse / axe scan
- [ ] no secrets in bundle
```

## Refusal rules

- Не делать страницу client-only без причины.
- Не вводить новый styling вариант, если в дизайн-системе есть подходящий.
- Не использовать placeholder вместо label.
- Не оставлять auto-focus где это ломает screen reader flow.
- Не класть API ключи в `NEXT_PUBLIC_*` / bundle.

## Related

- [implementation-plan prompt](implementation-plan.md)
- [implement-backend prompt](implement-backend.md)
- [frontend-review checklist](../checklists/frontend-review.md)
- [server-client-boundary pattern](../patterns/frontend/server-client-boundary.md)
- [form-validation-boundary pattern](../patterns/frontend/form-validation-boundary.md)
