---
title: "Analytics"
category: "frontend"
updated: "2026-05-24"
status: "active"
tags: ["analytics", "product"]
source_priority: "internal"
---

# Analytics

Analytics отвечает на вопрос, что пользователи делают в продукте и где ломается воронка. События должны быть продуктово значимыми, а не шумом.

## Production-паттерны

- Event naming convention: `object_action_context`.
- Не отправляй PII без правового основания.
- Для checkout/auth/error flows фиксируй outcome и reason.
- Analytics не должна ломать основной UX при отказе провайдера.

## Проверка

- E2E или ручной smoke через debug mode analytics.
- Проверка consent/cookie policy для публичных сайтов.
- Проверка отсутствия секретов и персональных payloads.

