---
title: "AI UI streaming"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["ai", "streaming", "chat", "frontend"]
source_priority: "mixed"
---

# AI UI streaming

AI UI streaming covers chat, generation, tool calls, partial responses, cancellation and telemetry. The UI must make model uncertainty and long-running work visible without leaking secrets or losing state.

## Когда использовать

- Product has chat, content generation, agent workflows, RAG answers or streaming assistants.
- Responses can take seconds and users need progress, cancellation and retry.
- Tool calls, citations, attachments or structured outputs are visible in UI.
- Cost, latency and safety need product-level observability.

## Когда не использовать

- One-shot backend AI job with no interactive UI.
- Deterministic form workflow where regular async submit state is enough.
- Prototype without rate limit, logging and abuse controls.

## Production-паттерны

- Stream text/events through server boundary; client never owns provider API keys.
- UI states include queued, streaming, tool-running, blocked, cancelled, error, done and retry.
- Persist conversation/message ids before streaming starts so refresh/retry can recover.
- Tool calls render as explicit steps with user-safe labels, not raw internal payload.
- Citations and retrieved sources are displayed with confidence/limitations where relevant.
- Telemetry tracks latency, token cost, model, route, retrieval quality and user cancellation.

## Частые ошибки

- Streaming directly from browser to provider with exposed keys.
- Losing conversation state on refresh or network drop.
- Showing tool internals, secrets or untrusted HTML.
- No cancel button, timeout or rate limit.
- Treating streamed text as final before safety/post-processing finishes.

## Security risks

Prompt injection, XSS in generated markdown, data exfiltration through tools, file upload abuse, PII leakage in logs and over-broad tool permissions are release blockers.

## Performance risks

Long context, slow retrieval, sequential tool calls, no backpressure and large markdown rendering can make UI feel broken. Use progressive rendering and timeouts.

## Testing strategy

Test stream happy path, cancellation, retry, provider error, slow retrieval, tool call visible state, markdown sanitization, rate limit, auth boundary and telemetry events.

## Edge cases

User navigates away mid-stream, duplicate submit, model emits invalid JSON, citation source deleted, tool call fails after partial text, content moderation blocks final answer.

## Источники

- [Vercel AI SDK](https://vercel.com/ai-sdk) — refreshed against `ai` 6.0.199 on 2026-06-10.
- [OpenAI Platform Docs](https://platform.openai.com/docs) — refreshed 2026-06-06.
- См. [AI/RAG app playbook](../13-playbooks/ai-rag-app.md), [OpenAI API](../07-mcp-and-ai-tools/OpenAI-API.md), [Evaluation](../07-mcp-and-ai-tools/Evaluation.md), [Prompt injection](../07-mcp-and-ai-tools/Prompt-injection.md).
