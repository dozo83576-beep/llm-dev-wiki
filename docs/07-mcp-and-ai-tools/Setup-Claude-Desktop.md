---
title: "Claude Desktop MCP setup"
category: "ai-tools"
updated: "2026-05-24"
status: "active"
tags: ["mcp", "claude-desktop", "setup"]
source_priority: "official-docs"
---

# Claude Desktop MCP setup

Claude Desktop хранит MCP-серверы в `claude_desktop_config.json`. Подключай только то, что нужно конкретному workflow, и держи права минимальными.

## Когда использовать

Используй этот документ при первичной настройке Claude Desktop или при добавлении нового MCP-сервера в существующий конфиг.

## Когда не использовать

Не используй для production-агентов на сервере — там нужен отдельный runtime, audit log и secret manager, а не локальный config-файл.

## Production-паттерны

- Filesystem-сервер ограничен явным списком директорий (workspace, vault) — никаких `~/` или `/`.
- GitHub-сервер с personal access token минимальных scopes (`repo:status`, `read:org` для read-only, `repo` только если действительно нужны write-операции).
- Browser/Playwright только для локальных web targets и dev-окружений, не для production URL-ов.
- Documentation/context7 — для актуальной документации библиотек, всегда read-only.
- Database-сервер запускается в read-only режиме (`DATABASE_URL` с read-only ролью); write-сценарии — отдельный конфиг с явным confirmation gate.
- Все credentials хранятся в системном keychain или env, а не в JSON в открытом виде.

## Частые ошибки

- Дать filesystem root выше рабочей директории — модель видит чужие проекты и секреты.
- Один токен GitHub с админ-правами на всю организацию.
- Оставить production DB MCP включённым "на всякий случай".
- Не делать инвентаризацию серверов перед обновлением Claude Desktop — забытые серверы продолжают работать.

## Security risks

Tool poisoning, prompt injection из tool output, утечка секретов через logs, неявное выполнение команд при автозапуске серверов на старте Claude Desktop.

## Проверка

- Открыть конфиг, прочитать список серверов, для каждого ответить на вопросы: зачем нужен, какие права, кто owner credentials, когда последний раз ревьюился.
- Прогон [MCP security review](../../prompts/mcp-security-review.md) перед добавлением нового сервера.
- Dry-run write-операций до того, как они станут default-доступными.

## Edge cases

- Несколько workspace-ов: разные filesystem-серверы, не глобальный root.
- CI-агенты: не используй Claude Desktop конфиг, поднимай headless MCP-runtime отдельно.
- Обновление Claude Desktop может перезаписать или сбросить конфиг — храни копию в личном dotfiles-репо без секретов.

## Источники

- [Model Context Protocol Docs](https://modelcontextprotocol.io/docs) — проверено 2026-05-24.
- [Claude Desktop MCP Quickstart](https://modelcontextprotocol.io/quickstart) — проверено 2026-05-24.
- См. [MCP security](../05-auth-security/MCP-security.md), [Recommended MCP servers](Recommended-MCP-servers.md), [Tool permissions](Tool-permissions.md).
