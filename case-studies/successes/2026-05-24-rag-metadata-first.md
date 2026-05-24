---
title: "Успешное решение: metadata-first RAG"
project_type: "ai-app"
stack: ["OpenAI API", "pgvector", "Markdown"]
status: "validated"
date: "2026-05-24"
tags: ["rag", "metadata", "llm-indexing"]
---

# Контекст

LLM-вики должна отвечать по инженерным документам и не смешивать устаревшие, вторичные и внутренние источники.

# Решение

Каждый документ получил front matter: title, category, updated, status, tags, source_priority. Retrieval использует metadata filters и source priority.

# Почему сработало

Ответы стали легче трассировать, а устаревшие документы можно исключать или понижать в ранге.

# Кодовые и архитектурные паттерны

Использовать [[../../docs/14-llm-indexing/metadata-policy|metadata policy]] и [[../../docs/14-llm-indexing/chunking-policy|chunking policy]].

# Ограничения

Metadata требует дисциплины обновления и автоматической проверки.

# Проверка

Wiki audit, sample retrieval queries, evals по stack/security/MCP вопросам.

# Ссылки

[[../../docs/07-mcp-and-ai-tools/RAG-ingestion|RAG ingestion]], [[../../docs/14-llm-indexing/rag-file-search|RAG/File Search]].

