---
title: "pgvector"
category: "database"
updated: "2026-05-24"
status: "active"
tags: ["pgvector", "rag", "postgresql"]
source_priority: "official-docs"
---

# pgvector

pgvector добавляет vector search в PostgreSQL. Это хороший первый выбор, если knowledge base небольшая или хочется избежать отдельной vector DB.

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

Источник: [pgvector](https://github.com/pgvector/pgvector).
