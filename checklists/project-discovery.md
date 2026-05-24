---
title: "Project discovery checklist"
category: "checklist"
updated: "2026-05-24"
status: "active"
tags: ["discovery", "kickoff"]
source_priority: "internal"
---

# Project discovery checklist

Gated checklist для kickoff'а нового проекта. Формат: критерий — проверка — owner — severity — ссылка. Используй вместе с [discovery interview prompt](../prompts/discovery-interview.md).

## Goal & scope

- [ ] **Цель проекта** сформулирована одним предложением (problem → outcome) — product owner — block.
- [ ] **Out of scope** явно зафиксирован — product owner — block.
- [ ] **Success metrics** определены и измеримы — product owner — block.
- [ ] **Тип проекта** выбран из [matrix стеков](../docs/01-development-process/stack-selection.md) → playbook назначен — tech lead — block — [playbooks](../docs/13-playbooks/index.md).

## Users & roles

- [ ] **Пользователи** перечислены: персоны, роли, сценарии — product owner — block.
- [ ] **Permissions matrix** черновик (кто что делает) — tech lead — block — [RBAC/ABAC](../docs/05-auth-security/RBAC-ABAC.md).
- [ ] **Onboarding flow** для каждой роли описан — product owner — warn.

## Acceptance criteria

- [ ] **Критерии приемки** зафиксированы как Gherkin / "given-when-then" или явные user stories — product owner — block.
- [ ] **Edge cases** перечислены (пустые состояния, ошибки, multi-locale, multi-tenant) — tech lead — warn.

## Integrations

- [ ] **Платежи** определены (provider, plan, currency, KYC) — tech lead — block — [Payments](../docs/03-backend/Payments.md).
- [ ] **Email / notifications** определены (transactional vs marketing) — tech lead — warn — [Email](../docs/03-backend/Email.md).
- [ ] **Analytics** и event tracking запланирован — product owner — warn — [Analytics](../docs/02-frontend/Analytics.md).
- [ ] **AI / external API** — список и квоты — tech lead — warn — [OpenAI API](../docs/07-mcp-and-ai-tools/OpenAI-API.md).
- [ ] **SSO / identity** требования зафиксированы — security owner — warn — [Authentication](../docs/05-auth-security/Authentication.md).

## Data & privacy

- [ ] **PII** определена; data retention policy зафиксирована — security owner — block.
- [ ] **Данные, которые нельзя сохранять** в вики и в logs перечислены — security owner — block.
- [ ] **Compliance** (GDPR / HIPAA / SOC2 / PCI) — обязательства явны — security owner — block.
- [ ] **Backup** и restore требования — devops owner — warn — [Backups](../docs/04-databases/Backups.md).

## Constraints

- [ ] **Сроки** известны (kickoff → MVP → launch) — product owner — block.
- [ ] **Бюджет** на сервисы и команду — product owner — block.
- [ ] **Hosting** / data residency — devops owner — block.
- [ ] **Поддержка** после launch (on-call, SLA) определена — tech lead — warn.

## Tests & quality

- [ ] **Минимальный набор тестов** для приёмки определён — QA — block — [Test pyramid](../docs/09-testing/Test-pyramid.md).
- [ ] **Performance budgets** (LCP, p95 latency) — tech lead — warn — [Performance](../docs/02-frontend/Performance.md).
- [ ] **Security baseline** определён (OWASP, MFA, rate limits) — security owner — block — [OWASP](../docs/05-auth-security/OWASP.md).

## Knowledge capture

- [ ] **Discovery документ** сохранён в репозитории проекта — product owner — block.
- [ ] **Playbook** ссылается из README проекта — tech lead — warn.
