---
title: "RAG and File Search"
category: "llm-indexing"
updated: "2026-05-24"
status: "active"
tags: ["rag", "file-search", "openai"]
source_priority: "official-docs"
---

# RAG and File Search

Для OpenAI File Search загрузи Markdown-файлы в vector store и используй tool в Responses API. Для self-hosted RAG используй pgvector/Qdrant и собственный retrieval layer.

## Pipeline

1. Audit wiki.
2. Exclude private files.
3. Parse front matter.
4. Chunk by headings.
5. Embed and index.
6. Query with metadata filters.
7. Return answers with citations.
8. Run evals.

Источник: [OpenAI File Search](https://platform.openai.com/docs/guides/tools-file-search/).

