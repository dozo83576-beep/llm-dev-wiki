---
title: "Vector databases"
category: "ai-tools"
updated: "2026-05-24"
status: "active"
tags: ["vector-db", "rag"]
source_priority: "internal"
---

# Vector databases

Выбор: Qdrant для отдельного vector store, pgvector для простоты внутри PostgreSQL, managed search если важна эксплуатация без DevOps.

Критерии: filters, hybrid search, backup, latency, cost, deployment model, observability.

## Когда использовать

Используй vector database для semantic search, RAG, recommendations, duplicate detection и similarity matching на больших корпусах.

## Когда не использовать

Не добавляй vector DB для маленькой базы знаний, где keyword search или managed File Search покрывает задачу дешевле.

## Production-паттерны

Metadata filters, embedding model version, backup/restore, reindexing pipeline, evals, latency and cost monitoring.

## Частые ошибки

Выбирать DB по hype, не тестировать retrieval quality, не иметь backup, не учитывать tenant/data isolation.

## Проверка

Retrieval evals, filter tests, restore drill, load smoke, cost estimate.

## Edge cases

- Migration между БД: переэкспорт embeddings, переиндекс, dual-read window.
- Hybrid retrieval: BM25 + vectors — Qdrant и Elastic поддерживают нативно, для pgvector нужен ts_vector + UNION.
- Multi-tenant: либо одна коллекция с metadata-filter, либо коллекция на tenant (security ↑, ops ↑).
- Cold-start: пустой index возвращает шум — fallback на дефолтный ответ / keyword.
- ANN parameters tuning: efSearch (HNSW), `lists` (IVFFlat) — после рост объёма.

## Security risks

Tenant isolation через payload-фильтр без back-end проверки — обходим клиентом; утечка embeddings (можно восстановить часть исходного текста по векторам); открытые admin порты.

## Источники

См. [Qdrant](Qdrant.md), [pgvector](../04-databases/pgvector.md), [RAG](RAG.md), [Embeddings](Embeddings.md), [RAG file search](../14-llm-indexing/rag-file-search.md).

