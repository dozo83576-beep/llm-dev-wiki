---
title: "Pattern: RAG metadata"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["ai", "rag", "metadata"]
---

# RAG metadata

RAG без metadata быстро превращается в поиск по неуправляемому тексту.

## Когда использовать

Любая knowledge base, где документы имеют категории, источники, дату обновления или уровень доверия.

## Когда не использовать

Для маленького одноразового prompt context metadata может быть лишней.

## Production-паттерны

Каждый chunk получает `path`, `title`, `category`, `tags`, `updated`, `source_priority`, `status`.

## Частые ошибки

- Индексировать устаревшие и актуальные документы одинаково.
- Не хранить ссылку на источник.
- Chunk без заголовочного контекста.

## Проверка

Evals на retrieval с фильтрами по category/source_priority и проверкой citations.

Источники: [Metadata policy](../../docs/14-llm-indexing/metadata-policy.md), [success case](../../case-studies/successes/2026-05-24-rag-metadata-first.md).

