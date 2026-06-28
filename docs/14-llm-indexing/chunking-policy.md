---
title: "Chunking policy"
category: "llm-indexing"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["chunking", "rag", "indexing"]
source_priority: "internal"
---

# Chunking policy

Chunk должен быть достаточно малым для precise retrieval и достаточно полным, чтобы быть самодостаточной единицей ответа. В этой вики chunking опирается на структуру Markdown-документа, а не на наивный split по N токенам.

## Когда использовать

- Любой документ, индексируемый для RAG / File Search.
- Корпус, который растёт и должен сохранять стабильную retrieval-quality.

## Когда не использовать

- Очень короткие документы (< 500 символов) — индексировать целиком.
- Snapshots / data dumps без human-readable структуры — отдельный pipeline.

## Правила

- **Разбивать по `##` (h2) с подкатами по `###` (h3)**, а не по случайному размеру.
- **Каждый chunk наследует**: путь файла, цепочку заголовков (`Doc > Section > Subsection`), front matter metadata.
- **Не смешивать разные технологии** в одном chunk: если в файле есть `## React` и `## Vue`, это два chunk'а.
- **Сохранять ссылки на источники** в chunk context — citation воспроизводимы.
- **Target size**: 200–800 токенов на chunk; крупнее — overlap не помогает, мельче — теряется контекст.
- **Overlap**: 10–15% между соседними chunk'ами для боковых тем.

## Production-паттерны

- Chunk id = `path#section-slug` — стабильный, переживает re-index.
- Metadata propagation: `category`, `tags`, `updated`, `source_priority` копируются в каждый chunk.
- Embeddings version + chunking version в манифесте — позволяет переиндексировать частично.
- Tracking `sha256(content)` per chunk — кеш переиспользует unchanged chunks.

## Частые ошибки

- Splitting по фиксированной длине без учёта структуры — chunk обрывается на полуслове.
- Терять контекст заголовка — `## Когда не использовать` без указания, чего именно.
- Класть в один chunk правило и анти-паттерн — модель путается, что хорошо, а что плохо.
- Игнорировать таблицы и code blocks при splitting — теряется семантика.

## Edge cases

- **Таблицы** (stack selection): индексировать как отдельные logical chunks с полным заголовком и подписями колонок.
- **Code blocks**: не разбивать на середине; если блок > target size — оставить целиком.
- **Промпты**: индексировать целиком, даже если длинные — иначе теряется смысл.
- **Failure cases / lessons learned**: индексировать с пометкой `tag: failure` и более высоким весом для debugging-запросов.
- **Чеклисты**: каждый пункт — отдельный chunk, чтобы retrieval отдавал ровно нужное правило.

## Testing strategy

- Golden Q&A: ожидаемый chunk path/id присутствует в top-K результатов.
- Smoke на re-index: один и тот же документ даёт идентичные chunk_id при повторе.
- Cardinality check: внезапный рост числа chunk'ов на коммит — повод проверить парсер.

## Источники

- [OpenAI Cookbook: Chunking](https://cookbook.openai.com/examples/chunking_for_rag) — проверено 2026-05-24.
- См. [Metadata policy](metadata-policy.md), [RAG file search](rag-file-search.md), [Source priority](source-priority.md), [RAG](../07-mcp-and-ai-tools/RAG.md).
