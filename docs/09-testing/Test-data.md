---
title: "Test data"
category: "testing"
updated: "2026-05-24"
status: "active"
tags: ["test-data", "fixtures", "synthetic"]
source_priority: "internal"
---

# Test data

Тестовые данные должны быть детерминированными, минимальными и безопасными. Они описывают сценарий теста, а не "вселенную" приложения. Production-дампы в тестах — почти всегда плохая идея.

## Когда использовать

- Любой тест уровня unit и выше.
- Demo / staging окружения с публичными примерами.
- Performance tests, где нужна реалистичная shape данных.

## Когда не использовать

- Production-данные напрямую в тестах (PII, риск утечки).
- "Real-world dataset" в unit-тестах — лишний шум.

## Production-паттерны

- **Минимум полей** на каждый тест: только то, что важно для сценария.
- **Детерминированные ids**: ULID/UUID с фиксированным seed или счётчиком.
- **Synthetic generation**: faker / mimesis с seeded RNG, единый stable seed на тест.
- **Permission grid**: матрица "роль × ресурс × action" для access-control тестов.
- **Boundary samples**: пустая строка, max length, юникод, leading/trailing spaces, инъекции — отдельные test cases.
- **Anonymisation pipeline** при использовании дампов: detect PII → mask → seed.

## Частые ошибки

- Импорт реальной production-БД "для воспроизводимости бага" с PII внутри.
- Тестировать только средние значения, не edge cases.
- Использовать одинаковые ids в разных тестах — конфликты при параллельном run.
- Сидерные скрипты, которые невозможно воспроизвести (зависимость от текущего времени / external API).

## Security risks

PII в репо, утечка через CI artifacts, dump-файлы в Slack / тикетах, тестовые credentials, мигрирующие в production.

## Performance risks

Гигантские seed-наборы замедляют integration suite; тестовые БД растут до десятков ГБ без cleanup.

## Testing strategy

- Lint: запрет на real-emails (`@gmail.com`, `@yandex.ru`) в test data, кроме `*@example.com`.
- Smoke на seed: повторный запуск даёт идентичный результат.
- Coverage по boundary cases отдельно от happy path.

## Edge cases

- Locale: ru/en/ar/zh данные, RTL текст, эмодзи, surrogates.
- Time-zones: фиксировать UTC и тестировать конкретные TZ-сценарии.
- Money: разные валюты, decimal precision, отрицательные значения.
- IDs из разных систем (Stripe payment_intent, Slack user_id) — фиксированные допустимые форматы.

## Источники

- [GDPR Test Data Guidance (ICO)](https://ico.org.uk/) — проверено 2026-05-24.
- См. [Fixtures](Fixtures.md), [Integration testing](Integration-testing.md), [Mocks](Mocks.md), [Secrets](../05-auth-security/Secrets.md).
