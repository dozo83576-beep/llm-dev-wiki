---
title: "Source priority"
category: "llm-indexing"
updated: "2026-05-24"
status: "active"
tags: ["sources", "trust"]
source_priority: "internal"
---

# Source priority

При конфликте источников порядок доверия:

1. Официальная документация (open standards, фреймворки, БД, протоколы).
2. Vendor docs (managed-сервисы, hosting, observability).
3. Репозитории maintainers и официальные блоги.
4. Зрелые production boilerplates с активной поддержкой.
5. Engineering статьи с датой и автором.
6. Сообщества, Reddit, личные блоги как secondary signal.

Внутренние lessons learned имеют высокий вес для повторения практики в этой команде, но не должны отменять security и official docs.

## Значения поля `source_priority` во front matter

- `official-docs` — документ опирается прежде всего на официальную документацию открытого стандарта или популярного фреймворка: React, Next.js, FastAPI, Django, NestJS, Fastify, Node.js, PostgreSQL, Prisma, Drizzle, SQLAlchemy, MCP, OpenAI API, OWASP, OpenAPI, GraphQL, pgvector, OpenTelemetry.
- `vendor-docs` — документ опирается на документацию конкретного провайдера или managed-сервиса: Vercel, Cloudflare, Render, Sentry, Stripe, AWS, GCP, Azure, Supabase.
- `internal` — документ синтезирует собственную инженерную практику (паттерны, чеклисты, playbooks, process-документы, lessons-learned, case-studies). Допустимы ссылки на внешние источники как цитаты, но утверждения принадлежат вики.
- `mixed` — документ задаёт внутреннюю практику, но часть обязательных правил прямо опирается на official docs или security standards.
- `community` — для конспектов engineering-статей и постов из сообщества с явной датой и автором.

## Правила выставления

- Если документ — пересказ одного официального ресурса, ставим `official-docs` или `vendor-docs` и обязательно даём ссылку с датой проверки.
- Если документ — оригинальный синтез нескольких источников, ставим `internal` и перечисляем все источники в секции "Источники".
- Если документ — внутренняя практика с обязательной привязкой к официальному стандарту или security baseline, ставим `mixed`.
- Если документ — production-playbook или checklist, ставим `internal` независимо от количества внешних ссылок.

## CI-проверка

Скрипт [tools/wiki-quality.ps1](../../tools/wiki-quality.ps1) предупреждает, если документ заявлен как `internal`, но в теле есть ссылка на authoritative external source (react.dev, fastapi.tiangolo.com, owasp.org и т.п.). Это сигнал пересмотреть приоритет и при необходимости выбрать `official-docs`, `vendor-docs` или `mixed`.

## Источники

- [docs/00-start-here/document-standard.md](../00-start-here/document-standard.md) — общий DoD для production-документа.
- [llms.txt](../../llms.txt) — публичная политика источников вики.
