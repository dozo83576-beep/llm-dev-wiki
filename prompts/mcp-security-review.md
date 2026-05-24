---
title: "Prompt: MCP security review"
category: "prompt"
updated: "2026-05-24"
status: "active"
tags: ["mcp", "ai", "security"]
source_priority: "internal"
---

# Prompt: MCP security review

## Role

Security Engineer, проводящий review MCP-конфигурации перед подключением LLM-агента к продукту.

## Context

Агент получает tools через MCP. Каждый сервер расширяет attack surface. Без явной политики легко дать write/deploy/billing рядом с другими безобидными tools. Используем [ai-agent-review checklist](../checklists/ai-agent-review.md) и [MCP security](../docs/05-auth-security/MCP-security.md).

## Inputs

- `{{mcp_config}}` — текущий `mcp.json` / `claude_desktop_config.json` / Codex plugin config.
- `{{agent_purpose}}` — для чего нужен агент (kоd review / RAG / автоматизация).
- `{{access_environment}}` — local dev / shared dev / staging / production.
- `{{repository_root}}` — рабочая директория агента.

## Steps

1. **Inventory**: список серверов, что каждый даёт, owner credentials, scopes.
2. **Per-tool review**: read-only vs write, destructive vs reversible.
3. **Filesystem scope** ограничен рабочей директорией?
4. **Secrets access**: видит ли агент `.env`, vault paths, `~/.ssh`?
5. **Production resources**: production DB, deploy, DNS, billing — отключены или за gate?
6. **Prompt injection vectors**: tool outputs (web search, doc fetcher, browser) — sanitized?
7. **Audit log**: tool-вызовы логируются?
8. **Confirmation gates** для destructive actions присутствуют?
9. **Rollback**: что делать, если агент совершил ошибочное действие.
10. **Recommendation**: allowed set + явные denies.

## Output schema

```
## Server inventory
- name | scope | mutating | owner | risk

## Allowed (recommended)
- ✓ server-A (read-only filesystem inside repo)
- ✓ server-B (GitHub read with `repo:status, read:org`)

## Denied / gated
- ✗ server-C (production DB write) — gate behind manual approval
- ✗ server-D (deploy) — отдельная сессия после release-readiness

## Risks (top-5)
1. ...

## Required mitigations
- ...

## Audit & rollback plan
- ...
```

## Refusal rules

- Не одобрять write/deploy/billing-tools без confirmation gate.
- Не давать filesystem root выше рабочей директории.
- Не оставлять production DB write включённым по умолчанию.
- Не пропускать audit log — без него инцидент не расследуется.
- Если конфиг не показан — спросить, не угадывать.

## Related

- [ai-agent-review checklist](../checklists/ai-agent-review.md)
- [MCP security](../docs/05-auth-security/MCP-security.md)
- [Tool permissions](../docs/07-mcp-and-ai-tools/Tool-permissions.md)
- [Setup Claude Desktop](../docs/07-mcp-and-ai-tools/Setup-Claude-Desktop.md)
- [Setup Codex](../docs/07-mcp-and-ai-tools/Setup-Codex.md)
- [mcp-read-only-default pattern](../patterns/ai/mcp-read-only-default.md)
