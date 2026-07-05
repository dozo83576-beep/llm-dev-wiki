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
- `site-architecture` завершён (API-контракты, модель данных, план этапов с acceptance — артефакт
  `_architecture.md` проекта) **и** `site-content` завершён, если у проекта есть визуальный
  контент/CMS (финальная контент-модель `_content-model.md` фиксирует точные data shapes для API —
  backend реализуется без недосказанностей). Для playbook `api-only-backend` без визуального UI
  это условие не применяется — достаточно завершённой архитектуры.

## Сначала прочитай
- Перед реализацией: `pwsh D:\Work\llm-dev-wiki\tools\ask-wiki.ps1 "<стек + интеграция/очереди/ошибки>"` — поднимет backend-паттерны и уроки.
- Слои контекста: project `AGENTS.md` → `D:\Work\AGENTS.md` → `AGENT-PREFERENCES.local.md` → вики — один раз за сессию, не перечитывать, если уже в контексте (правила — оркестратор `build-modern-site`).
- `D:\Work\llm-dev-wiki\prompts\implement-backend.md` — каркас реализации.
- `D:\Work\llm-dev-wiki\prompts\design-database.md`, `database-migration-review.md` — данные и миграции.
- `D:\Work\llm-dev-wiki\docs\03-backend\` и `docs\04-databases\` — только доки выбранного стека
  (runtime + БД из `_stack.md`, обычно 2–3 файла), не каталоги целиком.
- `D:\Work\llm-dev-wiki\docs\06-api-design\` — REST-конвенции, контракт ошибок, идемпотентность,
  пагинация — сверяй реализацию эндпоинтов с ними.
- `patterns\backend\`, `patterns\database\`, `patterns\security\` — выборочно через
  `ask-wiki.ps1 "<стек + интеграция>"` (top-2–3, напр. service-layer, webhook-idempotency,
  background-job-retry), не каталоги целиком.
- `D:\Work\llm-dev-wiki\checklists\backend-review.md`, `database-review.md`, `api-review.md`.
- `D:\Work\llm-dev-wiki\docs\05-auth-security\RU-152fz-and-ai-data-handling.md` — при работе с
  реальными клиентскими данными/дампами БД для отладки деперсонализировать перед отправкой в
  облачный AI.
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
6. **Артефакт.** Сохрани в корень проекта `_backend-gate.md`: статусы backend/database/api-review
   чек-листов (block/warn), фактический вывод прогона тестов, покрытые edge cases, известные
   ограничения. Это evidence фазы для `_pipeline-status.md` и вход для `site-review`.

## Quality gate
- Проходит `checklists\backend-review.md`, `database-review.md`, `api-review.md` (нет block-пунктов).
- Результаты зафиксированы в `_backend-gate.md` проекта.
- Для playbook `ai-rag-app`: evals/golden-set precision@K и refusal accuracy пройдены
  (`D:\Work\llm-dev-wiki\prompts\rag-design.md`) — это отдельный gate, не заменяется backend-review.
- Нет секретов в коде/логах; миграции обратимы (expand-contract).
- Рискованные операции имеют dry-run или план отката.
- Проверяет: review-чеклисты как self-check + прогон тестов (tool).

## Передача дальше
`site-frontend` — реализация UI против уже работающего backend (реальные эндпоинты, не бумажный
контракт), строго последовательно, без параллельного трека.
