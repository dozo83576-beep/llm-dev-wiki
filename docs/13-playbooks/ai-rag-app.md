---
title: "Playbook: AI/RAG app"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["ai", "rag", "mcp"]
source_priority: "internal"
---

# Playbook: AI/RAG app

## Стек по умолчанию

Next.js + OpenAI API + PostgreSQL/pgvector или Qdrant + ingestion pipeline + evals + tool permission policy.

## Порядок разработки

1. Define answer domain and forbidden content.
2. Prepare documents with metadata.
3. Build ingestion: parse, chunk, embed, index.
4. Build retrieval with filters and source citations.
5. Add prompt injection defenses.
6. Add eval set: quality, refusal, security, freshness.
7. Add monitoring: usage, latency, cost, failed retrieval.

## Анти-паттерны

- Индексировать хаотичные документы без metadata.
- Считать RAG решением hallucinations без evals.
- Давать агенту write-tools без permission policy.

