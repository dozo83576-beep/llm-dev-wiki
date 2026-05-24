---
title: "Project playbooks"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["playbooks", "delivery"]
source_priority: "internal"
---

# Project playbooks

Playbook — end-to-end инструкция для конкретного типа проекта: рекомендованный стек, порядок разработки, типичные риски, тесты, что точно нельзя забыть. Используй его вместе с [project discovery](../../checklists/project-discovery.md), [stack selection](../01-development-process/stack-selection.md) и [create project prompt](../../prompts/create-new-project.md).

## Доступные playbooks

- [SaaS](saas.md) — multi-tenant SaaS-приложение с auth, billing, RBAC.
- [Landing](landing.md) — маркетинговая страница с формами и аналитикой.
- [Marketplace](marketplace.md) — двух- и трёхсторонняя площадка с платежами, модерацией, payouts.
- [Admin dashboard](admin-dashboard.md) — internal-tool для операторов с audit log и RBAC.
- [AI/RAG app](ai-rag-app.md) — приложение с LLM и retrieval по собственной базе.
- [API-only backend](api-only-backend.md) — backend для mobile / third-party / SDK.
- [E-commerce](ecommerce.md) — магазин с checkout, payments, fulfillment.
- [Real-time app](real-time-app.md) — приложение с WebSocket/SSE и presence.

## Как пользоваться

1. Выбери playbook, который ближе всего к задаче. Если задача комбинирует несколько — комбинируй playbooks (например SaaS + AI/RAG).
2. Прогон [project-discovery](../../checklists/project-discovery.md) с пользователем продукта — чтобы playbook не висел в вакууме.
3. Иди по "Порядок разработки", не пропуская шаги, особенно security и testing.
4. Анти-паттерны проверь явно — каждый из них уже стоил кому-то релиза.
5. После запуска зафиксируй уроки в `lessons-learned/` или `case-studies/`.

## Общий Definition of Done

- Цель, аудитория и acceptance criteria зафиксированы и согласованы со стейкхолдерами.
- Стек выбран и обоснован (см. [stack selection](../01-development-process/stack-selection.md)).
- Архитектура задокументирована: компоненты, данные, интеграции.
- Security review пройден (см. [security-review checklist](../../checklists/security-review.md)).
- Тесты покрывают критичные сценарии (см. [Test pyramid](../09-testing/Test-pyramid.md)).
- Deploy, rollback и monitoring понятны (см. [Release flow](../08-devops-deploy/Release-flow.md), [Rollback](../08-devops-deploy/Rollback.md), [Observability](../08-devops-deploy/Observability.md)).
- Уроки проекта сохранены в `case-studies/successes`, `case-studies/failures` или `lessons-learned/`.

## Принципы

- Playbook — отправная точка, а не обязательная догма; адаптируй под контекст.
- Если в реальном проекте playbook оказался неполным — обнови его, не оставляй в личных заметках.
- Новый тип проекта — отдельный playbook, не "приклеить" к существующему.

## Источники

- См. [full-cycle](../01-development-process/full-cycle.md), [stack-selection](../01-development-process/stack-selection.md), [project discovery](../../checklists/project-discovery.md).
