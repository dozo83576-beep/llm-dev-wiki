---
title: "Security testing"
category: "testing"
updated: "2026-05-24"
status: "active"
tags: ["security-tests", "owasp"]
source_priority: "official-docs"
---

# Security testing

Security testing проверяет, что приложение защищено по OWASP Top 10 и не открывает классов уязвимостей: auth bypass, broken access control, injection, XSS, CSRF, SSRF, secrets leak, dependency CVE.

## Когда использовать

- Любой публичный API / SaaS / e-commerce.
- Перед major release с auth-изменениями.
- После security incident или ratification compliance (SOC2, ISO).
- Регулярный security review (ежеквартально или по релизам).

## Когда не использовать

- Прототипы без production-deploy — отложить, но не игнорировать в roadmap.
- Если приложение полностью offline и не принимает untrusted input.

## Уровни проверки

- **SAST** (static analysis): semgrep, CodeQL, GitHub Advanced Security.
- **SCA** (dependency scan): Dependabot, Snyk, OWASP Dependency-Check.
- **DAST** (running-app scan): OWASP ZAP, Burp.
- **Secrets scanning**: gitleaks, TruffleHog, GitHub Secret Scanning.
- **Container scan**: Trivy, Grype.
- **Manual pen-test** на критичные релизы.

## Production-паттерны

- Negative tests на auth boundary в integration suite (admin endpoint от non-admin даёт 403).
- IDOR-тесты: попытки доступа к чужим объектам через прямые id.
- Tenant isolation тесты: данные одного tenant не утекают в другой.
- Rate-limit тесты на login / password-reset / AI-endpoints.
- CSP / CORS regression тесты.
- Dependency review block на критичные CVE в CI.

## Что обязательно проверить

- Auth bypass: запросы без / с истёкшим / с подделанным токеном.
- Object-level access (IDOR).
- Injection: SQL, NoSQL, command, LDAP, prompt (для LLM).
- XSS: stored, reflected, DOM-based.
- CSRF на state-changing endpoints.
- SSRF: входящие URL-параметры, превращающиеся в исходящие запросы.
- Rate limits: brute-force / enumeration защиты.
- Secrets exposure: в bundle, в error messages, в logs.
- File upload: MIME, размер, AV-scan, path traversal.

## Частые ошибки

- Только automated scan без manual review — пропускает бизнес-логику.
- "Это internal API, не нужно auth" — пока однажды не выставят наружу.
- Игнорировать low/medium из scan без анализа — реальные риски накапливаются.
- Тестировать только happy auth path.

## Risks

DoS на собственное production через нагрузочный security scan, утечка данных через scan-логи, false sense of security от тестов без negative-кейсов.

## Testing strategy

- SAST + SCA + secrets scan на каждый PR.
- DAST против staging еженедельно.
- Manual security review перед major release.
- Regression tests на каждый закрытый security-finding.

## Edge cases

- LLM / RAG приложения: prompt injection, tool poisoning, jailbreak — отдельный класс тестов.
- WebSocket / SSE: auth и rate limit на каждом сообщении, не только на handshake.
- Webhook receivers: signature verification, replay protection.

## Источники

- [OWASP WSTG](https://owasp.org/www-project-web-security-testing-guide/) — проверено 2026-05-24.
- [OWASP Top 10](https://owasp.org/www-project-top-ten/) — проверено 2026-05-24.
- См. [OWASP](../05-auth-security/OWASP.md), [Authentication](../05-auth-security/Authentication.md), [Authorization](../05-auth-security/Authorization.md), [Prompt injection](../07-mcp-and-ai-tools/Prompt-injection.md), [security-review checklist](../../checklists/security-review.md).
