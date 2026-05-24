---
title: "OWASP"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["owasp", "security"]
source_priority: "official-docs"
---

# OWASP

Минимум для web-проектов: broken access control, cryptographic failures, injection, insecure design, security misconfiguration, vulnerable components, auth failures, integrity failures, logging failures, SSRF.

Каждый релиз должен проходить [security review](../../checklists/security-review.md).

Источник: [OWASP Top 10](https://owasp.org/www-project-top-ten/).

## Когда использовать

OWASP checklist используй перед release, после добавления auth/payments/uploads/admin и при code review security-sensitive изменений.

## Когда не использовать

Не превращай OWASP в формальную галочку. Если нет threat model и negative tests, checklist не защищает продукт.

## Production-паттерны

Для каждого риска определи контрол: validation, authz, secure config, dependency scan, logging, rate limit, tests.

## Частые ошибки

Проверить только injection и забыть broken access control, SSRF, logging gaps, vulnerable components и insecure design.

## Проверка

Security review checklist, dependency scan, authz negative tests, upload/SSRF tests, secrets scan, logs review.

