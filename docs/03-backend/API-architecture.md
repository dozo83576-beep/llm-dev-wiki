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

