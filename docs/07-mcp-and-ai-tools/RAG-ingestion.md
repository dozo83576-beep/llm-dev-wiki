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

