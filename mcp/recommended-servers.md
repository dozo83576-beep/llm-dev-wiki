# Recommended MCP servers

## Базовый набор

- GitHub: repository metadata, issues, pull requests, code review context.
- Filesystem: работа только внутри текущего проекта или vault.
- Browser: локальная проверка UI, screenshots, клики, формы.
- Documentation: актуальная документация библиотек и SDK.
- Database: read-only диагностика; write только с явным подтверждением.
- Vercel/Cloudflare/Render: deploy logs, project metadata, preview URLs.

## Политика прав

Read-only по умолчанию. Запись, удаление, deploy, DNS, billing, secrets и production database требуют отдельного подтверждения.

Источник: [MCP Docs](https://modelcontextprotocol.io/docs).

