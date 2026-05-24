---
title: "Authorization"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["authorization", "permissions"]
source_priority: "internal"
---

# Authorization

Authorization отвечает на вопрос "что пользователь может сделать". Проверяй права на сервере для каждого действия и объекта.

Правила: deny by default, object-level permissions, tenant isolation, tests на чужие ID, audit для privilege changes.

