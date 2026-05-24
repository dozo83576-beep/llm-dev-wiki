---
title: "LLM indexing"
category: "llm-indexing"
updated: "2026-05-24"
status: "active"
tags: ["rag", "file-search", "indexing"]
source_priority: "internal"
---

# LLM indexing

Этот раздел описывает, как подключать вики к LLM через RAG, File Search или MCP.

## Документы

- [[rag-file-search|RAG/File Search]]
- [[metadata-policy|Metadata policy]]
- [[chunking-policy|Chunking policy]]
- [[source-priority|Source priority]]
- [[freshness-checks|Freshness checks]]
- [[llms-txt-rules|llms.txt rules]]

## Правило

LLM должна видеть не “весь интернет”, а curated knowledge base: проверенные документы, metadata, источники, дату обновления и запрет на приватные данные.

