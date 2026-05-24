---
title: "RAG"
category: "ai-tools"
updated: "2026-05-24"
status: "active"
tags: ["rag", "knowledge-base"]
source_priority: "internal"
---

# RAG

RAG нужен, когда LLM должна отвечать по вашей базе знаний. Для этой вики индексируй Markdown-файлы с metadata: title, category, updated, tags, source_priority.

Правила: маленькие документы, стабильные заголовки, ссылки на источники, chunking по разделам, reranking для сложных запросов, evals на типовые вопросы.

## Когда использовать

Используй RAG, когда модель должна отвечать по вашей изменяемой базе знаний, документации, case studies, tickets или internal docs.

## Когда не использовать

Не используй RAG как замену качественной структуры документов. Если знания хаотичны, retrieval будет хаотичным.

## Production-паттерны

Curated corpus, metadata, chunking policy, source priority, citations, freshness checks, evals, prompt injection controls.

## Частые ошибки

Индексировать все подряд, не показывать источники, не проверять retrieval quality, считать RAG гарантией отсутствия hallucinations.

## Проверка

Golden question set, retrieval precision checks, citation checks, stale document tests, adversarial prompt injection tests.

## Источники

См. [[RAG-ingestion|RAG ingestion]], [[../14-llm-indexing/rag-file-search|RAG/File Search]].

