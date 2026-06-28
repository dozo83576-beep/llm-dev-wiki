---
title: "Wiki maintenance checklist"
category: "checklist"
updated: "2026-06-29"
reviewed: "2026-06-29"
status: "active"
tags: ["wiki", "maintenance", "rag", "offline"]
source_priority: "internal"
---

# Wiki maintenance checklist

Gated checklist для регулярного обслуживания вики. Формат: критерий - проверка - owner - severity - ссылка.

## Corpus quality

- [ ] **Wiki audit** проходит локально и в CI - maintainer - block - `pwsh ./tools/wiki-audit.ps1`.
- [ ] **Quality report** просмотрен; предупреждения либо исправлены, либо осознанно оставлены - maintainer - warn - `pwsh ./tools/wiki-quality.ps1`.
- [ ] **INDEX актуален** после изменения документов - maintainer - block - `pwsh ./tools/build-index.ps1`.
- [ ] **Front matter** заполнен: title, category, updated, status, tags, source_priority - maintainer - block - [metadata policy](../docs/14-llm-indexing/metadata-policy.md).

## Source priority

- [ ] **Official/vendor docs** помечены как `official-docs` или `vendor-docs` - maintainer - warn - [source priority](../docs/14-llm-indexing/source-priority.md).
- [ ] **Internal practice with official baseline** помечена как `mixed` - maintainer - warn.
- [ ] **Sources section** есть в production-документах с внешними утверждениями - maintainer - warn.

## Offline retrieval

- [ ] **Corpus snapshot** пересобран без внешних API - maintainer - block - `python tools/build_embeddings.py --mode offline-text`.
- [ ] **Manifest** содержит `retrieval_mode: offline-text` и `has_vectors: false` для обязательного CI - maintainer - block.
- [ ] **Golden Q&A** проходит локально - maintainer - block - `python tools/run_offline_retrieval_evals.py --min-precision 0.6 --top-k 5 --top-k-strict 10 --warn-rank 3`.
- [ ] **Best expected rank** для ключевых golden questions не хуже `3` или weak cases разобраны вручную - maintainer - warn - `evals-report.md`.
- [ ] **Weak retrieval cases** из `evals-report.md` превращены в улучшения документов, metadata, prompts, `retrieval-synonyms.yaml` или golden Q&A - maintainer - warn.

## Freshness

- [ ] **Technology watchlist** проверен - maintainer - warn - `pwsh ./tools/check-updates.ps1`.
- [ ] **Manual entries** сверены с официальными источниками перед изменением рекомендаций - maintainer - warn.
- [ ] **Stale docs** с массовым `updated` перечитаны; на актуальных проставлен `reviewed: <date>` (гасит stale-stamp честно, без подделки `updated`), при дрейфе — правка + бамп `updated` - maintainer - warn - [freshness-checks](../docs/14-llm-indexing/freshness-checks.md).

## Knowledge capture

- [ ] **Успешные решения** сохранены в `case-studies/successes` или `patterns` - tech lead - warn.
- [ ] **Ошибки** сохранены в `case-studies/failures` и связаны с чеклистами - tech lead - block.
- [ ] **Повторяемые выводы** добавлены в `lessons-learned` без секретов, PII и приватного кода - tech lead - block.
- [ ] **Learning review** по значимым задачам завершён: artifact создан/обновлен или указана причина `no artifact needed` - tech lead - warn - [Agent self-improvement loop](../docs/07-mcp-and-ai-tools/Agent-self-improvement.md).
