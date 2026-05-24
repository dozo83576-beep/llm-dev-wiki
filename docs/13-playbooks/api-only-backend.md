---
title: "Playbook: API-only backend"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["api", "backend"]
source_priority: "internal"
---

# Playbook: API-only backend

## Стек по умолчанию

NestJS/FastAPI/Fastify + PostgreSQL + OpenAPI + integration tests + observability.

## Порядок разработки

1. Define clients and API contracts.
2. Model resources, permissions and error contract.
3. Implement validation at boundary.
4. Add service layer and transaction boundaries.
5. Add OpenAPI and contract tests.
6. Add rate limits, logs, metrics and health checks.

## Анти-паттерны

- API без стабильного error contract.
- Версионирование после первого breaking change.
- Отсутствие negative permission tests.

