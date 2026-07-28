---
title: "External site skills"
category: "ai-tools"
updated: "2026-07-21"
status: "active"
tags: ["skills", "site-building", "agents"]
source_priority: "internal"
---

# External site skills

## Назначение

Как подключать сторонние скиллы из `alirezarezvani/claude-skills` к системе сборки сайтов в `D:\Work`.
Канон остаётся в `D:\Work\llm-dev-wiki\agent-skills`; внешние скиллы — optional helpers, которые усиливают
отдельную фазу, но не заменяют wiki, project-local `AGENTS.md` и `D:\Work\AGENT-PREFERENCES.local.md`.

## Правила

- Сначала проверь доступность: `pwsh D:\Work\tools\check-ai-tools.ps1` и директории `~\.codex\skills`,
  `~\.claude\skills`.
- По умолчанию внешние helpers не вызываются. Допустим максимум один узкий helper на фазу и только
  когда сформулировано, какой конкретный пробел он закрывает.
- Внешний helper даёт draft/review/идеи; финальное решение сверяется с wiki и локальными правилами.
- Не устанавливай весь внешний пакет как default: в нём есть конфликтующие имена, включая `site-architecture`.
- Не вызывай helpers, которые навязывают стек или scope, если это не одобрено явно.

## Когда использовать

- Нужно усилить фазу сайта узким внешним helper-ом: рынок, конкуренты, copy, CRO, SEO, QA, security или ops.
- Helper уже установлен в нужном рантайме и не конфликтует с локальным каноном.
- Результат helper-а можно проверить локальными docs/checklists/tools.

## Когда не использовать

- Простая задача решается текущим фазовым `site-*` скиллом и wiki без внешнего helper-а.
- Helper навязывает стек, scaffold или scope до завершения discovery/stack decision.
- Задача содержит PII, секреты или закрытые клиентские данные, которые нельзя отправлять во внешний контекст.

## Маппинг по фазам

| Фаза | Единственный допустимый optional helper выбирается из |
| --- | --- |
| Discovery / market | `market-research`, `product-discovery`, `marketing-context` |
| Competitors | `competitive-intel`, `competitive-teardown`, `competitor-alternatives` |
| Content / copy | `content-strategy`, `copywriting`, `copy-editing`, `brand-guidelines` |
| Design / CRO | `ux-researcher-designer`, `ui-design-system`, `page-cro`, `form-cro`, `signup-flow-cro`, `ab-test-setup` |
| Frontend / backend | `senior-frontend`, `senior-backend`, `api-design-reviewer`, `database-designer` |
| SEO / analytics | `seo-audit`, `schema-markup`, `aeo`, `analytics-tracking`, `programmatic-seo` |
| Review / release | `code-reviewer`, `senior-qa`, `dependency-auditor`, `security-pen-testing`, `ship-gate`, `env-secrets-manager` |
| Deploy / ops | `ci-cd-pipeline-builder`, `observability-designer`, `runbook-generator` |

## Исключить из default-пути

- `landing-page-generator` — генерирует Next.js/React/Tailwind и может обойти default Astro/KISS.
- `saas-scaffolder` — создаёт слишком широкий SaaS-boilerplate до подтверждения scope.
- `design-system` — ведёт собственный onboarding и может конфликтовать с `AGENT-PREFERENCES.local.md`.
- C-level, business, finance, legal-heavy и compliance-heavy helpers — использовать только по явному запросу
  или при реальном compliance-блокере.

## Частые ошибки

- Установить весь skill-pack глобально и получить конфликт имён с локальными `site-*` скиллами.
- Принять draft внешнего helper-а как source of truth без проверки wiki, project-local rules и валидаторов.
- Использовать генератор лендингов, который меняет выбранный стек и обходится без `site-stack`.

## Установка subset-а

Ставь только выбранный subset и только в нужные рантаймы:

```powershell
npx -y agent-skills-cli install alirezarezvani/claude-skills -g --agent codex claude --skill <skill-names> --yes
```

Не включай `site-architecture` и другие имена, совпадающие с локальным каноном `D:\Work\llm-dev-wiki\agent-skills`.

## Проверка

- `pwsh D:\Work\tools\check-ai-tools.ps1`
- `pwsh D:\Work\llm-dev-wiki\tools\verify-agent-skills.ps1`
- `pwsh D:\Work\llm-dev-wiki\agent-skills\sync-skills.ps1 -DryRun`
- `pwsh D:\Work\llm-dev-wiki\tools\ci-local.ps1`

## Источники

- [Система скиллов сборки сайтов](../00-start-here/skill-system.md)
- [Recommended MCP servers](Recommended-MCP-servers.md)
- [External design skills](External-design-skills.md)
- agent-skills CLI (`npx agent-skills-cli install`) — проверено 2026-06-21.
