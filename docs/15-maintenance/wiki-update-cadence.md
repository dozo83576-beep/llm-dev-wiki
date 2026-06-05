---
title: "Периодичность обновления вики"
category: "maintenance"
updated: "2026-06-04"
status: "active"
tags: ["maintenance", "cadence", "corpus", "index"]
source_priority: "internal"
---

# Периодичность обновления вики

Когда и как пересчитывать корпус вики, обновлять INDEX, проверять freshness и обновлять embeddings. Цель — вики остаётся живой и точной, не превращается в архив с датой "2026-05-24" на всех документах.

## Когда использовать

- После завершения каждого реального проекта.
- После инцидента с последующим retro.
- При добавлении новой технологии в стек.
- При квартальном review корпуса.
- При пуше новых документов в main — CI делает часть проверок автоматически.

## Когда не использовать

- Обновлять `updated` в front matter без реального изменения контента — это ломает freshness-правило в `wiki-quality.ps1`.

## Триггеры обновления

### После каждого проекта (обязательно)

1. Прогнать `prompts/post-project-knowledge-capture.md` → заполнить case-study + lessons.
2. Если обнаружен новый паттерн — создать `patterns/<area>/<name>.md` по шаблону.
3. Запустить `pwsh tools/ci-local.ps1` — локально проверить audit, quality, INDEX, offline corpus и retrieval evals.
4. Закоммитить и запушить → CI повторит обязательные проверки.

### Событийные триггеры

| Событие | Действие |
|---------|---------|
| Инцидент / retro | `case-studies/failures/` + `lessons-learned/` + возможно новый checklist item |
| Новая технология в стек | Новый doc в `docs/0X-*/` + ссылка из playbook |
| Обновление major версии (Next.js, Prisma и т.п.) | Обновить соответствующий doc, поднять `updated`, проверить ссылки |
| Изменился рекомендуемый стек | Обновить `docs/01-development-process/stack-selection.md` и playbook |
| Добавлен новый паттерн ≥2 раза | Оформить в `patterns/` |

### Квартальный review (раз в ~3 месяца)

1. `pwsh tools/wiki-quality.ps1` — проверить warnings по freshness (skew > 14 дней).
2. Просмотреть `docs/INDEX.md` — найти документы с `updated` старше 6 месяцев и пересмотреть.
3. Проверить внешние ссылки (особенно `official-docs` разделы) на актуальность.
4. Обновить `docs/14-llm-indexing/golden-qa.yaml` новыми вопросами по накопленному опыту.
5. Пересобрать embeddings: `python tools/build_embeddings.py` (нужен `OPENAI_API_KEY`).
6. Прогнать evals: `python tools/run_evals.py --min-precision 0.6 --top-k 5 --top-k-strict 10`.

## Production-паттерны

**Автоматические проверки при каждом пуше (CI):**
- `wiki-audit.ps1` — структура разделов, front matter, битые ссылки.
- `verify-workflows.ps1` — статические инварианты GitHub Actions: wiki CI идёт через `ci-local.ps1`, scheduled freshness остаётся non-blocking.
- `wiki-quality.ps1` — минимальный объём (1200 chars), наличие секций, freshness skew, stale stamp.
- `build-index.ps1` — INDEX.md актуален, иначе CI падает.
- `run_offline_retrieval_evals.py` — BM25-поиск по golden Q&A без OPENAI ключа.

**Ручные команды:**

```powershell
# Полный локальный CI-equivalent перед push
pwsh tools/ci-local.ps1

# Пересобрать INDEX
pwsh tools/build-index.ps1

# Проверить quality
pwsh tools/wiki-quality.ps1

# Полный audit
pwsh tools/wiki-audit.ps1

# Offline corpus + retrieval evals (без API ключа)
python tools/build_embeddings.py --mode offline-text
python tools/run_offline_retrieval_evals.py --min-precision 0.6 --top-k 5 --top-k-strict 10 --warn-rank 3

# Semantic embeddings + evals (нужен OPENAI_API_KEY)
python tools/build_embeddings.py --mode openai-embeddings
python tools/run_evals.py --min-precision 0.6 --top-k 5 --top-k-strict 10
```

## Частые ошибки

- **Mass-stamp `updated`** — обновить дату на всех файлах без изменения контента; freshness CI обнаружит stale stamp через 30+ файлов с одинаковой датой.
- **Добавить документ, не обновив INDEX** — CI упадёт при следующем пуше.
- **Пропустить `post-project-knowledge-capture` после проекта** — опыт теряется, вики не растёт.
- **Обновить технологию в doc, но не обновить ссылки из playbooks** — ссылки ведут на устаревшую информацию.
- **Offline snapshot устарел** — `manifest.json` покажет старый `corpus_hash`; запустить `pwsh tools/ci-local.ps1` и закоммитить обновлённый manifest.

## Проверка

- `git diff --stat docs/INDEX.md` пустой после `build-index.ps1` → INDEX актуален.
- `wiki-quality.ps1` без warnings по freshness → все обновлённые файлы имеют корректный `updated`.
- `run_offline_retrieval_evals.py` возвращает `precision@5 ≥ 0.60` → корпус не деградировал.
- `embeddings/manifest.json` содержит свежий `corpus_hash` → offline snapshot пересобран после изменений.

## Edge cases

- Если `build_embeddings.py --mode offline-text` падает — это tooling/runtime проблема, а не отсутствие API ключа; offline evals не требуют секретов.
- Если precision@5 упал после добавления новых документов — нужны дополнительные golden Q&A вопросы, покрывающие новый контент.
- Если CI падает на INDEX — кто-то добавил doc без запуска `build-index.ps1` локально; запустить и закоммитить обновлённый INDEX.

## Источники

- [Freshness checks](../14-llm-indexing/freshness-checks.md)
- [tools/wiki-quality.ps1](../../tools/wiki-quality.ps1)
- [tools/build-index.ps1](../../tools/build-index.ps1)
- [checklists/wiki-maintenance.md](../../checklists/wiki-maintenance.md)
- [retro-process.md](retro-process.md)
- [update-monitoring.md](update-monitoring.md)
