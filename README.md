---
title: "LLM Dev Wiki"
category: "start"
updated: "2026-05-24"
status: "active"
tags: ["llm", "frontend", "backend", "wiki", "obsidian"]
source_priority: "internal"
---

# LLM Dev Wiki

[![Wiki audit](https://github.com/dozo83576-beep/llm-dev-wiki/actions/workflows/wiki-audit.yml/badge.svg)](https://github.com/dozo83576-beep/llm-dev-wiki/actions/workflows/wiki-audit.yml)

Эта вики хранит практические знания для разработки сайтов и web-приложений: выбор стека, frontend, backend, базы данных, API, безопасность, MCP, AI-инструменты, DevOps, тестирование, промпты и проектные уроки.

Основной источник правды: Git-репозиторий `dozo83576-beep/llm-dev-wiki`. Локальное хранилище Obsidian: `D:\Work\llm-dev-wiki`.

## Как пользоваться

1. Начинай с [[docs/00-start-here/overview|карты вики]].
2. Для нового проекта открой [[docs/01-development-process/stack-selection|выбор стека]] и [[checklists/project-discovery|discovery-чеклист]].
3. Для реализации используй разделы `docs/02-frontend`, `docs/03-backend`, `docs/04-databases`, `docs/06-api-design`.
4. Перед выпуском проходи [[checklists/security-review|security review]] и [[checklists/release-readiness|release readiness]].
5. После проекта фиксируй удачные решения в `case-studies/successes`, ошибки в `case-studies/failures`, короткие выводы в `lessons-learned`.

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
