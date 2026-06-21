---
name: site-backend
description: >-
  Фаза реализации backend сайта в D:\Work: модули, сервисы, валидация, транзакции, фоновые задачи,
  логирование, обработка ошибок и серверная граница безопасности (auth, секреты, идемпотентность
  вебхуков). Использовать при написании API, серверной логики, интеграций (платежи, email, Telegram, AI)
  или работе с БД. Маршрутизирует в implement-backend, backend/database-доки и паттерны D:\Work\llm-dev-wiki.
---

# site-backend — реализация backend

Тонкий роутер. Источник правды — `D:\Work\llm-dev-wiki`. Секреты и валидация — всегда на серверной границе.

## Requires
- `site-architecture` завершён (API-контракты, модель данных, план этапов с acceptance).

## Сначала прочитай
- `D:\Work\llm-dev-wiki\prompts\implement-backend.md` — каркас реализации.
- `D:\Work\llm-dev-wiki\prompts\design-database.md`, `database-migration-review.md` — данные и миграции.
- `D:\Work\llm-dev-wiki\docs\03-backend\` и `docs\04-databases\` — профильные доки выбранного стека.
- `D:\Work\llm-dev-wiki\patterns\backend\` (service-layer, webhook-idempotency, background-job-retry,
  telegram-lead-notification), `patterns\database\`, `patterns\security\`.
- `D:\Work\llm-dev-wiki\checklists\backend-review.md`, `database-review.md`, `api-review.md`.
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\External-site-skills.md` — optional helpers
  `senior-backend`, `api-design-reviewer`, `database-designer`, если они установлены.

## Шаги
1. Реализуй модули/сервисы по плану: service-layer, явные границы, DI где уместно.
1.5. Если доступны backend/API/database helpers, используй их для ревью контрактов и схем; итоговые решения
   сверяй с локальными prompts/checklists.
2. Валидация входных данных на сервере; идемпотентность для вебхуков/повторов; транзакции для согласованности.
3. Фоновые задачи с retry; явное логирование; аккуратная обработка ошибок и контракт ошибок API.
4. Auth/authz по deny-by-default и tenant isolation; секреты только из env, никогда в код/логи.
5. Unit/integration-тесты, dry-run для рискованных операций, ≥5 edge cases.

## Quality gate
- Проходит `checklists\backend-review.md`, `database-review.md`, `api-review.md` (нет block-пунктов).
- Нет секретов в коде/логах; миграции обратимы (expand-contract).
- Рискованные операции имеют dry-run или план отката.
- Проверяет: review-чеклисты как self-check + прогон тестов (tool).

## Передача дальше
`site-review` — сводное ревью перед релизом.
