---
title: "Email"
category: "backend"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["email", "notifications"]
source_priority: "internal"
---

# Email

Email нужен для auth, transactional notifications, billing, lifecycle и marketing. Transactional и marketing потоки должны быть разделены.

## Production-паттерны

- Templates версионируются.
- Отправка через queue.
- Idempotency для критичных писем.
- Bounce/complaint handling.
- Unsubscribe для marketing.

## Проверка

- Snapshot/render tests для шаблонов.
- Integration test с sandbox provider.
- Проверка SPF/DKIM/DMARC перед production.

## Когда использовать

Используй email для transactional сообщений: auth, invites, receipts, alerts, lifecycle. Marketing email требует отдельного consent и unsubscribe.

## Когда не использовать

Не используй email как единственный канал для критичных real-time уведомлений, если задержка недопустима.

## Частые ошибки

Отправлять email в HTTP request без queue, не обрабатывать bounce/complaint, смешивать transactional и marketing, логировать персональный payload.

## Edge cases

- Verification email — двойной opt-in; токен с TTL и одноразовый.
- Локализация: язык письма берётся из user-preference, не из header браузера.
- Reply-to vs from: transactional обычно noreply, support-flow — реальный reply-to.
- Large attachments — отдельный путь (storage + ссылка), не inline.
- Reputation: warm-up нового домена, монитор bounce/complaint rate.

## Security risks

Header injection через user-input в subject / from, spoofing без SPF/DKIM/DMARC, утечка PII в email body (например, полный security token вместо короткого опаска).

## Источники

См. документацию выбранного provider (Resend / Postmark / SES) и [Secrets](../05-auth-security/Secrets.md).

