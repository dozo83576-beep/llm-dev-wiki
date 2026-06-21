---
title: "Token-efficient agent workflow"
category: "ai-tools"
updated: "2026-06-20"
status: "active"
tags: ["agents", "mcp", "workflow", "tokens"]
source_priority: "internal"
---

# Token-efficient agent workflow

## Назначение

Единый workflow для сайтов в `D:\Work` и Python-автоматизаций в `D:\agent`. Цель — меньше контекста, меньше лишнего кода, больше проверяемости.

## Когда использовать

Используй этот документ перед созданием или изменением сайтов, Telegram-ботов, webhook worker, scheduled jobs, scraper/export задач и смешанных site + automation систем.

## Когда не использовать

Не используй этот workflow как замену project-local `AGENTS.md`, security policy или production runbook. Если проект имеет собственный documented workflow, он имеет приоритет.

## Принцип

Сначала route/preflight, затем узкий план, затем минимальная реализация и local gates. Не загружай в контекст весь проект, README всех зависимостей или generated files.

## Production-паттерны

- Держать prompt коротким: тип задачи, путь, цель, ограничения, критерии готовности, проверки.
- Для сайта сначала выбирать статическую архитектуру, если продукт не требует server runtime.
- Для automation брать ближайший шаблон `python-automation-factory`, а не писать новый каркас.
- Проверять фактический UI через Playwright, а не только build output.
- Для write/API операций требовать dry-run, если действие может менять внешние данные.

## Сайты

- Используй `D:\Work\AGENT-WORKFLOW.md` как быстрый router.
- Для нового сайта запускай `new-site-preflight.ps1`.
- Для существующего сайта сначала собери inventory: стек, entrypoints, scripts, local gates, риски.
- Перед реализацией нового сайта покажи короткий inventory и список docs/skills, которые реально будут использованы.
- По умолчанию выбирай static Astro, если нет явной необходимости в CMS, auth или server logic.
- После успешной сборки UI запускай Playwright smoke по первому экрану, mobile/desktop, формам и CTA.

## Боты и автоматизации

- Начинай с `D:\agent\python-automation-factory\AGENTS.md`.
- Для классификации запускай `python -m automation_factory trigger --text "<запрос>"`.
- Для стартового workflow запускай `python -m automation_factory workflow-start --request "<запрос>" --json`.
- Scaffold создавай только после явного подтверждения реализации.
- Перед handoff запускай `python -m automation_factory readiness --project <path>`.

## MCP и CLI

- Context7 — только для актуальных API и точечных фрагментов документации.
- Playwright MCP — для фактической браузерной проверки, не для рассуждений о дизайне.
- Spec Kit — для новых проектов и фич с неустойчивыми требованиями.
- Task Master — для многошаговых работ с зависимостями; не использовать для мелких правок.
- Claude Code Router — не включать в default workflow, пока providers пустые.
- MCP packages в Codex config закрепляй точными версиями. Обновление версий делай через inventory, changelog note и повторный `check-ai-tools.ps1`.

## Prompt shape

Минимальный prompt должен содержать:

- тип задачи: site, automation или mixed;
- путь проекта;
- цель;
- ограничения;
- критерии готовности;
- команды проверки.

Для генерации такого prompt используй:

```powershell
powershell -ExecutionPolicy Bypass -File D:\Work\tools\new-agent-task-prompt.ps1 -Type site -Path "<path>" -Goal "<goal>"
```

## Частые ошибки

- Читать `node_modules`, build artifacts или всю wiki вместо нужного router-документа.
- Подключать Task Master для мелкой однофайловой правки.
- Делать Next/Payload там, где достаточно Astro.
- Создавать scaffold automation-проекта до preflight и уточнения интеграций.
- Использовать Claude Code Router без настроенных providers.

## Проверка

- Для сайтов: `npm run check`, `npm run build`, `npm test` если есть, Playwright smoke.
- Для automation: `python -m pytest tests -q`, `python -m ruff check .`, `python -m automation_factory readiness --project <path>`.
- Для MCP/CLI: `powershell -ExecutionPolicy Bypass -File D:\Work\tools\check-ai-tools.ps1`.

## Источники

- `D:\Work\AGENTS.md`
- `D:\Work\AGENT-WORKFLOW.md`
- `D:\agent\python-automation-factory\AGENTS.md`
- `D:\Work\tools\check-ai-tools.ps1`
