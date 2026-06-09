---
title: "Frontend review checklist"
category: "checklist"
updated: "2026-06-10"
status: "active"
tags: ["frontend", "review", "react"]
source_priority: "internal"
---

# Frontend review checklist

Gated checklist для frontend-фичи или UI-страницы. Формат: критерий — проверка — owner — severity — ссылка.

## Rendering strategy

- [ ] **Frontend blueprint** выбран до реализации: Next.js fullstack / Astro / Vite SPA / content site — frontend owner — block — [Frontend blueprints](../docs/02-frontend/Frontend-blueprints.md).
- [ ] **Alternative stack** рассмотрен, если default Next.js/React не подходит: TanStack Start, Nuxt, SvelteKit, htmx, Cloudflare Workers — frontend owner — warn — [Stack selection](../docs/01-development-process/stack-selection.md).
- [ ] **Server / Client component** выбор обоснован: client только если нужна интерактивность — frontend owner — block — [server-client-boundary pattern](../patterns/frontend/server-client-boundary.md).
- [ ] **SSR / SSG / ISR** соответствует природе данных — frontend owner — warn — [Nextjs](../docs/02-frontend/Nextjs.md).
- [ ] **Data fetching** на сервере где возможно; client fetch/TanStack Query только для интерактивного server state — frontend owner — warn — [Data fetching](../docs/02-frontend/Data-fetching.md), [TanStack Query](../docs/02-frontend/TanStack-Query.md).
- [ ] **Route map** разделяет public / auth / app / admin / settings зоны — frontend owner — warn — [UI architecture](../docs/02-frontend/UI-architecture.md), [React Router](../docs/02-frontend/React-Router.md).

## Forms

- [ ] **Все state** покрыты: loading / error / success / disabled / empty — frontend owner — block — [Forms validation](../docs/02-frontend/Forms-validation.md).
- [ ] **Submit UX** не теряет введённые данные при server error; destructive action требует подтверждение — frontend owner — block — [Forms validation](../docs/02-frontend/Forms-validation.md).
- [ ] **Валидация на клиенте и сервере** (одна zod-схема предпочтительно) — backend + frontend — block — [form-validation-boundary pattern](../patterns/frontend/form-validation-boundary.md).
- [ ] **Error messages** связаны с полями (`aria-describedby`) — frontend owner — block — [Accessibility](../docs/02-frontend/Accessibility.md).
- [ ] **Lead form fallback** есть для ошибки serverless/notification endpoint: пользователь видит понятное сообщение и резервный канал связи — frontend owner — block — [telegram lead notification](../patterns/backend/telegram-lead-notification.md).
- [ ] **Optimistic UI** для критичных write-операций где это улучшает UX — frontend owner — warn.

## Accessibility

- [ ] **Labels** на каждом input (`<label>` или `aria-label`) — frontend owner — block — [Accessibility testing](../docs/09-testing/Accessibility-testing.md).
- [ ] **Keyboard navigation** работает без мыши — frontend owner — block.
- [ ] **Focus visible** не отключён — frontend owner — block.
- [ ] **Color contrast** ≥ 4.5:1 для текста; проверены computed colors, а не только ожидаемые CSS tokens — frontend owner — block — [Accessibility](../docs/02-frontend/Accessibility.md), [semantic text tokens](../patterns/frontend/semantic-theme-text-tokens.md).
- [ ] **axe-core** scan без critical violations — frontend owner — warn.

## Responsive & visual

- [ ] **Mobile-first** проверен на 360px width — frontend owner — block.
- [ ] **Text overflow** не ломает layout — frontend owner — block.
- [ ] **Visual hierarchy** соответствует типу экрана: hero, dashboard, table, form, pricing и checkout не используют один масштаб типографики — design owner — warn — [Design systems](../docs/02-frontend/Design-systems.md).
- [ ] **Styling system** выбран и зафиксирован: Tailwind, CSS Modules, Panda CSS или tokens-first CSS — design owner — warn — [Styling systems](../docs/02-frontend/Styling-systems.md).
- [ ] **Stable dimensions** заданы для cards, media, toolbar, counters, tables and icon buttons; hover/loading labels не двигают layout — frontend owner — warn — [UI architecture](../docs/02-frontend/UI-architecture.md).
- [ ] **Dark / light theme** (если есть) — оба покрыты; текстовые токены не протекают между светлыми и темными поверхностями — frontend owner — warn — [semantic text tokens](../patterns/frontend/semantic-theme-text-tokens.md).
- [ ] **Long content** (длинные имена, многоязычные строки) не выходит за контейнеры — frontend owner — warn.
- [ ] **Media strategy** есть для hero/product/content images: dimensions, alt, focal point, WebP/AVIF, mobile crop, video poster — frontend owner — warn — [Performance](../docs/02-frontend/Performance.md).
- [ ] **Critical sections** проверены отдельно: hero, CTA, pricing, checkout, FAQ, lead form, empty dashboard — product + frontend — warn — [Frontend blueprints](../docs/02-frontend/Frontend-blueprints.md).

