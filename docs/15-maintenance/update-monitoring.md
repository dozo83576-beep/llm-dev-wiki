---
title: "Мониторинг обновлений технологий"
category: "maintenance"
updated: "2026-06-05"
status: "active"
tags: ["maintenance", "updates", "automation"]
source_priority: "internal"
---

# Мониторинг обновлений технологий

Вики отслеживает обновления ключевых библиотек, фреймворков, SDK и платформ через `resources/technology-watchlist.json` и `tools/check-updates.ps1`.

## Offline-first политика

Обязательные проверки вики должны выполняться без внешних LLM API, платных embeddings и секретов. Внешние API допустимы только для явно опциональных режимов, например semantic retrieval benchmark с `OPENAI_API_KEY`.

Основной локальный pre-push цикл:

```powershell
pwsh ./tools/ci-local.ps1
```

Полный локальный цикл с non-blocking freshness report:

```powershell
pwsh ./tools/ci-local.ps1 -IncludeUpdateCheck
```

Ручной fallback для диагностики:

```bash
pwsh ./tools/wiki-audit.ps1
pwsh ./tools/wiki-quality.ps1
pwsh ./tools/build-index.ps1
python tools/build_embeddings.py --mode offline-text
python tools/run_offline_retrieval_evals.py --min-precision 0.6 --top-k 5 --top-k-strict 10 --warn-rank 3
```

`embeddings/manifest.json` в обязательном режиме должен фиксировать `retrieval_mode: offline-text` и `has_vectors: false`. Snapshot `embeddings/snapshot.jsonl` локальный и не коммитится.

## Как работает проверка

1. Скрипт читает watchlist.
2. Для `npm` получает latest version из npm registry.
3. Для `pypi` получает latest version из PyPI JSON API.
4. Для `github-releases` получает latest release через GitHub API.
5. Для `github-tags` получает последний tag через GitHub API.
6. Для `manual` выводит ссылку на официальный источник и пометку ручной проверки.

Скрипт не меняет файлы, не коммитит изменения и не обновляет `updated` автоматически. Он только печатает Markdown-отчет.

## Как добавить технологию

Добавь объект в `resources/technology-watchlist.json`:

```json
{
  "name": "Example",
  "ecosystem": "npm",
  "package": "example",
  "currentVersion": "",
  "docsUrl": "https://example.com/docs",
  "notes": "Why this technology matters for the wiki."
}
```

Поддерживаемые значения `ecosystem`: `npm`, `pypi`, `github-releases`, `github-tags`, `manual`.

## Когда обновлять документы

Обновляй `updated` во front matter, когда:

- изменилась major/minor версия с важным поведением;
- появились новые security рекомендации;
- поменялись API, CLI, deployment или migration rules;
- существующий playbook стал неправильным или неполным.

## Как фиксировать существенное обновление

- Малое изменение: обнови профильный документ и ссылку на источник.
- Новый production-паттерн: добавь файл в `patterns/`.
- Ошибка из-за устаревшего знания: добавь запись в `case-studies/failures/`.
- Успешное применение нового подхода: добавь запись в `case-studies/successes/`.
- Короткий вывод: добавь запись в `lessons-learned/`.

## GitHub Actions

Workflow `.github/workflows/technology-updates.yml` запускается раз в неделю и вручную через GitHub UI. Он вызывает `pwsh ./tools/ci-local.ps1 -UpdateCheckOnly -IncludeUpdateCheck -WriteGithubSummary`, пишет `technology-update-report.md` и добавляет отчет в GitHub Actions summary.

Freshness monitoring не является блокирующим gate для push/PR. Он управляет lifecycle одного review issue:

- если отчет содержит `Updates found > 0` или `Check failures > 0`, workflow создает или обновляет один открытый GitHub Issue с заголовком `Technology updates require wiki review`;
- если отчет чистый (`Updates found: 0` и `Check failures: 0`) и такой issue открыт, workflow добавляет комментарий со ссылкой на run и закрывает issue как `completed`;
- если отчет чистый и открытого issue нет, workflow ничего не создает.

Это предотвращает дубли задач и оставляет ревизию знаний ручным, осознанным шагом.

## Как закрывать issue обновлений

1. Открой issue и сравни отчет с официальной документацией.
2. Обнови профильные документы в `docs/`, `stacks/`, `patterns` или `resources`.
3. Если изменение существенно для будущих проектов, добавь `lessons-learned` или `case-studies`.
4. Обнови `currentVersion` в `resources/technology-watchlist.json`, если хочешь отслеживать следующий drift от этой версии.
5. Запусти `pwsh tools/ci-local.ps1 -IncludeUpdateCheck`.
6. Закрой issue вручную после коммита обновлений или дождись следующего clean scheduled run, который закроет issue автоматически.

## Как закрывать maintenance drift

1. Пройди [wiki maintenance checklist](../../checklists/wiki-maintenance.md).
2. Если `evals-report.md` показывает `Weak rank warnings > 0` или `Best expected rank > 3`, сначала улучши документы, metadata, prompts или `docs/14-llm-indexing/retrieval-synonyms.yaml`, а не подгоняй пороги.
3. Если менялись metadata, пересобери `docs/INDEX.md`.
4. Если менялся corpus, пересобери `embeddings/manifest.json` через offline-text режим.
5. Если использовались внешние API, не сохраняй ключи, payload'ы и приватные данные в вики.
