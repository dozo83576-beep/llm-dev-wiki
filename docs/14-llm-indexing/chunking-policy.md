---
title: "Chunking policy"
category: "llm-indexing"
updated: "2026-05-24"
status: "active"
tags: ["chunking", "rag"]
source_priority: "internal"
---

# Chunking policy

Chunk должен быть достаточно малым для точного retrieval и достаточно полным для ответа.

## Правила

- Разбивать по `h2/h3`, а не по случайному размеру.
- Добавлять путь файла и цепочку заголовков.
- Не смешивать разные технологии в одном chunk.
- Сохранять ссылки на источники в chunk context.

## Edge cases

- Таблицы stack selection лучше индексировать как отдельные logical chunks.
- Промпты индексировать целиком, если они короткие.
- Failure cases индексировать с высоким весом для debugging-запросов.

