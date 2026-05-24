---
title: "LLM indexing"
category: "llm-indexing"
updated: "2026-05-24"
status: "active"
tags: ["rag", "file-search", "indexing"]
source_priority: "internal"
---

# LLM indexing

Раздел описывает, как подключить вики к LLM-агенту через RAG, OpenAI File Search или MCP-docs-сервер. Цель — чтобы LLM отвечал по проверенному корпусу с metadata и цитатами, а не по "всему интернету".

## Документы раздела

- [RAG and File Search](rag-file-search.md) — общий pipeline и выбор между OpenAI File Search и self-hosted vector store.
- [Metadata policy](metadata-policy.md) — обязательные поля front matter.
- [Chunking policy](chunking-policy.md) — как делить документы на chunk'и.
- [Source priority](source-priority.md) — таксономия `internal / official-docs / vendor-docs / community` и правила выставления.
- [Freshness checks](freshness-checks.md) — как поддерживать свежесть корпуса.
- [llms.txt rules](llms-txt-rules.md) — что и как писать в `llms.txt`.
- [golden-qa.yaml](golden-qa.yaml) — набор golden questions для retrieval evaluation (после Stage 3).

## Pipeline (сводно)

1. **Audit**: ходим по `docs/`, `patterns/`, `prompts/`, `checklists/`, `case-studies/`, `lessons-learned/`, исключая `*-template.md` и `_*.md`.
2. **Parse front matter**: достаём title, category, tags, updated, source_priority, status.
3. **Filter**: пропускаем `status: archived` и пустые/redirect-документы.
4. **Chunk**: по `##` / `###` с метаданными (см. [chunking-policy](chunking-policy.md)).
5. **Embed**: модель версионируется, snapshot фиксируется в `embeddings/manifest.json`.
6. **Index**: pgvector / Qdrant / OpenAI File Search.
7. **Retrieve**: top-K с фильтрами по metadata.
8. **Generate**: ответ с обязательными citations.
9. **Eval**: golden Q&A проверяет precision@5 / recall@5.

## Главное правило

LLM должна видеть не "весь интернет", а curated knowledge base: проверенные документы, явные metadata, источники с датой проверки, запрет на приватные данные и секреты, явный source_priority.

## Anti-patterns

- Индексировать всё подряд без фильтрации по `status` — старые документы перетягивают retrieval.
- Игнорировать metadata — невозможно фильтровать "только security" или "только vendor".
- Считать "поиск работает" доказательством корректности — нужен golden eval set.
- Скрывать citations — пользователь не может проверить ответ.

## Источники

- См. [RAG](../07-mcp-and-ai-tools/RAG.md), [RAG ingestion](../07-mcp-and-ai-tools/RAG-ingestion.md), [Vector databases](../07-mcp-and-ai-tools/Vector-databases.md), [pgvector](../04-databases/pgvector.md), [Qdrant](../07-mcp-and-ai-tools/Qdrant.md), [llms.txt](../../llms.txt).
