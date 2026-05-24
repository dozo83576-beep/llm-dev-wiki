---
title: "Recommended MCP servers"
category: "ai-tools"
updated: "2026-05-24"
status: "active"
tags: ["mcp", "tools"]
source_priority: "internal"
---

# Recommended MCP servers

Рекомендуемый набор:

- GitHub: issues, PR, repo metadata, code review context.
- Filesystem: read/write только в рабочей директории проекта.
- Browser: проверка UI, screenshots, локальные web targets.
- Documentation search: актуальные docs по библиотекам.
- Database: read-only для диагностики, write только с подтверждением.
- Vercel/Cloudflare/Render: deploy и logs, production mutations через подтверждение.

По умолчанию MCP работает в read-only режиме.

## Когда использовать

Подключай server только когда он нужен текущему workflow: GitHub для PR/issues, Browser для UI, docs search для актуальной документации, DB для диагностики.

## Когда не использовать

Не подключай production DB, deploy, DNS, billing или secrets MCP без конкретной задачи, owner и confirmation policy.

## Production-паттерны

Минимальные scopes, отдельные credentials, read-only default, audit logs, documented purpose, periodic review of enabled servers.

## Частые ошибки

Оставить write tools включенными постоянно, дать filesystem root выше workspace, не ограничить database queries, не отключать unused servers.

## Проверка

MCP inventory review, permission review, dry-run для write tools, secret exposure check.

## Источники

См. [MCP overview](MCP-overview.md), [Tool permissions](Tool-permissions.md), [MCP security](../05-auth-security/MCP-security.md).

