---
title: "Система скиллов сборки сайтов"
category: "start"
updated: "2026-06-10"
status: "active"
tags: ["skills", "agents", "self-learning", "claude-code", "codex"]
source_priority: "internal"
---

# Система скиллов сборки сайтов

Кросс-рантайм система вызываемых скиллов, которая ведёт проект сайта через весь цикл и поддерживает
controlled learning loop: фиксирует одобренные предпочтения и переиспользуемый опыт во внешней памяти.
Работает и в Claude Code, и в Codex. Скиллы — тонкие роутеры: вся инженерная глубина остаётся в этой вики,
а скиллы лишь направляют в нужные документы, playbooks, паттерны и чеклисты и применяют локальные предпочтения.
Скиллы не обучаются автономно и не меняют веса модели.

## Назначение

- Дать единый сквозной маршрут «идея → деплой → фиксация знаний» с проверяемыми этапами.
- Подключать в каждой фазе профильные документы вики, а не выбирать решения «из головы».
- Замкнуть управляемую петлю накопления знаний: одобренные предпочтения и дизайн-решения сохранять,
  чтобы следующий проект стартовал с накопленного контекста.

## Как устроено

Канон скиллов (единый источник, редактируется один раз) лежит **вне репозитория вики**, чтобы не нарушать
её CI-аудит: `D:\Work\.agent-skills\<name>\` (`SKILL.md` + для Codex `agents\openai.yaml`). Скрипт
`D:\Work\.agent-skills\sync-skills.ps1` раскатывает канон в оба рантайма:

- Claude Code: `~\.claude\skills\<name>\` (читает `SKILL.md`, вызов `/<name>`).
- Codex: `~\.codex\skills\<name>\` (читает `SKILL.md` + `agents\openai.yaml`, вызов `$<name>`).

## Слои контекста (порядок чтения)

1. Project-local `AGENTS.md` в корне целевого проекта (высший приоритет).
2. `D:\Work\AGENTS.md` — локальные правила для всех проектов.
3. `D:\Work\AGENT-PREFERENCES.local.md` — одобренные предпочтения (стек, дизайн, шрифты, анти-паттерны).
4. Эта вики — профильные [docs](../00-start-here/overview.md), stacks, [playbooks](../13-playbooks/index.md),
   patterns, checklists.

Приоритет при конфликте: project-local > security/compliance > официальные актуальные источники >
local preferences > wiki defaults.

## Скиллы цикла

Оркестратор `build-modern-site` ведёт по фазам и подключает фазовые скиллы:

Trigger-фраза для обоих рантаймов: если пользователь пишет `Я хочу создать сайт <описание сайта>`,
агент трактует текст после фразы как raw request и первым шагом запускает
`pwsh D:\Work\llm-dev-wiki\tools\new-site-preflight.ps1 -Request "<описание сайта>"`.

| Скилл | Фаза | Куда маршрутизирует |
| --- | --- | --- |
| `build-modern-site` | Оркестрация | [create-new-project](../../prompts/create-new-project.md), [full-cycle](../01-development-process/full-cycle.md), [playbooks](../13-playbooks/index.md) |
| `site-discovery` | Требования | [project-discovery](../../checklists/project-discovery.md) |
| `site-stack` | Выбор стека | [stack-selection](../01-development-process/stack-selection.md), [decision router](../01-development-process/site-architecture-decision-router.md) |
| `site-architecture` | Архитектура | design-architecture, implementation-plan, design-database |
| `site-content` | Контент | [CMS-content](../02-frontend/CMS-content.md), [Payload-CMS](../02-frontend/Payload-CMS.md), [I18n](../02-frontend/I18n.md), [Compliance-baseline](../05-auth-security/Compliance-baseline.md) |
| `site-design` | Дизайн | frontend-доки + дизайн-движок рантайма + дизайн-слой предпочтений |
| `site-frontend` | Frontend | implement-frontend + frontend-доки/паттерны |
| `site-backend` | Backend | implement-backend + backend/database-доки/паттерны |
| `site-seo` | SEO | [SEO](../02-frontend/SEO.md), [Performance](../02-frontend/Performance.md), [Analytics](../02-frontend/Analytics.md), [Accessibility](../02-frontend/Accessibility.md) |
| `site-review` | Ревью | review-чеклисты + code-review/security-review |
| `site-deploy` | Деплой | deploy + devops-доки + release-readiness |
| `capture-learnings` | Learning review | [post-task-learning-review](../../prompts/post-task-learning-review.md) |

## Петля накопления знаний

`capture-learnings` отделяет подтверждённое знание от шума и направляет его в правильный сток. Knowledge capture выполняется только после evidence или явного user approval:

- **Личные предпочтения → `D:\Work\AGENT-PREFERENCES.local.md`** (основной автосток). Только через
  безопасный инструмент `D:\Work\llm-dev-wiki\tools\update-local-preferences.ps1` со сканом секретов и
  обязательным dry-run; apply — после явного подтверждения. Правила — в
  [update-user-preferences](../../prompts/update-user-preferences.md) и
  [User preference memory](../07-mcp-and-ai-tools/User-preference-memory.md).
- **Обезличенное переиспользуемое знание → вики** (предлагается, подтверждается вручную): patterns,
  case-studies, lessons-learned, checklists. После правок вики — `pwsh tools\ci-local.ps1`. Общий контур —
  в [Agent self-improvement](../07-mcp-and-ai-tools/Agent-self-improvement.md).

Триггеры различаются по рантайму:

- **Claude Code** — Stop-hook в `D:\Work\.claude\settings.json` (скрипт
  `D:\Work\.agent-skills\hooks\stop-capture-reminder.ps1`) ненавязчиво напоминает запустить
  `capture-learnings` после задачи.
- **Codex** — Stop-hook'а нет; триггер — правило в `D:\Work\AGENTS.md`, которое Codex читает нативно.

Оба рантайма пишут предпочтения в один и тот же файл через один и тот же инструмент.

## Когда не использовать

- Мелкая правка готового проекта — иди сразу в нужный фазовый скилл, минуя оркестратор.
- Чистый research без сборки.
- Не превращать разовую вкусовую гипотезу в правило: предпочтение сохраняется только после явного approval.

## Как раскатывать и обновлять

- Отредактируй канон в `D:\Work\.agent-skills\<name>\SKILL.md`.
- Проверка: `pwsh D:\Work\.agent-skills\sync-skills.ps1 -DryRun`, затем боевой прогон без `-DryRun`.
- Альтернатива для распространения — `npx skills` (agent-skills CLI) или Codex `skill-installer`.

## Безопасность

- В предпочтения и вики не сохранять секреты, токены, cookies, приватные ключи, PII, customer payloads и
  закрытый код. Инструмент предпочтений даёт baseline guard, но не заменяет полноценный secret scanner.
- Личные референсы и preference-файл не пушить в GitHub-wiki; в вики — только обезличенные паттерны.

## Источники

- [Карта вики](overview.md)
- [Полный цикл разработки](../01-development-process/full-cycle.md)
- [Project playbooks](../13-playbooks/index.md)
- [Agent self-improvement](../07-mcp-and-ai-tools/Agent-self-improvement.md)
- [User preference memory](../07-mcp-and-ai-tools/User-preference-memory.md)
- [post-task learning review](../../prompts/post-task-learning-review.md)
- [update user preferences](../../prompts/update-user-preferences.md)
