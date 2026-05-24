---
title: "Frontend review checklist"
category: "checklist"
updated: "2026-05-24"
status: "active"
tags: ["frontend", "review", "react"]
source_priority: "internal"
---

# Frontend review checklist

Gated checklist для frontend-фичи или UI-страницы. Формат: критерий — проверка — owner — severity — ссылка.

## Rendering strategy

- [ ] **Server / Client component** выбор обоснован: client только если нужна интерактивность — frontend owner — block — [server-client-boundary pattern](../patterns/frontend/server-client-boundary.md).
- [ ] **SSR / SSG / ISR** соответствует природе данных — frontend owner — warn — [Nextjs](../docs/02-frontend/Nextjs.md).
- [ ] **Data fetching** на сервере где возможно; client fetch только для интерактивного UI — frontend owner — warn — [Data fetching](../docs/02-frontend/Data-fetching.md).

## Forms

- [ ] **Все state** покрыты: loading / error / success / disabled / empty — frontend owner — block — [Forms validation](../docs/02-frontend/Forms-validation.md).
- [ ] **Валидация на клиенте и сервере** (одна zod-схема предпочтительно) — backend + frontend — block — [form-validation-boundary pattern](../patterns/frontend/form-validation-boundary.md).
- [ ] **Error messages** связаны с полями (`aria-describedby`) — frontend owner — block — [Accessibility](../docs/02-frontend/Accessibility.md).
- [ ] **Optimistic UI** для критичных write-операций где это улучшает UX — frontend owner — warn.

## Accessibility

- [ ] **Labels** на каждом input (`<label>` или `aria-label`) — frontend owner — block — [Accessibility testing](../docs/09-testing/Accessibility-testing.md).
- [ ] **Keyboard navigation** работает без мыши — frontend owner — block.
- [ ] **Focus visible** не отключён — frontend owner — block.
- [ ] **Color contrast** ≥ 4.5:1 для текста — frontend owner — block.
- [ ] **axe-core** scan без critical violations — frontend owner — warn.

## Responsive & visual

- [ ] **Mobile-first** проверен на 360px width — frontend owner — block.
- [ ] **Text overflow** не ломает layout — frontend owner — block.
- [ ] **Dark / light theme** (если есть) — оба покрыты — frontend owner — warn.
- [ ] **Long content** (длинные имена, многоязычные строки) не выходит за контейнеры — frontend owner — warn.

## Performance

- [ ] **LCP < 2.5s, CLS < 0.1, INP < 200ms** на критичных страницах (Lighthouse) — frontend owner — block — [Performance](../docs/02-frontend/Performance.md).
- [ ] **Bundle size** не вырос без причины (CI gate на bytes) — frontend owner — warn.
- [ ] **Images optimized** (WebP/AVIF, `<Image>`/`<picture>`) — frontend owner — warn.
- [ ] **Heavy libraries** оправданы (нет moment.js / lodash целиком) — frontend owner — warn.

## Security

- [ ] **Нет секретов** в client bundle (`NEXT_PUBLIC_*` без credentials) — security owner — block — [Secrets](../docs/05-auth-security/Secrets.md).
- [ ] **User input** sanitized перед рендером (XSS-protection) — frontend owner — block.
- [ ] **CSP** совместим с используемыми ресурсами — frontend owner — warn — [CORS-CSRF-CSP](../docs/05-auth-security/CORS-CSRF-CSP.md).
- [ ] **External links** имеют `rel="noopener noreferrer"` для `target="_blank"` — frontend owner — warn.

## Tests

- [ ] **Critical user-journey** покрыт Playwright или ручным smoke — QA — block — [E2E testing](../docs/09-testing/E2E-testing.md).
- [ ] **Component tests** для сложных интерактивных компонентов — frontend owner — warn — [Frontend testing](../docs/02-frontend/Frontend-testing.md).
- [ ] **Visual regression** для дизайн-системы и hero pages — frontend owner — warn — [Visual testing](../docs/09-testing/Visual-testing.md).