## Performance

- [ ] **LCP < 2.5s, CLS < 0.1, INP < 200ms** на критичных страницах (Lighthouse) — frontend owner — block — [Performance](../docs/02-frontend/Performance.md).
- [ ] **Landing/content baseline**: Lighthouse performance ≥ 90, a11y ≥ 95, SEO ≥ 95 — frontend owner — block — [Astro](../docs/02-frontend/Astro.md), [SEO](../docs/02-frontend/SEO.md).
- [ ] **Site audit smoke** выполнен для staging/dev URL: `pwsh tools/site-audit.ps1 -Url <url>` — frontend owner — warn — [Site audit tooling](../docs/09-testing/Site-audit-tooling.md).
- [ ] **Bundle size** не вырос без причины (CI gate на bytes) — frontend owner — warn.
- [ ] **Images optimized** (WebP/AVIF, `<Image>`/`<picture>`) — frontend owner — warn.
- [ ] **Heavy libraries** оправданы (нет moment.js / lodash целиком) — frontend owner — warn.
- [ ] **Third-party scripts** измерены отдельно: analytics, chat, maps, embeds не блокируют first render — frontend owner — warn — [Performance](../docs/02-frontend/Performance.md).

## SEO & content

- [ ] **Metadata** есть для всех публичных страниц: title, description, canonical, OG image — frontend owner — block — [SEO](../docs/02-frontend/SEO.md).
- [ ] **Sitemap/robots** отражают реальные public routes; preview/search/internal pages не индексируются — frontend owner — block — [CMS content](../docs/02-frontend/CMS-content.md).
- [ ] **Structured data** соответствует видимому содержимому страницы — frontend owner — warn — [SEO](../docs/02-frontend/SEO.md).
- [ ] **Slug changes** имеют redirect map; localized pages имеют hreflang — content owner — warn — [CMS content](../docs/02-frontend/CMS-content.md), [I18n](../docs/02-frontend/I18n.md).

## Security

- [ ] **Нет секретов** в client bundle (`NEXT_PUBLIC_*` без credentials) — security owner — block — [Secrets](../docs/05-auth-security/Secrets.md).
- [ ] **User input** sanitized перед рендером (XSS-protection) — frontend owner — block.
- [ ] **CSP** совместим с используемыми ресурсами — frontend owner — warn — [CORS-CSRF-CSP](../docs/05-auth-security/CORS-CSRF-CSP.md).
- [ ] **Security headers smoke** выполнен минимум с `pwsh tools/site-audit.ps1 -Url <url> -SkipLighthouse` — frontend/devops — warn — [Site audit tooling](../docs/09-testing/Site-audit-tooling.md).
- [ ] **External links** имеют `rel="noopener noreferrer"` для `target="_blank"` — frontend owner — warn.

## Tests

- [ ] **Critical user-journey** покрыт Playwright или ручным smoke — QA — block — [Playwright](../docs/09-testing/Playwright.md), [E2E testing](../docs/09-testing/E2E-testing.md).
- [ ] **Component tests** для сложных интерактивных компонентов — frontend owner — warn — [Frontend testing](../docs/02-frontend/Frontend-testing.md).
- [ ] **Visual regression** для дизайн-системы и hero pages — frontend owner — warn — [Visual testing](../docs/09-testing/Visual-testing.md).
- [ ] **Responsive screenshots** сохранены или проверены для 360px / 768px / desktop на критичных routes — QA — warn — [Visual testing](../docs/09-testing/Visual-testing.md).
- [ ] **Story/component states** есть для reusable widgets: default/loading/error/empty/long text/mobile — frontend owner — warn — [Component-driven development](../docs/02-frontend/Component-driven-development.md).
