---
title: "AI agent review checklist"
category: "checklist"
updated: "2026-06-07"
status: "active"
tags: ["ai", "mcp", "agent", "security"]
source_priority: "internal"
---

# AI agent review checklist

Gated checklist для запуска нового AI-агента (LLM с инструментами, MCP, RAG). Формат: критерий — проверка — owner — severity — ссылка.

## Tool inventory

- [ ] **Tool list** документирован: имя, scope, mutating/read-only, owner credentials — AI owner — block — [Tool permissions](../docs/07-mcp-and-ai-tools/Tool-permissions.md).
- [ ] **Read-only по умолчанию**; write/deploy/billing требуют явного approval — AI owner — block — [MCP security](../docs/05-auth-security/MCP-security.md).
- [ ] **Filesystem scope** ограничен рабочей директорией проекта/vault — AI owner — block.
- [ ] **Production DB** доступен только read-only; write — отдельный gated tool — AI owner — block.

## Permissions

- [ ] **Минимальные scopes** на каждый OAuth-token / API key — AI owner — block — [mcp-read-only-default pattern](../patterns/ai/mcp-read-only-default.md).
- [ ] **Confirmation gates** для destructive actions (delete, drop, refund, deploy) — AI owner — block.
- [ ] **Audit log** tool-вызовов сохраняется — AI owner — warn.

## Prompt safety

- [ ] **System prompt** изолирован от user-input и tool-output — AI owner — block — [Prompt injection](../docs/07-mcp-and-ai-tools/Prompt-injection.md).
- [ ] **Tool output sanitization**: не интерпретируется как инструкция модели — AI owner — block.
- [ ] **Refusal policy** определена (out-of-domain, harmful, jailbreak) — AI owner — warn.
- [ ] **Prompt injection eval set** прогнан — AI owner — warn — [Evaluation](../docs/07-mcp-and-ai-tools/Evaluation.md).

## Data privacy

- [ ] **Агент не видит** секреты, PII, приватные данные клиентов — security owner — block — [Agent memory](../docs/07-mcp-and-ai-tools/Agent-memory.md).
- [ ] **Контекст**, отправляемый в LLM-провайдер, документирован — security owner — warn.
- [ ] **Data retention** на стороне провайдера учтена (opt-out если возможно) — security owner — warn.

## Behaviour

- [ ] **План действий** формулируется до изменений (write-операции) — AI owner — block.
- [ ] **Dry-run** для destructive операций — AI owner — block.
- [ ] **Изменения проверены** командой / тестами, а не только описаны в ответе — tech lead — block.
- [ ] **Stop conditions** определены: когда агент должен спросить, а не действовать — AI owner — warn.

## Knowledge capture

- [ ] **Успешные приёмы** сохранены в [case-studies/successes](../case-studies/successes) или [patterns](../patterns) — tech lead — warn.
- [ ] **Ошибки** сохранены в [case-studies/failures](../case-studies/failures) с правилом предотвращения — tech lead — block.
- [ ] **Learning review** выполнен: новый опыт сохранён или явно указано `no artifact needed` — tech lead — warn — [Agent self-improvement loop](../docs/07-mcp-and-ai-tools/Agent-self-improvement.md).
- [ ] **MCP / agent config** в репо как код, ревьюится через PR — AI owner — warn — [Setup Claude Desktop](../docs/07-mcp-and-ai-tools/Setup-Claude-Desktop.md), [Setup Codex](../docs/07-mcp-and-ai-tools/Setup-Codex.md).

## Evals

- [ ] **Golden Q&A** прогнан для RAG/retrieval компонентов — AI owner — warn — [RAG](../docs/07-mcp-and-ai-tools/RAG.md), [golden-qa.yaml](../docs/14-llm-indexing/golden-qa.yaml).
- [ ] **Cost / latency budget** определён и мониторится — AI owner — warn.
- [ ] **Regression suite** запускается до prompt/model/tool changes — AI owner — block.
