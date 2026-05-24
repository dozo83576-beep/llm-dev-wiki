---
title: "Compliance baseline"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["compliance", "gdpr", "pci", "wcag", "privacy"]
source_priority: "mixed"
---

# Compliance baseline

Compliance baseline — минимальный набор engineering gates для проектов с персональными данными, платежами и публичным UI. Это не юридическое заключение; спорные требования подтверждаются юристом или compliance owner.

## Когда использовать

- SaaS, ecommerce, marketplace, healthcare/finance-like workflows, публичные сайты с формами и аналитикой.
- Есть PII, billing, user-generated content, account deletion/export или accessibility commitments.
- Проект продаётся B2B и может получить security/compliance questionnaire.

## Когда не использовать

- Не заменяет DPIA, DPA, SOC2, ISO27001, HIPAA или PCI audit.
- Не должен превращаться в бумажную checklist без технических проверок.

## Production-паттерны

- GDPR/privacy: data inventory, lawful basis, retention, export/delete request flow, PII minimization.
- PCI-lite: не хранить card data; использовать Stripe Checkout/Portal/Elements и provider-hosted flows.
- WCAG: target WCAG 2.2 AA для публичных и рабочих critical flows.
- Audit log: auth, role, billing, data export/delete и admin actions пишутся append-only.
- Release gate: compliance-impacting changes требуют security review и rollback plan.

## Частые ошибки

- Считать Stripe Checkout автоматическим решением всех PCI/privacy вопросов.
- Делать delete user без удаления/анонимизации связанных PII.
- Игнорировать accessibility до конца проекта.
- Логировать emails, tokens, payment ids и raw webhook payloads без retention policy.

## Проверка

- Discovery: PII map, payment boundary, accessibility target, data retention.
- Tests: export/delete request, denied access after deletion, payment flow without card storage, keyboard-only smoke.
- Release: security-review, frontend-review, database-review и release-readiness пройдены.

## Источники

- [European Commission: EU data protection legal framework](https://commission.europa.eu/law/law-topic/data-protection/legal-framework-eu-data-protection_en) — проверено 2026-05-24.
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/) — проверено 2026-05-24.
- [Stripe security guide](https://docs.stripe.com/security/guide) — проверено 2026-05-24.
