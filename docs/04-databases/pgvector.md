---
title: "pgvector"
category: "database"
updated: "2026-06-22"
status: "active"
tags: ["pgvector", "rag", "postgresql"]
source_priority: "official-docs"
---

# pgvector

pgvector добавляет vector search в PostgreSQL. Это хороший первый выбор, если knowledge base небольшая или хочется избежать отдельной vector DB.

Freshness note: pgvector v0.8.3 is a version bump release; index, distance operator and embedding namespace guidance remains unchanged.

## Когда использовать

Используй pgvector для RAG, semantic search и similarity matching, когда данные уже живут в PostgreSQL и нагрузка vector search умеренная.

## Production-паттерны

- Храни embedding вместе с source metadata.
- Используй filters по category, tags, updated, source_priority.
- Разделяй raw document и chunks.
- Переиндексация должна быть воспроизводимой.

## Когда не использовать

- Очень высокая QPS vector search.
- Сложная hybrid retrieval, где отдельный Qdrant/OpenSearch проще эксплуатировать.

## Частые ошибки

Хранить embeddings без source metadata, не удалять старые chunks после обновления документа, смешивать разные embedding models в одной коллекции без версии.

## Проверка

Retrieval evals, metadata filter tests, переиндексация sample vault, проверка latency на типовых запросах.

## Edge cases

- Индексы: IVFFlat — быстро, требует `lists` tuning после roll-в данных; HNSW — точнее, дороже по памяти.
- Distance op: cosine (`<=>`), inner product (`<#>`), L2 (`<->`) — выбирать под embeddings model.
- Recreate index после массового insert: накопил данные → отверстие в качестве, нужен `REINDEX`.
- Embeddings model bump: новая модель = новая колонка / отдельный namespace, не переписывать поверх.

## Security risks

Утечка между tenants через общий vector index без metadata-фильтра; SQL injection в filter clause при динамической сборке запроса; exfiltration через retrieval (модель пересказывает чужие данные).

## Источники

- [pgvector GitHub](https://github.com/pgvector/pgvector) — refreshed against pgvector v0.8.3 on 2026-06-22.
- См. [Vector databases](../07-mcp-and-ai-tools/Vector-databases.md), [RAG](../07-mcp-and-ai-tools/RAG.md), [Qdrant](../07-mcp-and-ai-tools/Qdrant.md).
