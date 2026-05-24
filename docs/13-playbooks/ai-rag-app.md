---
title: "Playbook: AI/RAG app"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["ai", "rag", "mcp", "llm"]
source_priority: "internal"
---

# Playbook: AI/RAG app

LLM-приложение, которое отвечает на пользовательские запросы, опираясь на собственную базу знаний и/или инструменты. Главный риск — hallucinations и prompt injection, поэтому evals и permission policy критичны.

## Когда использовать

- Чат / поиск / Q&A по корпусу документов.
- Агент с инструментами (внутренний копайлот, MCP-сервис).
- Customer support / sales-assistant с базой FAQ.

## Когда не использовать

- Задача решается классическим поиском (full-text / facets) — RAG дороже и шумнее.
- Нет качественных source-данных — RAG будет генерировать ложные ответы уверенным тоном.
- Жёсткие требования по детерминизму — LLM не даёт гарантий.

## Стек по умолчанию

Next.js + OpenAI API (или совместимый) + PostgreSQL/pgvector или Qdrant + ingestion pipeline + retrieval с citations + evals + tool permission policy + observability на token spend и retrieval quality.

## Порядок разработки

1. **Define answer domain**: что отвечаем, что отказываемся отвечать (refusal policy).
2. **Source curation**: какие документы, какая freshness, какая granularity.
3. **Metadata schema**: title, category, updated, source_priority, tags.
4. **Ingestion**: parse → chunk → embed → index. Версионирование модели embeddings.
5. **Retrieval**: filters по metadata, top-K, hybrid (BM25 + vectors) если нужно, reranking для сложных запросов.
6. **Generation**: prompt template, citations обязательны, refusal для out-of-domain.
7. **Prompt injection defenses**: trust boundary между system / user / tool output; sanitize HTML.
8. **Evals**: golden set, precision@K, refusal accuracy, freshness, adversarial prompts.
9. **Tool permission policy**: read-only по умолчанию, confirmation для writes.
10. **Monitoring**: token spend, latency, failed retrievals, user feedback (thumbs up/down).

## Production-паттерны

- Source citations в ответе (ссылка + дата документа).
- Versioning embeddings model и snapshot корпуса.
- Hybrid retrieval для precision-критичных задач.
- Guardrails: refusal patterns, classifier для запрещённых тем.
- Cost guardrails: max tokens per request, daily budget per user.

## Анти-паттерны

- Индексировать хаотичные документы без metadata — мусор на входе, мусор на выходе.
- Считать RAG решением hallucinations без evals.
- Давать агенту write-tools без permission policy и audit.
- Отдавать "сырой" tool-output модели как доверенный контекст.

## Security risks

Prompt injection через документы корпуса, tool poisoning, exfiltration через response, утечка API-ключей в системный prompt, кросс-tenant data leak через neighbour-chunks.

## Performance risks

Холодный embedding-API при импорте, чрезмерный context (cost + latency), reranker как боттлнек, неконтролируемый сценарий long-context для пользователей.

## Testing strategy

- Golden Q&A с expected_paths (top-K retrieval).
- Refusal tests: запросы вне домена → отказ с обоснованием.
- Adversarial prompt injection набор.
- Freshness тесты: documents с истёкшим updated не появляются в "current" ответах.
- Cost / token regression tests.

## Edge cases

- Long-context overflow — нужна суммаризация / sliding window.
- Multimodal (images / PDFs со сложным layout) — особые ingestion-пайплайны.
- Multi-language корпус — отдельные embedding spaces или multilingual модель.
- Streaming + tools (SSE с function calls) — особенности UX.

## Источники

- См. [RAG](../07-mcp-and-ai-tools/RAG.md), [RAG ingestion](../07-mcp-and-ai-tools/RAG-ingestion.md), [Prompt injection](../07-mcp-and-ai-tools/Prompt-injection.md), [Tool permissions](../07-mcp-and-ai-tools/Tool-permissions.md), [Evaluation](../07-mcp-and-ai-tools/Evaluation.md), [Agent workflows](../07-mcp-and-ai-tools/Agent-workflows.md), [ai-agent-review checklist](../../checklists/ai-agent-review.md).
