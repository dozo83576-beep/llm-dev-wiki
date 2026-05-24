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

## Когда использовать

Используй analytics для лендингов, onboarding, checkout, activation, retention, feature adoption и error funnels.

## Когда не использовать

Не добавляй события “на всякий случай”. Событие без владельца, вопроса и решения, которое оно помогает принять, становится шумом.

## Частые ошибки

Отправлять PII, логировать raw form payload, считать page view достаточной аналитикой, ломать UX из-за отказа analytics provider.

## Источники

См. privacy и consent требования выбранного analytics provider, а также [[../05-auth-security/Secrets|Secrets]] и [[../02-frontend/Performance|Performance]].

