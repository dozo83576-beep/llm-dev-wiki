---
title: "Site pipeline map"
category: "process"
updated: "2026-07-05"
status: "active"
tags: ["site", "pipeline", "skills", "orchestration", "resume"]
source_priority: "internal"
---

# Site pipeline map

Каноническая карта фаз `build-modern-site`. Все документы, hooks и runtime prompts должны ссылаться
на эту карту, а не держать отдельную нумерацию. В цикле 17 фаз: стадии `full-cycle.md`
`Тестирование` и `Security review` объединены в `site-review`; `Пост-релиз` остаётся optional
планом maintenance внутри `site-handoff`.

| # | Фаза | Skill / действие | Вход | Выход | Gate |
|---|------|------------------|------|-------|------|
| 1 | preflight | `new-site-preflight.ps1` | raw request | `_preflight.md` (route, stack hint, audit command) | `ready` или вопросы `needs-discovery` |
| 2 | site-discovery | `site-discovery` | raw request / preflight | `_discovery.md` | требования, reference-pointers, acceptance |
| 3 | playbook | decision router | `_discovery.md` | playbook в `_pipeline-status.md` | выбран один playbook или обоснованный mix |
| 4 | site-competitive-analysis | `site-competitive-analysis` | `_discovery.md` | `_competitive-analysis.md` | 5-6 конкурентов, UX/content/stack/visual signals |
| 5 | site-stack | `site-stack` | `_discovery.md`, `_competitive-analysis.md` | `_stack.md` | один стек, rejected alternatives, versions check |
| 6 | site-architecture | `site-architecture` | `_stack.md`, `_competitive-analysis.md` | `_architecture.md` | компоненты, data/API flow, риски, этапы |
| 7 | project-agents | создать project `AGENTS.md` | `_architecture.md`, stack | `AGENTS.md` проекта | команды и quality gate проекта зафиксированы |
| 8 | site-content | `site-content` | `_architecture.md`, `_competitive-analysis.md` | `_content-model.md` | контент-модель, legal/consent, i18n |
| 9 | site-design | `site-design` | `_content-model.md`, references | `DESIGN-DIRECTION.md` / tokens | выбранное направление, a11y/motion/tokens |
| 10 | site-backend | `site-backend` | `_architecture.md`, `_content-model.md` | код + тесты, `_backend-gate.md` | backend/API/database checks без block |
| 11 | site-frontend | `site-frontend` | backend, `_content-model.md`, design tokens | код, `_frontend-smoke.md` | frontend checks и browser verification |
| 12 | site-seo | `site-seo` | финальные public pages | `_seo-report.md` (metadata, sitemap, metrics) | SEO/performance/analytics checks |
| 13 | site-review | `site-review` | реализованный проект | `_review-report.md` (чеклисты, smoke, sign-off) | testing + security + legal/UAT без block |
| 14 | site-deploy | `site-deploy` | passed review | `_deploy.md` (staging/production URL) | release/infrastructure/rollback gates |
| 15 | site-handoff | `site-handoff` | production deploy | `handoff.md` | post-deploy smoke, доступы, acceptance |
| 16 | post-release | maintenance plan | `handoff.md` | `_post-release-plan.md` (30-90 day review) | optional, дата/условия зафиксированы |
| 17 | capture-learnings | `capture-learnings` | evidence / approval | `_learning-review.md` + preferences/wiki artifacts | learning review выполнен |

## Допустимые пропуски

- `api-only-backend`: фазы 8, 9, 11 и 12 получают `skipped` с причиной; фаза 7
  `project-agents` обязательна всегда, поэтому после 7 идёт 10, затем 13.
- Внутренние admin/private проекты: `site-seo` может быть сокращён до `noindex`/basic metadata, но не
  удалён молча.
- `post-release` optional, но строка фазы остаётся в `_pipeline-status.md`: дата review или причина
  пропуска фиксируются явно.

## Проверка связности

`tools/verify-site-pipeline.ps1` проверяет, что эта карта, `build-modern-site`, `_pipeline-status.md`,
hook context и Codex `openai.yaml` используют один и тот же набор фаз.
