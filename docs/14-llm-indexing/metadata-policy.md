---
title: "Metadata policy"
category: "llm-indexing"
updated: "2026-05-24"
status: "active"
tags: ["metadata", "front-matter"]
source_priority: "internal"
---

# Metadata policy

Каждый индексируемый документ должен иметь metadata.

## Поля

- `title`: человекочитаемое название.
- `category`: раздел.
- `updated`: дата проверки.
- `status`: active, draft, archived.
- `tags`: ключевые темы.
- `source_priority`: internal, official-docs, maintainer-repo, secondary.

## Правило

Документы без metadata индексируются с меньшим приоритетом или исключаются из production retrieval.

