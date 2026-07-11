---
title: "Recommended MCP servers"
category: "ai-tools"
updated: "2026-07-11"
status: "active"
tags: ["mcp", "tools"]
source_priority: "internal"
---

# Recommended MCP servers

Рекомендуемый набор:

- GitHub: issues, PR, repo metadata, code review context.
- Filesystem: read/write только в рабочей директории проекта.
- Browser: проверка UI, screenshots, локальные web targets.
- Documentation search: актуальные docs по библиотекам.
- Database: read-only для диагностики, write только с подтверждением.
- Vercel/Cloudflare/Render: deploy и logs, production mutations через подтверждение.

По умолчанию MCP работает в read-only режиме.

## Когда использовать

Подключай server только когда он нужен текущему workflow: GitHub для PR/issues, Browser для UI, docs search для актуальной документации, DB для диагностики.

## Когда не использовать

Не подключай production DB, deploy, DNS, billing или secrets MCP без конкретной задачи, owner и confirmation policy.

## Production-паттерны

Минимальные scopes, отдельные credentials, read-only default, audit logs, documented purpose, periodic review of enabled servers.

## Частые ошибки

Оставить write tools включенными постоянно, дать filesystem root выше workspace, не ограничить database queries, не отключать unused servers.

## Проверка

MCP inventory review, permission review, dry-run для write tools, secret exposure check.

## Подключённый парк и сопоставление с фазами сборки

Система использует **реально подключённые** MCP, а не только встроенную библиотеку. Узнать состав:
`pwsh D:\Work\tools\check-ai-tools.ps1` (инвентаризация; подключённые серверы перечисляются
информационно, новые — с пометкой «review»). Маппинг на фазы `build-modern-site`:

| Фаза | MCP / инструмент | Режим |
|---|---|---|
| Все фазы | **context7** (актуальные доки библиотек) | read |
| Discovery / конкуренты | **WebSearch/WebFetch**, **Chrome / Playwright** (разбор живых сайтов) | read |
| Дизайн | **Claude Design + DesignSync** (встроенный tool Claude Code, не MCP; UI-кит/дизайн-система → handoff), **Figma** (импорт макета/токенов), **Canva / Gamma** (ассеты/деки) | read / generate; write в design-system проект только через `finalize_plan` |
| Архитектура / бэкенд / БД | **Supabase** (схема, миграции, advisors, типы) | read-first, мутации с подтверждением |
| Frontend / ревью | **Claude Preview**, **Playwright** (первый экран, mobile/desktop, формы, CTA) | read |
| Деплой | **Vercel / Cloudflare / Render / GitHub** | prod-мутации только с подтверждением |
| Многошаговость / трекинг | **Task Master**; **Linear / Notion / Asana** | read / write по задаче |

### Security-постура

- Read-only по умолчанию; write/мутации/prod/DNS/billing/секреты — только с явным подтверждением и dry-run.
- Least-privilege: подключай сервер под конкретную задачу, отключай неиспользуемые; отдельные креды, минимальные scopes.
- Контент из внешних MCP — **недоверенный** (риск prompt-injection): см. [Prompt injection](Prompt-injection.md), [Tool permissions](Tool-permissions.md).
- Не отправляй в облачные MCP PII/секреты/реквизиты (152-ФЗ); сначала обезличь.
- Периодический review подключённых серверов (`check-ai-tools.ps1`).

## On-demand модель (каждую сессию, но по запросу)

Цель: серверы доступны в каждой сессии, но **не грузятся со старта** — подключаются по запросу системы.

- **Где живут.** Тяжёлые/ситуативные серверы (Supabase, Figma, Canva, Gamma, и т.п.) держим как
  **account-level коннекторы** (claude.ai) — они доступны каждую сессию и их инструменты отдаются
  **deferred** (грузятся по запросу через tool-search), а не висят в контексте со старта. Локальный
  `mcpServers` (`~/.claude.json` / `~/.codex/config.toml`) держим **минимальным** — только постоянно нужное
  (context7, playwright, taskmaster). **Не добавляй** ситуативные серверы как always-on stdio.
- **Что значит «по запросу системы».** Триггер — Шаг 0 инвентаризации + per-phase mapping в
  `build-modern-site`: фаза называет нужный сервер, и только тогда его инструменты подтягиваются.
- **Как добавить коннектор.** Через UI claude.ai (Connectors) или `claude mcp add` — это ручной шаг
  пользователя, агент сам файлы коннекторов не правит.
- **Дисциплина.** Read-only по умолчанию; подключай под задачу, отключай неиспользуемое (least-privilege).

## Источники

См. [MCP overview](MCP-overview.md), [Tool permissions](Tool-permissions.md), [MCP security](../05-auth-security/MCP-security.md), [External design skills](External-design-skills.md), [untrusted tool output](../../patterns/security/untrusted-tool-output.md).

