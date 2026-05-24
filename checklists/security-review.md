---
title: "Security review checklist"
category: "checklist"
updated: "2026-05-24"
status: "active"
tags: ["security", "release-gate"]
source_priority: "internal"
---

# Security review checklist

Gated checklist. Каждая строка — критерий, способ проверки, owner, severity, ссылка. `block` — релиз останавливается; `warn` — фиксируется и проходит после подтверждения owner.

## Access control

- [ ] **Broken access control** — IDOR-тест на чужие ID; tenant-boundary fuzz; admin endpoint от non-admin даёт 403 — backend/security owner — block — [Authorization](../docs/05-auth-security/Authorization.md), [OWASP A01](../docs/05-auth-security/OWASP.md).
- [ ] **Tenant isolation** — данные org A не видны из org B (integration tests на каждом list endpoint) — backend owner — block — [tenant-isolation pattern](../patterns/security/tenant-isolation.md).
- [ ] **Managed auth boundary** — Clerk/Auth.js/Supabase claims не заменяют backend object-level permission checks — security owner — block — [Authorization](../docs/05-auth-security/Authorization.md), [Clerk](../docs/05-auth-security/Clerk.md), [Auth.js](../docs/05-auth-security/Authjs.md), [Supabase](../docs/03-backend/Supabase.md).
- [ ] **Deny-by-default** — новые endpoints/queries требуют явного allow, не наследуют доступ — backend owner — block — [deny-by-default pattern](../patterns/security/deny-by-default.md).
- [ ] **MFA / step-up** для admin / financial / destructive операций — security owner — warn — [Authentication](../docs/05-auth-security/Authentication.md).

## Injection & input

- [ ] **SQL/NoSQL injection** — параметризированные запросы, нет string-concat для SQL — backend owner — block — [OWASP](../docs/05-auth-security/OWASP.md).
- [ ] **XSS** — output sanitization, CSP режим без `unsafe-inline`; user content escapen — frontend owner — block — [CORS-CSRF-CSP](../docs/05-auth-security/CORS-CSRF-CSP.md).
- [ ] **SSRF** — URL-параметры проверяются по allowlist, internal IP-блоки заблокированы — backend owner — block — [OWASP](../docs/05-auth-security/OWASP.md).
- [ ] **CSRF** — state-changing endpoints защищены SameSite cookies / CSRF-token — frontend owner — block — [CORS-CSRF-CSP](../docs/05-auth-security/CORS-CSRF-CSP.md).
- [ ] **Prompt injection** (LLM features) — system-prompt изолирован от user-input и tool-output — AI owner — block — [Prompt injection](../docs/07-mcp-and-ai-tools/Prompt-injection.md).

## Network & headers

- [ ] **CORS** — `Access-Control-Allow-Origin` указывает только нужные домены — backend owner — block — [CORS-CSRF-CSP](../docs/05-auth-security/CORS-CSRF-CSP.md).
- [ ] **CSP** — `Content-Security-Policy` совместим с frontend и снижает XSS-риск — frontend owner — warn — [CORS-CSRF-CSP](../docs/05-auth-security/CORS-CSRF-CSP.md).
- [ ] **Security headers** — `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`, HSTS — frontend/devops — warn.

## Secrets & dependencies

- [ ] **Secrets не в git** — gitleaks/TruffleHog CI scan чистый; нет `.env*` в репо — devops owner — block — [Secrets](../docs/05-auth-security/Secrets.md).
- [ ] **Секреты не в frontend bundle** — `NEXT_PUBLIC_*` не содержит API keys — frontend owner — block — [Secrets](../docs/05-auth-security/Secrets.md).
- [ ] **Секреты не в logs / error tracker** — PII scrubbing в Sentry — devops owner — block — [Sentry](../docs/08-devops-deploy/Sentry.md).
- [ ] **Dependency scan** — `pnpm audit` / Snyk / Dependabot без критичных CVE — devops owner — block — [Dependency security](../docs/05-auth-security/Dependency-security.md).
- [ ] **Container scan** — Trivy/Grype не показывают critical CVE в base image — devops owner — warn — [Docker](../docs/08-devops-deploy/Docker.md).

## Rate limits & abuse

- [ ] **Rate limiting** включён для login / signup / password-reset / AI-endpoints / expensive search — backend owner — block — [Rate limiting](../docs/05-auth-security/Rate-limiting.md).
- [ ] **Bot protection** на формах (Turnstile / hCaptcha) если есть public submission — frontend owner — warn.
- [ ] **Webhook signatures** проверяются до парсинга бизнес-payload — backend owner — block — [webhook-idempotency pattern](../patterns/backend/webhook-idempotency.md).
- [ ] **Payment/compliance boundary** — card data не хранится, Stripe/webhook state идемпотентен, GDPR/WCAG/PCI gates определены — security owner — block — [Stripe](../docs/03-backend/Stripe.md), [Compliance baseline](../docs/05-auth-security/Compliance-baseline.md).

## MCP & AI

- [ ] **MCP-инструменты** имеют минимальные права; write-tools требуют подтверждения — AI owner — block — [MCP security](../docs/05-auth-security/MCP-security.md).
- [ ] **Tool poisoning protection** — tool output не интерпретируется как инструкция модели — AI owner — block — [Tool permissions](../docs/07-mcp-and-ai-tools/Tool-permissions.md).

## Error handling & disclosure

- [ ] **Stack trace** не отдаётся пользователю; SQL/секреты не утекают в ответе — backend owner — block — [Error handling](../docs/03-backend/Error-handling.md).
- [ ] **Verbose 404** vs **vague 401/403** не позволяет user-enumeration — backend owner — warn.

## Knowledge capture

- [ ] **Найденные проблемы** записаны в [case-studies/failures](../case-studies/failures) с правилом предотвращения — security owner — warn.
- [ ] **Регрессионные тесты** добавлены для каждой закрытой security-issue — backend owner — block — [Security testing](../docs/09-testing/Security-testing.md).
