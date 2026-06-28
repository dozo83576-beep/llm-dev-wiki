---
title: "Astro 7 + Vercel adapter: import path and audit"
category: "lesson"
updated: "2026-06-25"
status: "active"
tags: ["astro", "vercel", "security", "audit"]
source_priority: "internal"
---

# Astro 7 + Vercel adapter: import path and audit

## Контекст

В Astro 7 с `@astrojs/vercel@11` импорт `@astrojs/vercel/serverless` не резолвится. Актуальный импорт:

```js
import vercel from '@astrojs/vercel';
```

Для runtime endpoint на Vercel использовать:

```js
export default defineConfig({
  output: 'server',
  adapter: vercel(),
});
```

## Урок

- Не переносить старые snippets с `@astrojs/vercel/serverless` без проверки текущего `exports` пакета.
- Если `npm audit` показывает high по `path-to-regexp` через `@vercel/routing-utils`, проверить совместимый override до отката adapter на старую major-версию.
- Для `@astrojs/vercel@11.0.0` override `path-to-regexp: 6.3.0` снял production audit finding в проекте `stroganov-site`.

## Проверка

- `npm run check`
- `npm run build`
- `npm audit --omit=dev`
