---
title: "Mocks"
category: "testing"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["mocks", "testing", "stubs"]
source_priority: "internal"
---

# Mocks

Mocks нужны для границ системы: внешние API, время, случайность, источники недетерминированных эффектов. Mock доменной логики — анти-паттерн, который скрывает реальные баги под уверенностью "тест зелёный".

## Когда использовать

- Внешние HTTP-сервисы (Stripe, OpenAI, GitHub) — заменить sandbox / MSW / fake server.
- Время — frozen clock, чтобы тест был детерминированным.
- Случайность — seeded RNG.
- Дорогие операции (S3 upload, sending email) в unit-тестах.

## Когда не использовать

- Внутренние сервисы / repository — теряется ценность теста, лучше real DB.
- Доменная логика — теряется коврадж того, что реально хочется проверить.
- API-контракт с внешним сервисом — лучше contract tests / sandbox.

## Подходы

- **MSW (Mock Service Worker)**: перехват HTTP на уровне fetch / XHR. Один источник правды для frontend и Node integration tests.
- **Fake implementations**: in-memory реализация интерфейса (fakeUserRepo) вместо stub'а на каждый метод.
- **Sandbox / test mode** провайдеров (Stripe test mode, AWS LocalStack, MailHog).
- **Stub** одной функции — vi.spyOn / sinon.stub точечно, без замены всего модуля.

## Production-паттерны

- Mock external boundary, not internal behavior.
- Стабильные responses, версионированные вместе с тестом.
- Failure modes явно покрыты: timeout, 429, 500, malformed JSON, network drop.
- Counter-проверки (`expect(mock).toHaveBeenCalledWith(...)`) — только когда действительно важно, иначе хрупкие тесты.

## Частые ошибки

- Мокать database client / ORM — упускаются SQL-баги.
- Дублировать контракт в моках и в коде — изменение спецификации требует двойной правки.
- Mock who-knows-what через `vi.mock()` без типов — тест может зеленеть на исчезнувший метод.
- Stub возвращает `null` "чтобы прошло" — реальный ответ устроен иначе.
- Один глобальный mock на весь suite — скрытое состояние.

## Security risks

Sandbox API keys коммитятся в репо; mock-fixtures содержат реальные PII; sandbox-ответы не отражают новые поля production-схемы.

## Testing strategy

- Contract test для внешнего API против sandbox раз в N runs.
- Smoke на mock setup: вернёт ли он валидный ответ согласно типу.
- Чёрный ящик: тест читается как сценарий, не как набор `mockReturnValue`.

## Edge cases

- Async / стриминг ответы (OpenAI SSE) — нужен mock с правильным флоу.
- WebSocket-моки — MSW v2 / отдельная библиотека.
- Race conditions при двух параллельных fetch — порядок ответов важен.
- File system mocks: разные платформы — разное поведение.

## Источники

- [Mock Service Worker](https://mswjs.io/) — проверено 2026-05-24.
- См. [Fixtures](Fixtures.md), [Integration testing](Integration-testing.md), [Contract testing](Contract-testing.md).
