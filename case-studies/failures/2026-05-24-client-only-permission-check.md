---
title: "Ошибка: проверка прав только на клиенте"
project_type: "admin"
stack: ["React", "API"]
severity: "critical"
date: "2026-05-24"
tags: ["authorization", "security", "frontend"]
---

# Что пошло не так

UI скрывал кнопку удаления для обычного пользователя, но backend endpoint не проверял object-level permission.

# Причина

Authorization была реализована как UI-состояние, а не как серверный инвариант.

# Как проявилось

Пользователь мог отправить HTTP-запрос напрямую и удалить чужой объект.

# Как исправили

Добавили серверную проверку actor + target + tenant, deny-by-default policy и negative integration tests.

# Как не повторять

- Любой sensitive action проверяется на backend.
- Frontend guard считается UX-слоем, не security-слоем.
- Каждый endpoint получает negative permission tests.

# Анти-паттерн

Не делай authorization через скрытие кнопок, если backend endpoint остается доступным.

# Связанные чеклисты

[Security review](../../checklists/security-review.md), [Deny by default](../../patterns/security/deny-by-default.md).

