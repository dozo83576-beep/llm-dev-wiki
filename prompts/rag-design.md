---
title: "Prompt: RAG design"
category: "prompt"
updated: "2026-05-24"
status: "active"
tags: ["rag", "ai", "design"]
source_priority: "internal"
---

# Prompt: RAG design

## Role

Senior AI Engineer, проектирующий RAG (retrieval-augmented generation) поверх корпуса документов.

## Context

Нужен chat / search / Q&A с цитированием по собственной базе знаний. Решение должно покрыть весь pipeline (ingestion → retrieval → generation → evals), а не только "выбрать модель embeddings".

## Inputs

- `{{corpus_description}}` — что за корпус (docs / tickets / wiki / mixed).
- `{{size}}` — объём (документов / GB / tokens).
- `{{access_model}}` — публичный / per-tenant / privacy-sensitive.
- `{{usage}}` — чат / поиск / suggest / agent-tool.
- `{{constraints}}` — latency / cost / on-prem / vendor lock-in.

## Steps

1. **Source curation**: какие документы in / out. Что точно не индексируем.
2. **Metadata schema**: фронт-матер: title, category, tags, updated, source_priority, visibility, tenant_id.
3. **Chunking policy**: по `##` / `###` с metadata propagation (см. [chunking-policy](../docs/14-llm-indexing/chunking-policy.md)).
4. **Embeddings model**: provider, версия, dimension, multilingual?
5. **Vector store**: pgvector vs Qdrant vs managed; обоснование.
6. **Retrieval**: top-K, filters, hybrid (BM25 + vectors)?, reranker?
7. **Citation format**: path + section heading; обязательны.
8. **Generation**: prompt template, refusal policy, response schema.
9. **Prompt injection defenses**: trust boundary, sanitization, structured output.
10. **Privacy exclusions**: что физически не должно попасть в index.
11. **Freshness policy**: cadence reindex, watch для критичных source.
12. **Evals**: golden Q&A, precision@K, refusal accuracy, adversarial injection.
13. **Monitoring**: token spend, latency, failed retrieval, user feedback.

## Output schema

```
## Sources & exclusions
## Metadata schema
## Chunking policy
## Embeddings (model, version, dimension)
## Vector store + why
## Retrieval pipeline (filters, top-K, hybrid?, rerank?)
## Citation format
## Prompt template (system / user / tool boundaries)
## Refusal & safety
## Privacy exclusions
## Freshness policy + reindex cadence
## Evals
- golden set: ...
- metrics: precision@5, refusal accuracy, ...
## Monitoring
## Roll-out plan (POC → soft-launch → GA)
```

## Refusal rules

- Не индексировать все документы подряд без `status: active` фильтра.
- Не использовать tool/retrieval output как доверенный context модели (prompt injection).
- Не отдавать ответ без citations.
- Не запускать в production без golden Q&A и baseline precision@K.
- Не смешивать embeddings разных моделей в одном space без версии.

## Related

- [RAG](../docs/07-mcp-and-ai-tools/RAG.md)
- [RAG ingestion](../docs/07-mcp-and-ai-tools/RAG-ingestion.md)
- [Vector databases](../docs/07-mcp-and-ai-tools/Vector-databases.md)
- [chunking-policy](../docs/14-llm-indexing/chunking-policy.md)
- [metadata-policy](../docs/14-llm-indexing/metadata-policy.md)
- [Prompt injection](../docs/07-mcp-and-ai-tools/Prompt-injection.md)
- [Evaluation](../docs/07-mcp-and-ai-tools/Evaluation.md)
- [ai-rag-app playbook](../docs/13-playbooks/ai-rag-app.md)
