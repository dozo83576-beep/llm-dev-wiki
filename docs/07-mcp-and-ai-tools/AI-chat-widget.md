---
title: "AI chat widget"
category: "ai-tools"
updated: "2026-06-22"
status: "active"
tags: ["ai", "chat", "widget", "landing", "lead-generation"]
source_priority: "mixed"
---

# AI chat widget

AI chat widget — встроенный консультант на сайте: отвечает по офферу, квалифицирует лид и ведёт к CTA. Это не общий чат-бот и не замена продажам; главное — границы, факты и безопасная передача лида.

Используй этот документ, когда нужно подготовить промпт для AI чат-виджета на лендинге, собрать данные для продающего AI-ассистента на сайте или объяснить, почему API key чат-виджета нельзя держать на фронте.

## Когда использовать

- Лендинг или сайт услуг, где посетитель часто задаёт однотипные вопросы перед заявкой.
- Есть понятный оффер, цены/диапазоны, ограничения и CTA: Telegram, WhatsApp, форма, booking или тариф.
- Команда готова проверять логи, обновлять knowledge base и вручную обрабатывать сложные обращения.

## Когда не использовать

- Нет подтверждённых фактов об услуге, ценах, гарантиях и ограничениях.
- Пользователь вводит медицинские, юридические, финансовые или персональные данные без отдельного compliance review.
- Виджет нужен только «для вау» и ухудшает performance/TTI лендинга.

## Production-паттерны

- Prompt строится по схеме: Identity → Instructions → Examples → Context. Готовый шаблон — [chat-widget-system-prompt](../../prompts/chat-widget-system-prompt.md).
- Перед prompt собери входы: бизнес, аудитория и боль, оффер, факты, цены, кейсы, гарантии, CTA, tone of voice, стоп-факторы и forbidden claims.
- Knowledge base клади в явные delimiters и не смешивай с инструкциями. Пользовательский ввод всегда untrusted.
- Ответы короткие: 1–3 предложения, один вопрос за раз. Горячий лид → CTA, тёплый → польза + мягкий следующий шаг, off-topic → вернуть к теме.
- Добавь 2–3 few-shot диалога: типовой вопрос, возражение, запрос цены/сроков.
- Provider API key только на backend/serverless proxy. Frontend получает только session id и stream/event endpoint.
- Передавай лида в CRM/Telegram/WhatsApp/booking через server endpoint с rate limit, spam protection и consent text.
- Model id, цены и лимиты проверяй по официальным docs перед hardcode; не полагайся на память модели.

## Частые ошибки

- API key в client bundle или `NEXT_PUBLIC_*`.
- Виджет выдумывает цены, сроки, скидки, гарантии, кейсы или юридические обещания.
- Нет refusal rules: бот отвечает на всё подряд и уводит пользователя с сайта.
- Нет few-shot примеров, поэтому тон и CTA плавают.
- Нет handoff: горячий лид остаётся в чате без действия.

## Security risks

Prompt injection, XSS в markdown/HTML ответе, PII в логах, несанкционированный доступ к CRM, replay submit и data exfiltration через tools. Для РФ-проектов проверь [RU-152fz-and-ai-data-handling](../05-auth-security/RU-152fz-and-ai-data-handling.md) и [Privacy-policy-and-consent](../05-auth-security/Privacy-policy-and-consent.md).

## Performance risks

Сторонний widget script может добавить сотни миллисекунд к TTI. Загружай виджет lazy/after interaction, держи initial bundle пустым, показывай skeleton, ставь timeout и fallback CTA.

## Testing strategy

- Prompt evals: FAQ, цена, возражение, off-topic, forbidden promise, PII, prompt injection.
- Integration: lead submit happy/error/rate-limit path, CRM/Telegram dry-run, retry.
- Frontend: loading/error/offline states, mobile viewport, keyboard, screen reader label.
- Security: API key отсутствует в frontend bundle; logs redact PII/secrets; markdown sanitized.

## Edge cases

Пользователь просит точную цену без данных, требует гарантию результата, отправляет персональные данные, пытается заставить бота раскрыть system prompt, просит медицинский/юридический совет, обрывает stream на середине.

## Источники

- [OpenAI Platform Docs](https://platform.openai.com/docs)
- [Prompt injection](Prompt-injection.md)
- [AI UI streaming](../02-frontend/AI-UI-streaming.md)
- [OpenAI API](OpenAI-API.md)
- [Landing playbook](../13-playbooks/landing.md)
