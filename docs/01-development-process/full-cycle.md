---
title: "Полный цикл разработки"
category: "process"
updated: "2026-05-24"
status: "active"
tags: ["process", "delivery"]
source_priority: "internal"
---

# Полный цикл разработки

1. Discovery: цель, аудитория, бизнес-ограничения, контент, роли пользователей, интеграции.
2. Критерии приемки: измеримые сценарии, которые показывают, что проект готов.
3. Выбор стека: по типу продукта, команде, срокам, нагрузке, интеграциям и бюджету.
4. Архитектура: frontend, backend, данные, auth, API, очереди, интеграции, deploy.
5. Дизайн данных: сущности, связи, индексы, миграции, audit log, backup.
6. API-контракты: REST/OpenAPI, ошибки, пагинация, версии, rate limits.
7. Frontend: маршруты, компоненты, состояние, формы, доступность, performance budgets.
8. Backend: модули, сервисы, валидация, транзакции, логирование, ошибки.
9. Тестирование: unit, integration, E2E, contract, security, load по рискам.
10. Security review: OWASP, секреты, authz, CORS/CSRF/CSP, dependency scan.
11. Деплой: environment variables, migrations, rollback, monitoring, alerts.
12. Knowledge capture: success/failure кейсы, lessons learned, обновленные чеклисты.

Результат каждого этапа должен быть проверяемым: документ, тест, diff, скриншот, лог, метрика или ссылка на deploy.

