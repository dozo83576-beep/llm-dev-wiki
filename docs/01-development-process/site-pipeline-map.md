---
title: "Site pipeline map"
category: "process"
updated: "2026-08-10"
status: "active"
tags: ["site", "pipeline", "skills", "orchestration", "resume", "contract"]
source_priority: "internal"
---

# Site pipeline map

Эта карта применяется только при `routeMode: full-pipeline`. Для `direct` status-файл и фазовый граф не создаются; выполняются только gates, релевантные локальной задаче.

Человекочитаемое представление [pipeline contract](../../resources/site-pipeline-contract.json).
JSON-контракт v2 — единственный источник фаз, зависимостей, canonical artifacts, primary playbook,
supporting guides и delivery profiles. Bootstrap, verifier и `build-modern-site` потребляют его;
эта карта не вводит собственные правила.

В цикле сохраняются 17 контрольных фаз, но выполнение управляется графом зависимостей, а не номером
строки. После архитектуры, project rules и контента `site-design` и `site-backend` независимы;
`site-frontend` ждёт оба применимых результата.

| # | Фаза | Исполнитель | Canonical artifact | Зависит от |
|---|------|-------------|--------------------|------------|
| 1 | preflight | `new-site-preflight.ps1` | `_preflight.md` | — |
| 2 | site-discovery | `site-discovery` | `_discovery.md` | preflight |
| 3 | playbook | decision router | `_pipeline-status.md` | site-discovery |
| 4 | site-competitive-analysis | `site-competitive-analysis` | `_competitive-analysis.md` | site-discovery, playbook |
| 5 | site-stack | `site-stack` | `_stack.md` | site-discovery, playbook, site-competitive-analysis |
| 6 | site-architecture | `site-architecture` | `_architecture.md` | site-stack, site-competitive-analysis |
| 7 | project-agents | create project rules | `AGENTS.md` | site-architecture |
| 8 | site-content | `site-content` | `_content-model.md` | site-architecture, site-competitive-analysis, project-agents |
| 9 | site-design | `site-design` | `DESIGN-DIRECTION.md` | site-architecture, site-competitive-analysis, site-content, project-agents |
| 10 | site-backend | `site-backend` | `_backend-gate.md` | site-architecture, site-content, project-agents |
| 11 | site-frontend | `site-frontend` | `_frontend-smoke.md` | site-content, site-design, site-backend |
| 12 | site-seo | `site-seo` | `_seo-report.md` | site-content, site-frontend |
| 13 | site-review | `site-review` | `_review-report.md` | site-backend, site-frontend, site-seo |
| 14 | site-deploy | `site-deploy` | `_deploy.md` | site-review |
| 15 | site-handoff | `site-handoff` | `handoff.md` | site-deploy |
| 16 | post-release | `site-handoff` | `_post-release-plan.md` | site-handoff |
| 17 | capture-learnings | `capture-learnings` | `_learning-review.md` | post-release |

Зависимость считается закрытой статусом `done` или контрактным `not-applicable`; для единственной
optional-фазы `post-release` также допустим обоснованный `skipped`.

`capture-learnings` зависит от `post-release`: финальное знание не фиксируется до deploy, handoff и решения о post-release. Пропуск `post-release` допустим только с фактической причиной, после чего он считается завершённой зависимостью.
Проект, где хостинг ещё не выбран, закрывает фазу сразу после ревью — иначе выводы остаются в
`_learning-review.md` и не доезжают до вики. Эксплуатационные наблюдения после прода дописываются
отдельно, когда появятся.

## Primary playbook и supporting guides

У проекта ровно один `Playbook`: `landing`, `content-site`, `saas`, `ecommerce`,
`admin-dashboard`, `marketplace`, `ai-rag-app`, `api-only-backend` или `real-time-app`.
Платформенные ограничения не конкурируют с типом продукта и фиксируются в `Supporting-Guides`:
например, e-commerce + `shopify-hydrogen` или marketplace + `wordpress-woocommerce`.

## Delivery profiles

| Profile | Контрактная применимость |
|---------|--------------------------|
| `public-static` | `site-backend` = `not-applicable` |
| `public-fullstack` | все фазы применимы |
| `private-app` | SEO выполняется как сокращённый `noindex` gate |
| `api-only` | content, design, frontend и SEO = `not-applicable` |

`not-applicable` определяется только profile и требует структурированной причины. `skipped`
используется только для `post-release` и также требует причины.

## Проверка

```powershell
pwsh tools/verify-site-pipeline.ps1
pwsh tools/verify-site-pipeline.ps1 -ProjectRoot <project> -RequirePhase site-review
pwsh tools/verify-site-pipeline.ps1 -ProjectRoot <project> -RequireComplete
```

Verifier проверяет контракт, схему status v2, граф, ISO-даты, точные artifacts, непустые файлы и
containment с учётом symlink/junction.
