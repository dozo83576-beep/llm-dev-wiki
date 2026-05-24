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

## Когда использовать

Определяй tool permissions перед любым agent workflow, где есть filesystem, GitHub, DB, browser, deploy, cloud или внешние API.

## Когда не использовать

Не выдавай write permissions, если задача сводится к чтению, анализу, ревью или планированию.

## Частые ошибки

Один token для dev/staging/prod, отсутствие confirmation gates, broad filesystem access, неограниченные shell commands.

## Проверка

Permission matrix, audit logs, dry-run destructive commands, review enabled tools before execution.

## Источники

См. [MCP read-only default](../../patterns/ai/mcp-read-only-default.md), [Prompt injection](Prompt-injection.md).

