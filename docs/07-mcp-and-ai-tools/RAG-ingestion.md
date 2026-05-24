---
title: "RAG ingestion"
category: "ai-tools"
updated: "2026-05-24"
status: "active"
tags: ["rag", "ingestion"]
source_priority: "internal"
---

# RAG ingestion

Ingestion превращает Markdown vault в searchable knowledge base. Ошибка ingestion приводит к плохим ответам даже при хорошей модели.

## Pipeline

1. Сканировать `.md/.mdx`.
2. Читать front matter.
3. Разбивать по заголовкам и смысловым блокам.
4. Добавлять metadata: path, title, category, tags, updated, source_priority.
5. Создавать embeddings.
6. Сохранять chunks в vector store.
7. Запускать eval queries.

## Production-паттерны

- Chunk должен содержать заголовочный контекст.
- Внутренние Obsidian-ссылки сохраняются как metadata или plain references.
- Устаревшие chunks удаляются при изменении файла.
- Evals включают вопросы по stack selection, security, MCP и playbooks.

## Когда не использовать

Не строй ingestion pipeline, если корпус маленький и помещается в controlled prompt context. RAG нужен при росте объема и необходимости freshness.

## Частые ошибки

Индексировать черновики, не удалять stale chunks, терять source path, не хранить `updated`, игнорировать private data exclusions.

## Проверка

Dry-run ingestion, count chunks per document, retrieval evals, secret scan, freshness checks.

## Источники

См. [Chunking policy](../14-llm-indexing/chunking-policy.md), [Metadata policy](../14-llm-indexing/metadata-policy.md).

