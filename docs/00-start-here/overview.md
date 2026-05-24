---
title: "Карта LLM-вики"
category: "start"
updated: "2026-05-24"
status: "active"
tags: ["navigation", "wiki"]
source_priority: "internal"
---

# Карта LLM-вики

## Быстрый маршрут для нового проекта

1. [[../01-development-process/full-cycle|Полный цикл разработки]]
2. [[../01-development-process/stack-selection|Выбор стека]]
3. [[../../checklists/project-discovery|Project discovery]]
4. [[../../prompts/create-new-project|Промпт создания проекта]]
5. [[../../checklists/security-review|Security review]]
6. [[../../checklists/release-readiness|Release readiness]]

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
