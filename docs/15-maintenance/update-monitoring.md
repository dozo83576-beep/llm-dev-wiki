---
title: "Мониторинг обновлений технологий"
category: "maintenance"
updated: "2026-07-21"
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
pwsh ./tools/pre-release-local.ps1
```

Полный локальный CI:

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
4. Для `github-releases` получает latest stable release через GitHub API.
5. Для `github-tags` просматривает official tags и выбирает highest stable, пропуская RC/prerelease.
6. Для `nodejs-lts` читает `nodejs.org/dist/index.json` и выбирает Latest LTS, а не Current.
7. Для `python-stable` читает official `python/cpython` tags и выбирает highest stable без prerelease.
8. Для `php-stable` читает официальный PHP releases JSON и выбирает highest stable.
9. Для `wordpress-core` использует WordPress Core Version Check API.
10. Для `postgresql-stable` использует `postgresql.org/versions.json` и выбирает highest supported major/patch.
11. Для `manual` выводит ссылку на официальный источник и пометку ручной проверки.

Скрипт не меняет файлы, не коммитит изменения и не обновляет `updated` автоматически. Он только печатает Markdown-отчет.

`currentVersion` означает последнюю изученную stable-версию, а необязательный `recommendedBaseline` — версию, рекомендуемую для новых production-проектов. Если latest stable уже изучен, но baseline намеренно старее из-за migration/tooling риска, отчет ставит `baseline-hold`, не увеличивает `Updates found` и увеличивает отдельный счётчик `Baseline holds`.

По умолчанию watchlist считает drift только по stable версиям. Prerelease (`rc`, `alpha`, `beta`, `preview`, `canary`, `nightly` и похожие) не может автоматически стать ни `currentVersion`, ни `recommendedBaseline`. Если источник возвращает только prerelease, `tools/check-updates.ps1` ставит статус `prerelease-ignored` и не увеличивает `Updates found`.

Исключение задается явно через `"versionPolicy": "allow-prerelease"`. Используй его только для осознанного мониторинга draft/RC стандартов, где prerelease важен как freshness-сигнал, но не становится production baseline автоматически. Пример: MCP RC отслеживается, но production policy меняется только после проверки stable docs, client compatibility и security guidance.

Если внешний источник недоступен, статус `check-unavailable` считается `Check failures`. Scheduled workflow должен создать или обновить review issue, даже если в watchlist уже есть `currentVersion`.

Fixture режим для тестов включается только явным параметром `-UseFixtureVersions`; переменная `LLM_DEV_WIKI_UPDATE_FIXTURES_JSON` без этого параметра игнорируется. Fixtures поддерживают как простые version strings, так и структурированные official API payloads, чтобы отдельно проверять LTS/Current, stable/prerelease и разные source schemas.

## Как добавить технологию

Добавь объект в `resources/technology-watchlist.json`:

```json
{
  "name": "Example",
  "ecosystem": "npm",
  "package": "example",
  "currentVersion": "2.0.0",
  "recommendedBaseline": "1.9.0",
  "docsUrl": "https://example.com/docs",
  "notes": "Why this technology matters for the wiki."
}
```

Поддерживаемые значения `ecosystem`: `npm`, `pypi`, `github-releases`, `github-tags`, `nodejs-lts`, `python-stable`, `php-stable`, `wordpress-core`, `postgresql-stable`, `manual`.

`recommendedBaseline` опционален. Заполняй его только когда production baseline осознанно отличается от изученного latest stable; значение должно быть stable и иметь документированное migration-обоснование. Старые записи без поля остаются валидными.

`manual` оставляй только для платформ без единой package/core-версии или надежного публичного version API. Текущий ручной список: Webflow, Vercel, Cloudflare, OWASP и DIKIDI.

`versionPolicy` опционален. Поддерживаемые значения: `stable` и `allow-prerelease`. Если поле отсутствует, используется `stable`.

## Когда обновлять документы

Обновляй `updated` во front matter, когда:

- изменилась major/minor версия с важным поведением;
- появились новые security рекомендации;
- поменялись API, CLI, deployment или migration rules;
- существующий playbook стал неправильным или неполным.

Если версия проверена, но version-specific поведение и рекомендации не изменились, обнови freshness note и `reviewed`; не повышай `updated` искусственно в документах без содержательной правки.

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

Issue lifecycle покрыт Node unit tests и входит в `pwsh tools/ci-local.ps1 -IncludeToolTests`.

## Как закрывать issue обновлений

1. Открой issue и сравни отчет с официальной документацией.
2. Обнови профильные документы в `docs/`, `stacks/`, `patterns` или `resources`.
3. Если изменение существенно для будущих проектов, добавь `lessons-learned` или `case-studies`.
4. Обнови `currentVersion` до изученной stable-версии; если production migration отложена, сохрани старую рекомендацию в `recommendedBaseline` и опиши gate в профильном документе.
5. Запусти `pwsh tools/ci-local.ps1 -IncludeUpdateCheck`.
6. Закрой issue вручную после коммита обновлений или дождись следующего clean scheduled run, который закроет issue автоматически.

## Как закрывать maintenance drift

1. Пройди [wiki maintenance checklist](../../checklists/wiki-maintenance.md).
2. Если `evals-report.md` показывает `Weak rank warnings > 0` или `Best expected rank > 3`, сначала улучши документы, metadata, prompts или `docs/14-llm-indexing/retrieval-synonyms.yaml`, а не подгоняй пороги.
3. Если менялись metadata, пересобери `docs/INDEX.md`.
4. Если менялся corpus, пересобери `embeddings/manifest.json` через offline-text режим.
5. Если использовались внешние API, не сохраняй ключи, payload'ы и приватные данные в вики.
