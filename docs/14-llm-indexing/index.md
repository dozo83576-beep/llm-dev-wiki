---
title: "LLM indexing"
category: "llm-indexing"
updated: "2026-05-25"
status: "active"
tags: ["rag", "file-search", "indexing"]
source_priority: "internal"
---

# LLM indexing

Раздел описывает, как подключить вики к LLM-агенту через RAG, локальный lexical retrieval, OpenAI File Search или MCP-docs-сервер. Цель — чтобы LLM отвечал по проверенному корпусу с metadata и цитатами, а не по "всему интернету".

## Документы раздела

- [RAG and File Search](rag-file-search.md) — общий pipeline и выбор между OpenAI File Search и self-hosted vector store.
- [Metadata policy](metadata-policy.md) — обязательные поля front matter.
- [Chunking policy](chunking-policy.md) — как делить документы на chunk'и.
- [Source priority](source-priority.md) — таксономия `internal / mixed / official-docs / vendor-docs / community` и правила выставления.
- [Freshness checks](freshness-checks.md) — как поддерживать свежесть корпуса.
- [llms.txt rules](llms-txt-rules.md) — что и как писать в `llms.txt`.
- [golden-qa.yaml](golden-qa.yaml) — набор golden questions для retrieval evaluation (после Stage 3).
- [retrieval-synonyms.yaml](retrieval-synonyms.yaml) — локальный словарь русско-английских синонимов для offline evals.

## Pipeline (сводно)

1. **Audit**: ходим по `docs/`, `patterns/`, `prompts/`, `checklists/`, `case-studies/`, `lessons-learned/`, исключая `*-template.md` и `_*.md`.
2. **Parse front matter**: достаём title, category, tags, updated, source_priority, status.
3. **Filter**: пропускаем `status: archived` и пустые/redirect-документы.
4. **Chunk**: по `##` / `###` с метаданными (см. [chunking-policy](chunking-policy.md)).
5. **Snapshot**: corpus snapshot фиксирует chunk'и и `embeddings/manifest.json`.
6. **Offline eval**: `tools/run_offline_retrieval_evals.py` проверяет golden Q&A без внешних API.
7. **Optional embeddings**: `tools/build_embeddings.py --mode openai-embeddings` используется только при явном ключе и необходимости semantic retrieval.
8. **Index**: локальный lexical retrieval, pgvector / Qdrant / OpenAI File Search.
9. **Retrieve**: top-K с фильтрами по metadata.
10. **Generate**: ответ с обязательными citations.

## Offline-first режим

Обязательный CI не зависит от OpenAI API, внешних embeddings или сетевых retrieval-сервисов. Базовый режим:

```bash
python tools/build_embeddings.py --mode offline-text
python tools/run_offline_retrieval_evals.py --min-precision 0.6 --top-k 5 --top-k-strict 10 --warn-rank 3
```

В `embeddings/manifest.json` для этого режима должны быть `retrieval_mode: offline-text`, `has_vectors: false`, `embedding_model: null`. Это нормальное состояние для локальной разработки и CI.

## Stage 4 quality gate

Offline retrieval оценивает не только попадание expected-документа в top-K, но и его позицию. `Best expected rank` в `evals-report.md` должен быть `<= 3` для ключевых golden questions; если документ проходит top-5, но находится ниже `--warn-rank`, это weak retrieval case.

Weak case не блокирует CI, пока `precision@K` и `top-k-strict` проходят, но требует ручного разбора. Сначала улучшай формулировку документа, metadata или `retrieval-synonyms.yaml`; пороги меняй только после ревью golden set.

`retrieval-synonyms.yaml` хранит deterministic query expansion для русско-английских терминов. Это offline-only конфиг: он не вызывает внешние API, не содержит embeddings и не должен включать секреты или клиентские данные.

OpenAI embeddings остаются optional enhanced mode:

```bash
OPENAI_API_KEY=... python tools/build_embeddings.py --mode openai-embeddings
python tools/run_evals.py --min-precision 0.6 --top-k 5 --top-k-strict 10
```

Такой режим не является обязательным quality gate и не должен блокировать работу без ключей.

## Главное правило

LLM должна видеть не "весь интернет", а curated knowledge base: проверенные документы, явные metadata, источники с датой проверки, запрет на приватные данные и секреты, явный source_priority.

## Anti-patterns

- Индексировать всё подряд без фильтрации по `status` — старые документы перетягивают retrieval.
- Игнорировать metadata — невозможно фильтровать "только security" или "только vendor".
- Считать "поиск работает" доказательством корректности — нужен golden eval set.
- Игнорировать weak-rank warnings — пользователь получит менее релевантные источники, даже если precision формально зелёный.
- Делать внешний embeddings API обязательным для CI — вики должна проверяться offline-first.
- Скрывать citations — пользователь не может проверить ответ.

## Источники

- См. [RAG](../07-mcp-and-ai-tools/RAG.md), [RAG ingestion](../07-mcp-and-ai-tools/RAG-ingestion.md), [Vector databases](../07-mcp-and-ai-tools/Vector-databases.md), [pgvector](../04-databases/pgvector.md), [Qdrant](../07-mcp-and-ai-tools/Qdrant.md), [llms.txt](../../llms.txt).
