---
title: "LLM Dev Wiki"
category: "start"
updated: "2026-07-05"
status: "active"
tags: ["llm", "frontend", "backend", "wiki", "obsidian"]
source_priority: "internal"
---

# LLM Dev Wiki

[![Wiki audit](https://github.com/dozo83576-beep/llm-dev-wiki/actions/workflows/wiki-audit.yml/badge.svg)](https://github.com/dozo83576-beep/llm-dev-wiki/actions/workflows/wiki-audit.yml)

Эта вики хранит практические знания для разработки сайтов и web-приложений: выбор стека, frontend, backend, базы данных, API, безопасность, MCP, AI-инструменты, DevOps, тестирование, промпты и проектные уроки.

Основной источник правды: Git-репозиторий `dozo83576-beep/llm-dev-wiki`. Локальное хранилище Obsidian: `D:\Work\llm-dev-wiki`.

## Как пользоваться

1. Полный список документов и их статус: [docs/INDEX.md](docs/INDEX.md) (генерируется через `tools/build-index.ps1`).
2. Навигация по разделам: [карта вики](docs/00-start-here/overview.md).
3. Для нового проекта открой [выбор стека](docs/01-development-process/stack-selection.md) и [discovery-чеклист](checklists/project-discovery.md).
4. Для реализации используй разделы `docs/02-frontend`, `docs/03-backend`, `docs/04-databases`, `docs/06-api-design`.
5. Перед выпуском проходи [security review](checklists/security-review.md) и [release readiness](checklists/release-readiness.md).
6. После проекта фиксируй удачные решения в [case-studies/successes](case-studies/successes), ошибки в [case-studies/failures](case-studies/failures), короткие выводы в [lessons-learned](lessons-learned).

## Система скиллов (Claude Code + Codex)

Сквозную сборку сайтов ведут вызываемые скиллы: оркестратор `build-modern-site`, фазовые `site-*` и controlled learning loop `capture-learnings`. Канонические 17 фаз описаны в [site pipeline map](docs/01-development-process/site-pipeline-map.md). Скиллы — тонкие роутеры в эту вики; они не обучаются автономно и не меняют веса модели, а помогают сохранять подтверждённые знания в wiki/preferences после evidence или явного approval. Описание: [docs/00-start-here/skill-system.md](docs/00-start-here/skill-system.md).

## Локальные проверки и CI

- Полный локальный гейт: `pwsh tools/ci-local.ps1` (audit, skills, quality, INDEX, embeddings, evals); он же выполняется в GitHub Actions (`.github/workflows/wiki-audit.yml`).
- Быстрый pre-release/pre-push гейт для wiki/tooling/pipeline правок: `pwsh tools/pre-release-local.ps1`.
- Быстрый pre-commit гейт (ссылки/front matter + паритет скиллов) подключается один раз: `git config core.hooksPath tools/git-hooks`.
- После правок в `agent-skills/` раскатай и проверь канон: `pwsh tools/verify-agent-skills.ps1`,
  `pwsh agent-skills/sync-skills.ps1 -DryRun`, `pwsh agent-skills/sync-skills.ps1`, затем
  `pwsh tools/verify-agent-skills.ps1 -VerifyUserRuntimes`.

## Принципы качества

- Документы короткие, проверяемые и связаны внутренними ссылками.
- Рекомендации опираются на официальные документы или зрелую production-практику.
- Секреты, API-ключи, приватные данные клиентов и закрытый код в вики не сохраняются.
- Любой повторяемый успех превращается в паттерн, любая существенная ошибка превращается в анти-паттерн и чеклист.

## Актуальные источники

- [React Docs](https://react.dev/)
- [Next.js Docs](https://nextjs.org/docs)
- [TypeScript Docs](https://www.typescriptlang.org/docs/)
- [Node.js Docs](https://nodejs.org/en/learn)
- [NestJS Docs](https://docs.nestjs.com/)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Prisma Docs](https://www.prisma.io/docs)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Model Context Protocol Docs](https://modelcontextprotocol.io/docs)
- [OpenAI Platform Docs](https://platform.openai.com/docs)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
