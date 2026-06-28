---
title: "Codex MCP setup"
category: "ai-tools"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["mcp", "codex", "setup"]
source_priority: "official-docs"
---

# Codex MCP setup

Codex CLI и Codex web-агент работают с MCP через плагины и встроенные инструменты. Цель — дать минимально достаточный набор серверов для текущей задачи и удерживать read-only по умолчанию.

## Когда использовать

При первичной настройке Codex, при добавлении нового плагина или при переходе с одного провайдера документации на другой.

## Когда не использовать

Не используй этот документ как замену AGENTS.md проекта — он описывает только подключение инструментов, а не правила работы агента.

## Production-паттерны

- GitHub-плагин с минимальными scopes; для public-only тасков — без `repo` write.
- Browser-плагин включается только под конкретный web target, отключается после задачи.
- OpenAI Developers (Agents SDK, embeddings, API reference) — read-only документация.
- Vercel/Cloudflare/Render — deploy logs и метаданные, mutations через подтверждение.
- context7 — актуальная документация библиотек, кешируется локально для воспроизводимости.
- Перед началом работы агент читает корневой [AGENTS.md](../../AGENTS.md), затем relevant docs и chekclists.

## Частые ошибки

- Включить production DB или billing плагин по умолчанию.
- Хранить токены в shell history или в незашифрованных env-файлах.
- Не обновлять список плагинов при смене проекта — лишние серверы остаются доступными.

## Security risks

Tool poisoning из docs MCP (поддельный README с инструкциями), exfiltration через logs, prompt injection из browser-плагина, неавторизованные deploy-mutations.

## Проверка

- Запустить агента с пустым запросом "перечисли активные tools и их scopes", сверить с ожидаемым набором.
- Прогон [MCP security review](../../prompts/mcp-security-review.md) при добавлении нового плагина.
- Hello-world запрос для каждого плагина: что возвращает, какие данные, есть ли неожиданные мутации.

## Edge cases

- Codex web vs Codex CLI: разные наборы плагинов, не предполагай parity.
- Несколько профилей (личный, команда): отдельные credentials, не делить токены.
- Долго работающие session-агенты: периодически перечитывать AGENTS.md, иначе устаревшая политика.

## Источники

- [Model Context Protocol Docs](https://modelcontextprotocol.io/docs) — проверено 2026-05-24.
- [OpenAI Platform Docs](https://platform.openai.com/docs) — проверено 2026-05-24.
- См. [MCP security](../05-auth-security/MCP-security.md), [Recommended MCP servers](Recommended-MCP-servers.md), [Tool permissions](Tool-permissions.md).
