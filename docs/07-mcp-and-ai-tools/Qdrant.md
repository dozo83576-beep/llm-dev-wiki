---
title: "Qdrant"
category: "ai-tools"
updated: "2026-07-21"
status: "active"
tags: ["qdrant", "vector-db"]
source_priority: "official-docs"
---

# Qdrant

Qdrant подходит для production vector search, metadata filtering и RAG. Используй collections по типам знаний или единый индекс с сильной metadata-схемой.

Источник: [Qdrant Documentation](https://qdrant.tech/documentation/) и [Qdrant releases](https://github.com/qdrant/qdrant/releases) — v1.18.3 reviewed 2026-07-21; collection/filter guidance unchanged.

## Когда использовать

Используй Qdrant для production RAG, высокой нагрузки vector search, metadata filtering, отдельной эксплуатации vector store и гибкой retrieval architecture.

## Когда не использовать

Не добавляй Qdrant, если pgvector внутри PostgreSQL достаточно и отдельная инфраструктура увеличивает операционную сложность.

## Production-паттерны

Collections с понятной schema, payload metadata, backup/snapshot policy, reindex pipeline, retrieval evals, latency monitoring.

## Частые ошибки

Индексировать без source metadata, не планировать backup, не версионировать embeddings, не проверять фильтры tenant/category.

## Проверка

Retrieval evals, metadata filter tests, snapshot restore drill раз в квартал, load smoke перед запуском, p95 latency monitor.

## Edge cases

- HNSW vs scalar quantization — trade-off recall vs RAM.
- Sparse + dense (hybrid) поиск — Qdrant поддерживает с v1.10+.
- Shard configuration для большого объёма; репликация для HA.
- Payload index на часто-фильтруемых полях (tenant_id, category) — без него фильтр работает full scan.

## Security risks

Open Qdrant port без auth (исторически частая ошибка), API-keys в env без ротации, утечка через payload (PII в metadata), tenant boundary через payload-фильтр без RLS-аналога — нужны строгие тесты.

## Источники

- [Qdrant Documentation](https://qdrant.tech/documentation/) — refreshed 2026-06-06.
- [Qdrant releases](https://github.com/qdrant/qdrant/releases) — v1.18.3 checked 2026-07-21.
- См. [Vector databases](Vector-databases.md), [pgvector](../04-databases/pgvector.md), [RAG](RAG.md), [Embeddings](Embeddings.md).
