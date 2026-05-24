---
title: "Мониторинг обновлений технологий"
category: "maintenance"
updated: "2026-05-24"
status: "active"
tags: ["maintenance", "updates", "automation"]
source_priority: "internal"
---

# Мониторинг обновлений технологий

Вики отслеживает обновления ключевых библиотек, фреймворков, SDK и платформ через `resources/technology-watchlist.json` и `tools/check-updates.ps1`.

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

Workflow `.github/workflows/technology-updates.yml` запускается раз в неделю и вручную через GitHub UI. Результат пишется в GitHub Actions summary.

