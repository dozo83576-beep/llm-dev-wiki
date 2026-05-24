---
title: "Карта LLM-вики"
category: "start"
updated: "2026-05-24"
status: "active"
tags: ["navigation", "wiki"]
source_priority: "internal"
---

# Карта LLM-вики

Полный список документов с metadata: [INDEX.md](../INDEX.md) (генерируется через `tools/build-index.ps1`).

## Быстрый маршрут для нового проекта

1. [Полный цикл разработки](../01-development-process/full-cycle.md)
2. [Выбор стека](../01-development-process/stack-selection.md)
3. [Project discovery](../../checklists/project-discovery.md)
4. [Промпт создания проекта](../../prompts/create-new-project.md)
5. [Security review](../../checklists/security-review.md)
6. [Release readiness](../../checklists/release-readiness.md)

## Основные разделы

- `docs/02-frontend` — React, Next.js, TypeScript, UI, формы, состояние, доступность, производительность.
- `docs/03-backend` — Node.js, NestJS, FastAPI, Django, фоновые задачи, ошибки, логирование.
- `docs/04-databases` — PostgreSQL, ORM, миграции, Redis, backup, проектирование данных.
- `docs/05-auth-security` — auth, RBAC/ABAC, OWASP, секреты, CSP, MCP-security.
- `docs/06-api-design` — REST, OpenAPI, GraphQL, WebSockets, ошибки, пагинация.
- `docs/07-mcp-and-ai-tools` — MCP, OpenAI API, RAG, embeddings, vector DB, agents, evaluation.
- `docs/08-devops-deploy` — Docker, CI/CD, Vercel, Cloudflare, Render, observability.
- `docs/09-testing` — unit, integration, E2E, contract, load, security testing.
- `docs/13-playbooks` — end-to-end инструкции по типам проектов.
- `docs/14-llm-indexing` — индексация вики для RAG/File Search и LLM-клиентов.

## Накопление опыта

Практический опыт хранится в `case-studies`, `patterns` и `lessons-learned`. Эти разделы важнее длинных теоретических заметок: они уменьшают повторение ошибок и ускоряют будущие проекты.

## Стандарт документа

Каждый production-документ должен отвечать на вопросы: назначение, когда использовать, когда не использовать, production-паттерны, частые ошибки, security/performance risks, testing strategy, edge cases и источники. Если источник внешний, вики хранит собственный конспект и ссылку, а не полную копию чужого материала.
