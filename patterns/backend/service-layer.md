---
title: "Pattern: Service layer"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["backend", "architecture"]
---

# Service layer

Controller отвечает за transport, service — за бизнес-операцию, repository/ORM — за данные. Это снижает связанность и упрощает тесты.

Проверка: бизнес-правила не должны жить в route handler/controller.

