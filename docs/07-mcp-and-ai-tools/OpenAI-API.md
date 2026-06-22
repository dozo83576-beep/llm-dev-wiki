---
title: "OpenAI API"
category: "ai-tools"
updated: "2026-06-22"
status: "active"
tags: ["openai", "api"]
source_priority: "official-docs"
---

# OpenAI API

Для приложений используй актуальные OpenAI API: Responses API, tools, structured outputs, file search, web search и agents там, где нужен workflow с инструментами.

Правила: не передавать секреты в prompt, логировать request id и usage, ограничивать tool permissions, делать evals для AI-функций.

Источник: [OpenAI Platform Docs](https://platform.openai.com/docs) и [OpenAI Python SDK on PyPI](https://pypi.org/project/openai/) — refreshed against `openai` 2.43.0 on 2026-06-22.

## Когда использовать

Используй OpenAI API для chat, structured extraction, tool-use agents, RAG/File Search, embeddings, classification и генерации контента.

## Когда не использовать

Не используй LLM для deterministic бизнес-правил, security decisions без проверки, billing logic и задач, где простая функция надежнее.

## Production-паттерны

Structured outputs, tool allowlist, request ids, usage/cost logging, evals, retries с backoff, timeout, content filtering по домену.

## Частые ошибки

Передавать secrets в prompt, не ограничивать tool calls, не делать evals, игнорировать latency/cost, не хранить traceability для ответов.

## Проверка

Evals, integration tests с mocked API, budget alerts, refusal/security probes, schema validation для structured output.

Для сайтов с AI-консультантом используй [AI chat widget](AI-chat-widget.md): prompt и lead handoff проектируются отдельно, а provider key остаётся только на backend/serverless boundary.
