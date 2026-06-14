---
title: "Pattern: Static site + dev-only CMS behind build flag"
category: "pattern"
updated: "2026-06-12"
status: "active"
tags: ["astro", "cms", "keystatic", "static", "cloudflare-pages", "seo", "forms"]
source_priority: "internal"
area: "frontend"
date: "2026-06-12"
---

# Pattern: Static site + dev-only CMS behind build flag

## Назначение

Позволяет иметь редактируемую CMS (Keystatic, TinaCMS и т.п.) для контентного сайта, не жертвуя
полностью статической прод-сборкой. CMS и SSR-адаптер подключаются только локально под флагом
сборки; прод остаётся чистой статикой (`output: 'static'`, без адаптера) — лучший SEO/perf и
предсказуемый деплой. Динамическая логика (приём заявок) выносится в отдельную serverless-функцию
платформы, а не в SSR-маршрут фреймворка.

## Когда использовать

- Лендинг/контентный сайт на Astro (или похожем SSG), где органика — часть бизнес-модели.
- Контент редактирует только разработчик (или редко, локально), и hosted-CMS избыточна.
- Нужна «удобная CMS, не WordPress», но её админка требует SSR и ломает статический prerender.
- Есть ровно один-два динамических эндпоинта (форма лида, webhook), ради которых не хочется
  переводить весь сайт в server-mode.

## Когда не использовать

- Редактор-неразработчик правит контент в проде регулярно → нужна hosted-CMS (Sanity) или
  git-CMS в GitHub-storage с рабочей админкой на проде.
- Много персонализированных/SSR-страниц → проще честный server-output с адаптером.

## Структура

- **Флаг сборки** (`ENABLE_KEYSTATIC=true`) условно добавляет: React-интеграцию, интеграцию CMS и
  SSR-адаптер. Без флага их нет — сборка чисто статическая.
- **CMS source of truth** — те же файлы контента, что читает SSG (Astro Content Collections).
  Редактирование локально (`npm run cms`), затем коммит и редеплой (git-based workflow).
- **Форма/динамика** — нативная функция платформы (Cloudflare Pages Function в `functions/`,
  Netlify Function и т.п.), независимая от сборки фреймворка. Секреты только в server env.
- **robots/sitemap** исключают служебные маршруты CMS (`/keystatic`) и noindex-страницы.

## Реализация (пример)

```js
// astro.config.mjs — статика по умолчанию; CMS+адаптер только под флагом
const enableKeystatic = process.env.ENABLE_KEYSTATIC === "true";

const keystaticIntegrations = enableKeystatic
  ? await (async () => {
      const react = (await import("@astrojs/react")).default;
      const keystatic = (await import("@keystatic/astro")).default;
      return [react(), keystatic()];
    })()
  : [];

const adapter = enableKeystatic
  ? (await import("@astrojs/cloudflare")).default()
  : undefined;

export default defineConfig({
  site: "https://example.tld",
  output: "static",
  ...(adapter ? { adapter } : {}),
  integrations: [mdx(), ...keystaticIntegrations, sitemap({
    filter: (p) => !p.includes("/keystatic"),
  })],
  vite: { plugins: [tailwindcss()] },
});
```

```jsonc
// package.json
"scripts": {
  "dev": "astro dev",
  "cms": "cross-env ENABLE_KEYSTATIC=true astro dev", // админка на /keystatic
  "build": "astro build"                              // чистая статика
}
```

Форма лида — отдельной функцией платформы (`functions/api/lead.js`), см.
[telegram-lead-notification](../backend/telegram-lead-notification.md): валидация на сервере,
honeypot, экранирование, dry-run без env.

## Production-паттерны

- Прод-сборка не содержит маршрутов CMS и SSR-адаптера → нет лишней attack surface и нет зависимости
  от runtime платформы для контентных страниц.
- Функция формы деплоится платформой из `functions/` автоматически (Cloudflare Pages), env-секреты
  задаются в дашборде как Secret.
- Локальный тест функции: `npx wrangler pages dev dist`; быстрый unit-тест — импорт `onRequestPost`
  с фейковым `Request`/`env` и проверка happy/validation/honeypot путей (dry-run без сети).

## Частые ошибки

- **Включить CMS-интеграцию в статический prerender.** Маршрут админки (`/keystatic`) при
  `output: 'static'` пытается пререндериться и уходит в сеть (config/cloud), падая с `fetch failed`
  (`internalConnectMultiple`) на этапе `prerendering static routes`. Лечится вынесением CMS за флаг,
  как выше.
- Слать лид прямо из браузера в Telegram → утечка токена в client-бандл.
- Забыть исключить `/keystatic` из sitemap и noindex-страницы из карты сайта.
- Тянуть SSR-адаптер только ради CMS, переводя в server-mode весь сайт.

## Альтернативы

- **Git-CMS в GitHub-storage** (Keystatic Cloud/GitHub mode) — рабочая админка на проде, но нужен
  OAuth и SSR-эндпоинты в проде.
- **Hosted headless CMS** (Sanity) — когда редактор-неразработчик правит контент регулярно.
- **Только Content Collections без CMS** — если редактор всегда разработчик и UI-админка не нужна.

## Источники

- Case study: статический сайт «детский спортивный психолог» (sport-psy), Astro 6 + Keystatic
  dev-only + Cloudflare Pages Function, build green, lead-функция протестирована (happy/validation/
  honeypot), секретов в client-бандле нет — 2026-06-12.
- См. [telegram-lead-notification](../backend/telegram-lead-notification.md),
  [server-client-boundary](server-client-boundary.md),
  [CMS content](../../docs/02-frontend/CMS-content.md),
  [Astro](../../docs/02-frontend/Astro.md),
  [SEO](../../docs/02-frontend/SEO.md).
