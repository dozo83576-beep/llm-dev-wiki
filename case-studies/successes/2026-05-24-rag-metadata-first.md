---
title: "Успешное решение: metadata-first RAG"
category: "case-study"
updated: "2026-05-24"
status: "validated"
tags: ["rag", "metadata", "llm-indexing"]
source_priority: "internal"
date: "2026-05-24"
project_type: "ai-app"
stack: ["OpenAI API", "pgvector", "Markdown"]
---

# Контекст

LLM-вики должна отвечать по инженерным документам и не смешивать устаревшие, вторичные и внутренние источники.

# Решение

Каждый документ получил front matter: title, category, updated, status, tags, source_priority. Retrieval использует metadata filters и source priority.

# Почему сработало

Ответы стали легче трассировать, а устаревшие документы можно исключать или понижать в ранге.

# Кодовые и архитектурные паттерны

Использовать [metadata policy](../../docs/14-llm-indexing/metadata-policy.md) и [chunking policy](../../docs/14-llm-indexing/chunking-policy.md).

# Ограничения

Metadata требует дисциплины обновления и автоматической проверки.

# Проверка

Wiki audit, sample retrieval queries, evals по stack/security/MCP вопросам.

# Ссылки

[RAG ingestion](../../docs/07-mcp-and-ai-tools/RAG-ingestion.md), [RAG/File Search](../../docs/14-llm-indexing/rag-file-search.md).
