---
title: "RAG and File Search"
category: "llm-indexing"
updated: "2026-05-24"
status: "active"
tags: ["rag", "file-search", "openai", "indexing"]
source_priority: "official-docs"
---

# RAG and File Search

Два пути подключения вики к LLM: managed (OpenAI File Search / Anthropic / vendor) и self-hosted (pgvector / Qdrant + собственный retrieval layer). Выбор определяется control / cost / latency / data-residency.

## Когда использовать

- LLM должен отвечать на основе вики и давать цитаты.
- Agent-инструмент `wiki_search` для других задач.
- Бот в support / dev-канале с base of knowledge.

## Когда не использовать

- Маленький корпус (< 50 документов) — иногда хватит keyword-search + ranking.
- Регулярно меняющиеся данные (минутно) — RAG не транспорт для real-time данных.

## Выбор подхода

### OpenAI File Search (managed)

- **Плюсы**: всё managed, citations из коробки, минимум кода.
- **Минусы**: vendor lock-in, ограниченный control над chunking / embeddings, data-residency.
- **Когда**: PoC, быстрый запуск, корпус целиком публичный/допустимый.

### Self-hosted (pgvector / Qdrant)

- **Плюсы**: полный control, можно hybrid retrieval (BM25 + vectors), data в собственном контуре.
- **Минусы**: больше кода и обслуживания.
- **Когда**: чувствительные данные, нужен hybrid / rerank, большой корпус.

## Pipeline

1. **Audit** репо: список индексируемых директорий, исключения (`_template*`, `*.draft.md`, `archived`).
2. **Exclude** приватные файлы: проверка front matter `status` и `source_priority` + denylist.
3. **Parse front matter**: title, category, updated, tags, source_priority, status.
4. **Chunk by headings**: см. [chunking-policy](chunking-policy.md).
5. **Embed**: модель версионируется (`text-embedding-3-small` или provider equivalent).
6. **Index**: загрузить в vector store; сохранить manifest.
7. **Query**: top-K с фильтрами по metadata (`category`, `tags`, `source_priority`).
8. **Generate**: ответ с обязательными citations (path + section).
9. **Evals**: golden Q&A, precision@5 / recall@5.

## Production-паттерны

- Один источник правды: репо. Indexing-pipeline идемпотентен.
- Cache по `sha256(chunk_content)` — переиндексируется только изменившееся.
- Metadata filtering обязателен (не "search everywhere").
- Citations возвращаются всегда (path + section heading).
- Hybrid retrieval для precision-critical задач.
- Reranker (cross-encoder) для top-50 → top-5.

## Частые ошибки

- Индексировать всё подряд, включая шаблоны и черновики.
- Передавать "сырой" tool/retrieval output модели как доверенный context (prompt injection).
- Игнорировать `source_priority` при ранжировании.
- Не показывать citations — пользователь не может проверить ответ.

## Security risks

Prompt injection через документы корпуса, утечка приватных файлов через слабые exclusion-правила, exfiltration через response (LLM пересказывает то, что не должно быть в ответе).

## Testing strategy

- Golden Q&A с expected paths (top-K).
- Refusal tests на out-of-domain вопросы.
- Adversarial prompt injection набор.
- Smoke на re-index: воспроизводимость chunk_id и числа chunk'ов.

## Edge cases

- Multi-language корпус — отдельные spaces или multilingual модель.
- Long documents (> 50 KB) — отдельный pipeline / suммаризация.
- Code blocks / config — не дробить, индексировать целиком.
- Tables — отдельный chunk с заголовками колонок.

## Источники

- [OpenAI File Search](https://platform.openai.com/docs/guides/tools-file-search/) — проверено 2026-05-24.
- [OpenAI Embeddings](https://platform.openai.com/docs/guides/embeddings) — проверено 2026-05-24.
- См. [RAG](../07-mcp-and-ai-tools/RAG.md), [RAG ingestion](../07-mcp-and-ai-tools/RAG-ingestion.md), [Vector databases](../07-mcp-and-ai-tools/Vector-databases.md), [pgvector](../04-databases/pgvector.md), [Qdrant](../07-mcp-and-ai-tools/Qdrant.md).
