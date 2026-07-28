---
title: "OWASP"
category: "security"
updated: "2026-07-21"
reviewed: "2026-07-21"
status: "active"
tags: ["owasp", "security"]
source_priority: "official-docs"
---

# OWASP

OWASP Top 10:2025 задаёт десять категорий: **Broken Access Control**, **Security Misconfiguration**, **Software Supply Chain Failures**, **Cryptographic Failures**, **Injection**, **Insecure Design**, **Authentication Failures**, **Software or Data Integrity Failures**, **Security Logging & Alerting Failures**, **Mishandling of Exceptional Conditions**.

Это не простое переименование списка 2021: SSRF рассматривается внутри Broken Access Control, риск vulnerable/outdated components расширен до software supply chain, а небезопасная обработка исключительных ситуаций выделена отдельно. Threat model, review и negative tests должны покрывать все десять категорий, а не только injection/auth.

Каждый релиз должен проходить [security review](../../checklists/security-review.md).

Источник: [OWASP Top 10:2025](https://owasp.org/Top10/2025/) — проверено 2026-07-21.

## Когда использовать

OWASP checklist используй перед release, после добавления auth/payments/uploads/admin и при code review security-sensitive изменений.

## Когда не использовать

Не превращай OWASP в формальную галочку. Если нет threat model и negative tests, checklist не защищает продукт.

## Production-паттерны

Для каждого риска определи контрол: validation, authz, secure config, dependency scan, logging, rate limit, tests.

## Частые ошибки

Проверить только injection и забыть broken access control/SSRF, supply chain, misconfiguration, logging/alerting gaps, integrity, insecure design и fail-open exception paths.

## Проверка

Security review checklist, dependency/provenance scan, authz negative tests, upload/SSRF tests, secure-config diff, secrets scan, logs/alerts review и fail-closed tests для timeouts/exceptions.

