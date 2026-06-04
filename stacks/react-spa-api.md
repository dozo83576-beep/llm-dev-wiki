---
title: "Stack: React SPA + API"
category: "stack"
updated: "2026-06-04"
status: "active"
tags: ["react", "spa", "api", "vite"]
source_priority: "official-docs"
---

# React SPA + API

Production baseline для client-heavy приложений, где frontend и backend деплоятся отдельно. Актуальная линия: React 19, TypeScript 6, Vite, TanStack Query, React Hook Form, Zod, OpenAPI client, Playwright.

## Когда использовать

- API уже существует или backend развивает отдельная команда.
- Приложение работает за корпоративным gateway, в embedded окружении или как internal tool.
- SEO не является главным каналом, а основная ценность в интерактивности после логина.
- Backend должен быть NestJS/FastAPI/Fastify с отдельными workers, очередями или WebSocket runtime.

## Когда не использовать

- Публичные SEO-страницы, каталог, blog, landing или marketplace listings требуют server-rendered контент.
- Нужен единый full-stack deploy с route handlers и Server Components: см. [Next.js Fullstack](nextjs-fullstack.md).
- Команда не готова держать API contract, CORS, auth token refresh и release coordination.

## Scaffold commands

```bash
pnpm create vite web --template react-ts
cd web
pnpm add @tanstack/react-query react-hook-form @hookform/resolvers zod react-router
pnpm add -D vitest @testing-library/react @testing-library/jest-dom playwright
pnpm exec playwright install --with-deps
```

Для typed API клиента генерируй код из OpenAPI:

```bash
pnpm add -D openapi-typescript
pnpm exec openapi-typescript ../api/openapi.json -o src/shared/api/schema.d.ts
```

## Структура проекта

```text
src/app/                 router, providers, app shell
src/pages/               route-level screens
src/features/<name>/     feature components, hooks, schemas
src/shared/api/          generated API types, client, error normalization
src/shared/ui/           primitives and design tokens
src/shared/lib/          query client, auth token helpers, config
tests/e2e/               Playwright journeys against preview/staging
```

API contract is the boundary. The SPA must not depend on backend database shape or undocumented response fields.

## Env vars

- `VITE_API_BASE_URL` points to preview/staging/prod API.
- `VITE_PUBLIC_*` values are not secrets; auth client IDs are allowed only when provider docs mark them public.
- Runtime config should be served from a small `/config.json` only when the same build artifact must run in multiple environments.

## Data, auth and cache boundaries

- TanStack Query owns server state, retries, refetch and invalidation.
- Local component state owns UI-only values: open dialogs, tabs, draft input before submit.
- API errors are normalized once and mapped to field/global UI messages.
- Access tokens are not stored in localStorage unless the threat model accepts XSS token theft; prefer httpOnly cookies or short-lived tokens with refresh controls.
- Query keys include tenant/user/filter scope to prevent cross-user cache bleed.

## CI/test/deploy gates

```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm build
pnpm exec playwright test
```

Frontend preview must point to a compatible API preview or a reviewed contract mock. Backend breaking changes require contract tests before frontend merge.

## Acceptance checklist

- SPA handles loading, error, empty, unauthorized and permission denied states.
- OpenAPI schema or typed API client is committed or generated deterministically in CI.
- CORS and cookie settings are tested against preview domains.
- Bundle budget is tracked; heavy dashboard widgets are lazy loaded.
- Playwright covers login, primary CRUD, failed API response and responsive shell.

## Источники

- [React Docs](https://react.dev/)
- [Vite Docs](https://vite.dev/)
- [TanStack Query](https://tanstack.com/query/latest)
- [React Router](https://reactrouter.com/)
- См. [Vite + React](../docs/02-frontend/Vite-React.md), [React Router](../docs/02-frontend/React-Router.md), [OpenAPI](../docs/06-api-design/OpenAPI.md).
