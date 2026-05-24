---
title: "Backend API architecture"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["api", "architecture"]
source_priority: "internal"
---

# Backend API architecture

Слои: transport/controller, validation DTO, application service, domain logic, repository/ORM, integration clients.

Правила: вход валидируется на границе, права проверяются до доступа к данным, транзакции охватывают целостную бизнес-операцию, ошибки возвращаются единым контрактом.

## Когда использовать

Всегда для backend, который обслуживает UI, external clients, webhooks или фоновые процессы. Архитектура особенно важна, когда есть роли, транзакции и интеграции.

## Когда не использовать

Не дроби маленький одноразовый endpoint на чрезмерное количество слоев, если нет доменной логики и повторного использования.

## Production-паттерны

Controller/route handler только принимает transport request. Service выполняет use case. Repository/ORM работает с данными. Integration client изолирует внешние API. Validation, authorization и transaction boundary явные.

## Частые ошибки

Бизнес-логика в controller, права после чтения данных, внешние HTTP-вызовы внутри долгой транзакции, разные форматы ошибок в разных endpoints.

## Проверка

Unit tests для services, integration tests для API+DB, negative permission tests и contract tests для внешних клиентов.

## Источники

См. [[Error-handling|Error handling]], [[../06-api-design/Error-contracts|API error contracts]], [[../../patterns/backend/service-layer|Service layer]].

