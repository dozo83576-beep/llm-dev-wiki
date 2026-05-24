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

