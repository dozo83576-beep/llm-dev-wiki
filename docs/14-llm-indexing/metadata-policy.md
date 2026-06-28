---
title: "Metadata policy"
category: "llm-indexing"
updated: "2026-06-29"
reviewed: "2026-06-29"
status: "active"
tags: ["metadata", "front-matter", "rag"]
source_priority: "internal"
---

# Metadata policy

Metadata делает корпус фильтруемым и ранжируемым. Без неё retrieval отдаёт случайный шум; с ней — релевантные документы с понятным происхождением и свежестью.

## Когда использовать

- Каждый Markdown-файл, попадающий в RAG-pipeline.
- Любой документ из `docs/`, `patterns/`, `prompts/`, `checklists/`, `case-studies/`, `lessons-learned/`, `stacks/`.

## Когда не использовать

- README, AGENTS.md, llms.txt и другие "корневые" файлы — у них своя структура.
- Шаблоны (`_template*.md`) — фикстуры, не индексируются.

## Обязательные поля

- **`title`** (string) — человекочитаемое название, отображается в выдаче.
- **`category`** (string) — основной раздел: `frontend`, `backend`, `database`, `security`, `ai-tools`, `playbooks`, `testing`, `devops`, `process`, `governance`, `llm-indexing`, `pattern`, `prompt`, `checklist`, `case-study`, `lesson`.
- **`updated`** (YYYY-MM-DD) — дата последнего **содержательного изменения** контента.
- **`status`** (`active` | `draft` | `archived` | `redirect`) — управляет включением в production retrieval.
- **`tags`** (list[string]) — ключевые темы. 2–6 тегов на документ.
- **`source_priority`** (`official-docs` | `vendor-docs` | `internal` | `community`) — см. [source-priority.md](source-priority.md).

## Опциональные поля

- **`reviewed`** (YYYY-MM-DD) — дата последней **проверки, что контент всё ещё актуален** (без правок). Living-документ, перечитанный и подтверждённый, получает `reviewed: <today>` — это честно гасит stale-stamp warning в `wiki-quality.ps1`, не подделывая `updated`. См. [freshness-checks](freshness-checks.md).
- **`owner`** (string) — ответственный за актуальность (для крупных команд).
- **`expires_at`** (YYYY-MM-DD) — дата, после которой документ требует обязательного re-review.
- **`related`** (list[string]) — ссылки на родственные документы.
- **`sources`** (list[string]) — список внешних источников.

## Правила

- **Документы без metadata** индексируются с пониженным приоритетом или исключаются из production retrieval — настраивается в `tools/build_embeddings.py`.
- **`status: draft`** не попадает в production index, но виден в Obsidian.
- **`status: archived`** исключается полностью; история остаётся в git.
- **`status: redirect`** — короткий stub со ссылкой на канонический документ; индексируется только сама ссылка.
- **`tags`** не должны дублировать `category` — теги дополняют, не повторяют.

## CI-проверка

- Front matter присутствует и валиден (YAML parser).
- Все обязательные поля заполнены.
- `updated` ≤ сегодня.
- `category` из словаря (no тайпов).
- `status` из словаря.
- `tags` — массив строк, не пустой.

## Частые ошибки

- Title повторяет имя файла без улучшения читабельности.
- Tags = весь словарь — теряется отличительный сигнал.
- Старый `updated` после фактического обновления — freshness обманывает retrieval.
- `category: misc` или `category: other` — затрудняет фильтрацию.

## Источники

- См. [Source priority](source-priority.md), [Chunking policy](chunking-policy.md), [Freshness checks](freshness-checks.md), [RAG file search](rag-file-search.md).
