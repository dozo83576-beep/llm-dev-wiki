---
title: "User preference memory"
category: "ai-tools"
updated: "2026-06-07"
status: "active"
tags: ["agents", "memory", "preferences", "privacy"]
source_priority: "internal"
---

# User preference memory

User preference memory хранит локальные предпочтения пользователя: одобренные решения, любимые frontend/design приёмы, шрифты, визуальные референсы, anti-patterns и “не предлагать”. Это не заменяет wiki, official docs и security review.

## Когда использовать

- Пользователь явно сказал “запомни”, “это мой preferred вариант”, “такой стиль мне нравится”, “так больше не предлагай”.
- Один и тот же выбор повторился в нескольких задачах и был подтверждён результатом.
- Нужно сделать сайт “в моём стиле” или выбрать решение с учётом прошлых одобренных решений.

## Когда не использовать

- Для latest versions, security guidance, API changes, лицензий, цен, CI/CD или platform behavior.
- Для временных вкусовых гипотез, черновых ссылок и неподтверждённых предпочтений.
- Для приватных клиентских данных, закрытого кода, credentials, cookies, tokens, private keys и PII.

## Storage policy

По умолчанию личные preference entries хранятся локально в `D:\Work\AGENT-PREFERENCES.local.md`. Этот файл не должен попадать в GitHub-wiki, project commits, issue body, CI artifacts или screenshots.

В wiki можно хранить только процесс, шаблоны и sanitized lessons без личных референсов. Если preference превращается в общий production-паттерн, его нужно обезличить и оформить как `patterns/`, `lessons-learned/` или checklist update.

Обновление preference-файла делай через `tools/update-local-preferences.ps1`: сначала dry-run, затем явный `-Apply`. Ручное редактирование допустимо только для review, потому что скрипт выполняет базовый scan на secrets, PII и приватные payload markers.

## Priority order

1. Project-local `AGENTS.md`.
2. Security, compliance и explicit user approval.
3. Official docs для свежих фактов.
4. `D:\Work\AGENT-PREFERENCES.local.md`.
5. Wiki defaults, playbooks, blueprints and patterns.
6. Встроенные знания модели как вспомогательный источник.

## Entry schema

```text
### <short name>
- Scope: global | site-building | frontend | backend | design | project:<name>
- Preference: <что предпочитать>
- Avoid: <что не предлагать или использовать осторожно>
- Evidence: <user approval, project result, tests, diff, sources>
- Review after: <дата или условие пересмотра>
- Links: <безопасные локальные или публичные ссылки>
```

## Production-паттерны

- Перед визуальным решением проверь local preferences, затем [Design systems](../02-frontend/Design-systems.md) и [Frontend blueprints](../02-frontend/Frontend-blueprints.md).
- Перед выбором стека проверь preference defaults, затем [site architecture decision router](../01-development-process/site-architecture-decision-router.md) и [stack selection](../01-development-process/stack-selection.md).
- Если пользователь одобрил решение в конце задачи, запусти [update user preferences](../../prompts/update-user-preferences.md) и спроси, стоит ли сохранить preference.
- Любая запись должна иметь область применимости и evidence. Без evidence это заметка, а не правило.
- Команда сохранения должна быть dry-run first:

```powershell
pwsh D:\Work\llm-dev-wiki\tools\update-local-preferences.ps1 `
  -Title "Premium landing typography" `
  -Scope "frontend" `
  -Preference "Prefer expressive display font paired with readable body font." `
  -Avoid "Avoid generic AI purple gradients." `
  -Evidence "Approved by user after landing page review." `
  -ReviewAfter "2026-12-31" `
  -DryRun
```

## Частые ошибки

Сохранять приватные референсы в публичной wiki, считать taste preference обязательным technical constraint, игнорировать project-local rules, хранить “люблю такой стиль” без scope, не пересматривать устаревшие предпочтения.

## Проверка

- Preference file существует только локально.
- Нет секретов, PII, credentials, cookies, закрытого кода и customer payloads.
- Каждая запись имеет scope, evidence и review condition.
- Dry-run просмотрен до `-Apply`.
- При генерации сайта preference не ломает accessibility, performance, security и responsive QA.

## Источники

См. [Agent memory](Agent-memory.md), [Agent workflows](Agent-workflows.md), [Agent self-improvement loop](Agent-self-improvement.md), [Design systems](../02-frontend/Design-systems.md).
