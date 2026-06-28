---
title: "CORS, CSRF, CSP"
category: "security"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["cors", "csrf", "csp"]
source_priority: "official-docs"
---

# CORS, CSRF, CSP

CORS не является auth. Разрешай только нужные origins, methods и headers. CSRF защищай для cookie-based auth. CSP снижает XSS-ущерб и должна быть совместима с frontend.

Источники: [MDN CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS), [MDN CSP](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP), [OWASP CSRF](https://owasp.org/www-community/attacks/csrf).

## Когда использовать

CORS нужен для browser access control, CSRF для cookie-based auth, CSP для снижения XSS-ущерба на публичных и authenticated страницах.

## Когда не использовать

Не используй CORS как authentication. Не отключай CSRF для cookie auth без другой защиты. Не вводи CSP, которую никто не проверяет в report-only режиме.

## Production-паттерны

Allowlist origins, credentials только где нужно, SameSite cookies, CSRF token или double-submit, CSP report-only rollout перед enforcement.

## Частые ошибки

`Access-Control-Allow-Origin: *` с credentials, отключенный CSRF в Django/Rails-like apps, inline scripts без nonce, CSP ломает checkout/provider widgets.

## Проверка

Browser integration tests, security header scan, CSRF negative test, CSP report review, ручная проверка third-party scripts.

