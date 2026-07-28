---
title: "Pipeline status template"
category: "templates"
updated: "2026-07-21"
status: "active"
tags: ["pipeline", "orchestration", "resume", "contract-v2"]
source_priority: "internal"
---

# Pipeline status template

`_pipeline-status.md` — машиночитаемое состояние contract v2. Новый файл создаётся только атомарным
bootstrap-инструментом (по умолчанию dry-run):

```powershell
pwsh tools/new-site-pipeline-status.ps1 -ProjectRoot <path> -ProjectName "<name>" -Playbook <primary> -DeliveryProfile <profile> -SupportingGuides <guide> -Apply
```

Canonical phases, dependencies и artifacts берутся из
[`resources/site-pipeline-contract.json`](../../resources/site-pipeline-contract.json), а не из шаблона.

## Правила

- Метаданные обязательны: `Contract-Version`, один `Playbook`, `Supporting-Guides`, `Delivery-Profile`.
- Статусы: `pending`, `in-progress`, `done`, `not-applicable`, `skipped`.
- `not-applicable` задаётся delivery profile; `skipped` допустим только для `post-release`.
- Любой не-pending статус имеет реальную дату `YYYY-MM-DD`.
- `done` указывает ровно canonical artifact: существующий непустой файл внутри physical project root.
- Resume идёт по готовности зависимостей, а не по первой строке с номером.

## Schema v2

```markdown
# Pipeline status — <project>

Contract-Version: 2
Playbook: <primary-playbook>
Supporting-Guides: <comma-separated guide ids или —>
Delivery-Profile: <public-static | public-fullstack | private-app | api-only>
Обновлено: YYYY-MM-DD

| # | Фаза | Статус | Дата | Артефакт |
|---|------|--------|------|----------|
| 1 | preflight | pending | — | `_preflight.md` |
| 2 | site-discovery | pending | — | `_discovery.md` |
| 3 | playbook | pending | — | `_pipeline-status.md` |
| 4 | site-competitive-analysis | pending | — | `_competitive-analysis.md` |
| 5 | site-stack | pending | — | `_stack.md` |
| 6 | site-architecture | pending | — | `_architecture.md` |
| 7 | project-agents | pending | — | `AGENTS.md` |
| 8 | site-content | pending | — | `_content-model.md` |
| 9 | site-design | pending | — | `DESIGN-DIRECTION.md` |
| 10 | site-backend | pending | — | `_backend-gate.md` |
| 11 | site-frontend | pending | — | `_frontend-smoke.md` |
| 12 | site-seo | pending | — | `_seo-report.md` |
| 13 | site-review | pending | — | `_review-report.md` |
| 14 | site-deploy | pending | — | `_deploy.md` |
| 15 | site-handoff | pending | — | `handoff.md` |
| 16 | post-release | pending | — | `_post-release-plan.md` |
| 17 | capture-learnings | pending | — | `_learning-review.md` |

## Неприменимые фазы

- <phase>: not-applicable — delivery-profile <profile>

## Пропуски и причины

- post-release: skipped — <явная причина>

## Открытые вопросы

- <что блокирует готовую по графу фазу>
```

Проверка: `pwsh tools/verify-site-pipeline.ps1 -ProjectRoot <path>`; перед production-ready
завершением — с `-RequireComplete`.
