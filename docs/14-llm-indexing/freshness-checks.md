---
title: "Freshness checks"
category: "llm-indexing"
updated: "2026-05-24"
status: "active"
tags: ["freshness", "maintenance", "rag"]
source_priority: "internal"
---

# Freshness checks

Freshness отвечает на вопрос "насколько содержимое документа всё ещё актуально". Для RAG это критично: устаревший документ с уверенным тоном — самый дорогой класс ошибок.

## Когда использовать

- Любой документ, индексируемый в production RAG.
- Корпус с быстро меняющимися источниками (frameworks, SDK, vendor pricing).
- Перед крупными проектами — точечный аудит релевантных разделов.

## Когда не использовать

- Исторические case-studies / lessons-learned — там freshness = "никогда" для самого события, обновляется только interpretation.
- Прототипы корпуса без производственного использования.

## Правила

- **Active frameworks** (React, Next.js, FastAPI, OpenAI API): проверять минимум раз в квартал.
- **Security / MCP / Auth**: проверять перед каждым большим проектом и при появлении новых major CVE / advisory.
- **Vendor docs** (Vercel, Stripe, Cloudflare): проверять раз в 6 месяцев, плюс при изменении продукта на стороне vendor.
- **Internal practices**: обновлять по факту нового опыта; помечать `updated` только при содержательном изменении, а не при rename.
- **Archived**: status переводится в `archived` для устаревшего материала с явной причиной в front matter.
- **Источники в коммитах**: обновление внешнего источника фиксируется в git commit message ("update sentry docs link, refresh after v8 release").

## CI-сигналы

- **Stale stamp**: если `updated` совпадает у ≥ 30 файлов и при этом файл не менялся последние 30 дней — warning.
- **Updated vs git log**: если `updated` в front matter старше последнего реального коммита по файлу больше чем на 14 дней — warning.
- **External link rot**: периодический workflow проверяет, что внешние URL отдают 2xx.
- **Source priority drift**: документ помечен `internal`, но опирается на внешние источники — сигнал к ревизии (см. [source-priority.md](source-priority.md)).

## Частые ошибки

- Массовый штамп `updated` одной датой при batch-edit без реальных изменений содержания — freshness теряет смысл.
- Не обновлять `updated` после содержательной правки — стейкхолдеры считают документ свежее, чем он есть.
- Считать live-проверку link health достаточной — линк жив, но содержимое за ним устарело.
- Удалять старые документы без архивации — теряется контекст для будущих ретро.

## Knowledge capture

При большом обновлении внешнего источника (например, мажорный релиз фреймворка):
1. Прочитать changelog.
2. Обновить документ + `updated`.
3. Зафиксировать в lessons-learned, если изменение влияет на стек.
4. Перегенерировать embeddings snapshot.

## Источники

- См. [Metadata policy](metadata-policy.md), [Source priority](source-priority.md), [llms.txt rules](llms-txt-rules.md), [docs/15-maintenance/update-monitoring.md](../15-maintenance/update-monitoring.md).
