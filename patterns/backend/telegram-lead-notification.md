---
title: "Pattern: Telegram lead notification"
category: "patterns"
updated: "2026-05-27"
status: "active"
tags: ["backend", "serverless", "telegram", "forms", "notifications"]
source_priority: "internal"
area: "backend"
date: "2026-05-27"
---

# Telegram lead notification

## Назначение

Паттерн позволяет быстро принимать заявки с лендинга и отправлять их в Telegram-чат без полноценной CRM на первом этапе. Он подходит для MVP, когда важна скорость реакции менеджера, но безопасность формы все равно должна жить на сервере.

## Когда использовать

- Небольшой лендинг или промо-сайт собирает имя, телефон, направление и комментарий.
- Команде достаточно Telegram-чата как первого канала обработки лидов.
- Нужен простой serverless endpoint, который можно задеплоить рядом со статикой.

## Когда не использовать

Не используй Telegram как единственное хранилище лидов, если нужны SLA, аналитика продаж, история статусов, согласия, CRM-воронка или аудит обработки персональных данных. В этих случаях Telegram может быть уведомлением, но не источником истины.

## Структура

- Клиентская форма отправляет JSON на serverless endpoint, например `/api/lead`.
- Endpoint принимает только `POST` и `OPTIONS`; остальные методы возвращают `405`.
- Payload ограничен по размеру, JSON парсится безопасно, некорректный JSON превращается в пустой объект.
- Сервер повторно валидирует поля: имя обязательно, телефон нормализуется до `+7...`, направление проверяется через allowlist.
- Honeypot-поле, например `website`, отсекает простые spam-submit без влияния на обычного пользователя.
- Сообщение для Telegram собирается на сервере; пользовательские строки экранируются перед `parse_mode: HTML`.
- `TELEGRAM_BOT_TOKEN` и `TELEGRAM_CHAT_ID` читаются только из server env vars.
- В dev/preview без env vars endpoint возвращает dry-run success; в production отсутствие env vars считается ошибкой конфигурации.
- UI показывает loading, disabled submit, validation errors, server error fallback и success state.

## Реализация (пример)

```js
async function sendToTelegram(lead) {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  const chatId = process.env.TELEGRAM_CHAT_ID;

  if (!token || !chatId) {
    if (process.env.NODE_ENV !== 'production' || process.env.LEAD_DRY_RUN === '1') {
      return { ok: true, dryRun: true };
    }
    throw new Error('telegram_env_missing');
  }

  return fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      chat_id: chatId,
      text: buildEscapedMessage(lead),
      parse_mode: 'HTML',
      disable_web_page_preview: true,
    }),
  });
}
```

## Production-паттерны

Добавь rate limit или Turnstile/hCaptcha при росте spam, логируй только технические ошибки без полного payload, держи резервный канал связи в UI, проверяй env vars на preview и production отдельно. Если лиды становятся критичными, дублируй их в CRM, таблицу или очередь.

### Astro + Vercel: рантайм-env и платформо-нейтральный endpoint

- **Читай секреты из `process.env`, не из `import.meta.env`.** В Astro приватные
  (не `PUBLIC_`) переменные через `import.meta.env` подставляются на build-time;
  в serverless-рантайме (Vercel/Cloudflare) их там может не быть → форма молча
  уйдёт в вечный dry-run даже при заданных токенах. Безопасно:
  `process.env.TELEGRAM_BOT_TOKEN ?? import.meta.env.TELEGRAM_BOT_TOKEN`
  (фолбэк сохраняет локальный `astro dev` с `.env`).
- **Держи endpoint платформо-нейтральным** (стандартные `Request`/`Response`,
  `export const prerender = false`). Тогда смена адаптера `@astrojs/node` →
  `@astrojs/vercel` (`npx astro add vercel`) при `output: 'static'` собирает
  именно этот роут как serverless-функцию без правок его кода (hybrid).
- Токены задаются в env платформы (Vercel → Project → Settings → Environment
  Variables, scope Production); включение доставки = добавить env + redeploy,
  без передеплоя кода.

## Частые ошибки

- Отправлять Telegram Bot Token в клиентский JavaScript.
- Доверять client validation и не проверять телефон/направление на сервере.
- Не экранировать пользовательский текст при `parse_mode: HTML`.
- Возвращать success пользователю, когда Telegram API вернул ошибку.
- Логировать имя и телефон полностью в server logs.

## Альтернативы

Email provider лучше для формальных transactional notifications. CRM webhook лучше, когда уже есть отдел продаж и статусы обработки. Google Sheets или Notion допустимы как временное хранилище, но требуют строгих прав доступа.

## Источники

- [Урок: Telegram lead form boundary](../../lessons-learned/2026-05-27-telegram-lead-form-boundary.md)
- [Успешное решение: статический лендинг ТВОЙ ХИТ](../../case-studies/successes/2026-05-27-tvoi-hit-static-landing.md)
- [Forms and validation](../../docs/02-frontend/Forms-validation.md)
- [Secrets](../../docs/05-auth-security/Secrets.md)
