---
title: "Pipeline status template"
category: "templates"
updated: "2026-07-11"
status: "active"
tags: ["pipeline", "orchestration", "resume", "artifacts", "website"]
source_priority: "internal"
---

# Pipeline status template

Шаблон файла `_pipeline-status.md` в корне проекта. Это машиночитаемое состояние цикла
`build-modern-site`: какие фазы пройдены, где лежат их артефакты и с какой фазы продолжать после
перезапуска сессии или компакции контекста. Без этого файла состояние пайплайна живёт только в чате
и теряется вместе с ним.

Канонический список фаз — [site pipeline map](../01-development-process/site-pipeline-map.md).

## Когда использовать

- Новый файл создаётся только bootstrap-инструментом:
  `pwsh tools/new-site-pipeline-status.ps1 -ProjectRoot <путь> -ProjectName "<имя>" -Playbook <playbook>`
  (по умолчанию dry-run, запись — `-Apply`). Дальше оркестратор `build-modern-site` обновляет файл
  после каждой фазы.
- Новая сессия в проекте: если файл существует, оркестратор читает его и артефакты завершённых фаз
  и продолжает с первой незавершённой фазы — не переспрашивая discovery заново.

## Когда не использовать

- Мелкая правка вне цикла (одиночный вызов `site-frontend`/`site-review`) — файл не трогается.
- Не хранить в файле секреты, доступы и приватные URL клиентов — только статусы и ссылки на
  локальные артефакты проекта.

## Правила ведения

1. Статусы фаз: `done` (quality gate пройден), `in-progress`, `skipped` (с причиной — молчаливый
   пропуск запрещён), `pending`.
2. Каждая `done`-фаза указывает проверяемый artifact/evidence. Для файлов используй backtick-path
   относительно корня проекта; для `site-deploy` допустим staging/production URL. `done` с `—`
   запрещён: строка статуса должна доказывать, чем закрыта фаза.
3. Дату ставить в формате `YYYY-MM-DD`; при повторном прохождении фазы дата обновляется.
4. Файл в корне проекта, рядом с `_competitive-analysis.md`; в вики не переносится (приватные данные проекта).

## Шаблон

```markdown
# Pipeline status — <имя проекта>

Playbook: <landing | saas | ecommerce | marketplace | api-only-backend | ...>
Обновлено: YYYY-MM-DD

| # | Фаза | Статус | Дата | Артефакт |
|---|------|--------|------|----------|
| 1 | preflight | done | YYYY-MM-DD | `_preflight.md` |
| 2 | site-discovery | done | YYYY-MM-DD | `_discovery.md` |
| 3 | playbook | done | YYYY-MM-DD | `_pipeline-status.md` (строка Playbook выше) |
| 4 | site-competitive-analysis | done | YYYY-MM-DD | `_competitive-analysis.md` |
| 5 | site-stack | done | YYYY-MM-DD | `_stack.md` |
| 6 | site-architecture | in-progress | YYYY-MM-DD | `_architecture.md` |
| 7 | project-agents | pending | — | `AGENTS.md` |
| 8 | site-content | pending | — | `_content-model.md` |
| 9 | site-design | pending | — | `DESIGN-DIRECTION.md` (лендинг) / токены |
| 10 | site-backend | pending | — | `_backend-gate.md` |
| 11 | site-frontend | pending | — | `_frontend-smoke.md` |
| 12 | site-seo | pending | — | `_seo-report.md` |
| 13 | site-review | pending | — | `_review-report.md` |
| 14 | site-deploy | pending | — | `_deploy.md` или production URL |
| 15 | site-handoff | pending | — | `handoff.md` |
| 16 | post-release | pending | — | `_post-release-plan.md` |
| 17 | capture-learnings | pending | — | `_learning-review.md` |

## Пропуски и причины

- <фаза>: skipped — <причина, например playbook api-only-backend>

## Открытые вопросы

- <что блокирует следующую фазу>
```

## Связанные документы

- [Оркестратор build-modern-site](../00-start-here/skill-system.md) — как фазы связаны в цикл.
- [Site pipeline map](../01-development-process/site-pipeline-map.md) — канонические 17 фаз.
- [Полный цикл разработки](../01-development-process/full-cycle.md) — стадии и гейты.
- [Handoff template](handoff.md) — финальный артефакт передачи клиенту.
