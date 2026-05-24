---
title: "Урок: authorization живет на сервере"
date: "2026-05-24"
project_type: "admin"
tags: ["authorization", "security", "backend"]
---

# Вывод

Frontend может улучшать UX, но не может быть источником истины для прав доступа.

# Контекст

Скрытая кнопка не защищает endpoint от прямого HTTP-запроса.

# Новое правило

Каждый sensitive endpoint требует server-side permission check и negative test.

# Обновленные документы

[Deny by default](../patterns/security/deny-by-default.md), [Tenant isolation](../patterns/security/tenant-isolation.md), [client-only permission failure](../case-studies/failures/2026-05-24-client-only-permission-check.md).

