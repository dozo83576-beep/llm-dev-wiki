---
title: "Embeddings"
category: "ai-tools"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["embeddings", "search"]
source_priority: "official-docs"
---

# Embeddings

Embeddings превращают текст в векторы для semantic search. Для engineering wiki важны metadata filters, freshness, source priority и регулярная переиндексация.

Источник: [OpenAI Embeddings Docs](https://platform.openai.com/docs/guides/embeddings).

## Когда использовать

Используй embeddings для semantic search, RAG, similarity matching, clustering документов и поиска похожих case studies.

## Когда не использовать

Не используй embeddings там, где exact keyword search, SQL filter или простая навигация надежнее и дешевле.

## Production-паттерны

Фиксируй model name/version, chunking policy, metadata schema, reindex process и eval queries. Не смешивай embeddings разных моделей без поля версии.

## Частые ошибки

Индексировать мусорные chunks, не хранить source path, не переиндексировать после обновления, ожидать точных фактов от vector similarity.

## Проверка

Retrieval evals на golden Q&A, metadata filter tests, sample queries, latency/cost monitoring, periodic re-embed после крупных правок корпуса.

## Edge cases

- Multilingual корпус: multilingual model (text-embedding-3-small / Cohere multilingual) или отдельные spaces per language.
- Token-budget на chunk vs контекст модели: соблюдай 200–800 tokens per chunk.
- Очень длинные документы — отдельная стратегия (summarize → embed) либо чёткий chunking.
- Cost при scale: caching по `sha256(chunk_content)`, инкрементальный re-index.
- Embedding model bump — новая колонка / namespace, не overwrite.

## Security risks

Утечка приватных документов в общий index без `source_priority`/visibility-фильтра, exfiltration через retrieval (модель пересказывает чужие данные), prompt injection в проиндексированных документах.

## Источники

- [OpenAI Embeddings Docs](https://platform.openai.com/docs/guides/embeddings) — проверено 2026-05-24.
- См. [Vector databases](Vector-databases.md), [RAG](RAG.md), [Chunking policy](../14-llm-indexing/chunking-policy.md), [pgvector](../04-databases/pgvector.md).

