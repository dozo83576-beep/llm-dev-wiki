---
title: "Vercel"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["vercel", "nextjs", "hosting"]
source_priority: "vendor-docs"
---

# Vercel

Vercel — основной hosting для Next.js: preview deployments на каждый PR, environment variables по окружениям, edge/CDN, serverless functions, observability, analytics. Production-мутации проверяются через preview и protected branches.

## Когда использовать

- Frontend и full-stack на Next.js, особенно с App Router и Server Components.
- Маркетинговые сайты, SaaS с умеренной нагрузкой, dashboards.
- Команды, которым важен preview-per-PR workflow.

## Когда не использовать

- Backend требует long-running процессы, large background jobs или WebSocket-сервера — лучше Render/Fly/Railway.
- Жёсткие требования к региону (data residency) и нужен self-host.
- Очень большие vendor-блоки compute (cron-задачи на минуты) — будет дорого.

## Production-паттерны

- Production deploy только из защищённого main; PR'ы катят preview окружение.
- Environment variables разделены по `production` / `preview` / `development`; секреты не дублируются.
- Edge functions для лёгких задач (auth-cookie, geo-routing); тяжёлая логика — в node runtime.
- ISR/On-demand revalidation вместо ручных deploy для изменения контента.
- Аналитика и Real Experience Score включены, alert на регрессию p75 LCP.

## Частые ошибки

- Хранить секрет в `NEXT_PUBLIC_*` — он попадает в bundle.
- Превышение лимита на serverless function size (включены лишние deps) — деплой падает в production.
- Использовать `unstable_cache` или `revalidate` без понимания, что попадает в edge cache.
- Промоутить preview в production без прогона миграций и smoke-тестов.

## Security risks

Утечка переменных окружения в client bundle, открытые preview URL с production-данными, отсутствие auth на admin-routes на preview, забытые legacy preview deployments.

## Performance risks

Холодный старт serverless functions, edge-vs-node mismatch, неконтролируемая ISR-инвалидация, тяжёлые middleware на каждый запрос.

## Testing strategy

- Preview URL — основная среда для review и QA.
- Lighthouse / WebPageTest в CI с порогами.
- E2E (Playwright) на preview перед мерджем.
- Smoke-тесты на production после релиза.

## Edge cases

- Monorepo: правильная настройка `Root Directory` и `Build Command` на проект.
- Database connection pooling: для Postgres использовать pgbouncer/Neon pooler.
- Cookies на edge — особенности `SameSite` и `Secure` для preview-доменов.

## Источники

- [Vercel Docs](https://vercel.com/docs) — проверено 2026-05-24.
- [Next.js Deployment](https://nextjs.org/docs/app/building-your-application/deploying) — проверено 2026-05-24.
- См. [Release flow](Release-flow.md), [Environment variables](Environment-variables.md), [Observability](Observability.md).
