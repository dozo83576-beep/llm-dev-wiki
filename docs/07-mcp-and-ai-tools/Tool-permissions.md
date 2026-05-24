---
title: "Tool permissions"
category: "ai-tools"
updated: "2026-05-24"
status: "active"
tags: ["mcp", "permissions"]
source_priority: "internal"
---

# Tool permissions

Tool permissions определяют, что агент может читать, писать, запускать и деплоить. Ошибка прав превращает обычный промпт в production-инцидент.

## Уровни доступа

- Read-only: документация, репозиторий, логи без секретов.
- Workspace write: изменения только в текущем проекте.
- External write: issues, PR, comments, docs.
- Production mutation: deploy, DNS, DB writes, billing, secrets.

## Правила

- По умолчанию read-only.
- Production mutation только с явным подтверждением.
- Destructive operations требуют dry-run.
- Секреты не передаются в model context.

