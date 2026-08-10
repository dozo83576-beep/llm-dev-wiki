---
title: "GitHub repositories"
category: "resource"
updated: "2026-06-21"
status: "active"
tags: ["resources"]
source_priority: "mixed"
---

# GitHub repositories

- [vercel/next.js](https://github.com/vercel/next.js) — Next.js framework.
- [facebook/react](https://github.com/facebook/react) — React.
- [prisma/prisma](https://github.com/prisma/prisma) — Prisma ORM.
- [nestjs/nest](https://github.com/nestjs/nest) — NestJS.
- [fastapi/fastapi](https://github.com/fastapi/fastapi) — FastAPI.
- [shadcn-ui/ui](https://github.com/shadcn-ui/ui) — shadcn/ui.
- [supabase/supabase](https://github.com/supabase/supabase) — Supabase platform.
- [qdrant/qdrant](https://github.com/qdrant/qdrant) — vector database.
- [pgvector/pgvector](https://github.com/pgvector/pgvector) — PostgreSQL vector extension.
- [openai/openai-node](https://github.com/openai/openai-node) — OpenAI Node SDK.
- [openai/openai-python](https://github.com/openai/openai-python) — OpenAI Python SDK.
- [openai/evals](https://github.com/openai/evals) — AI evaluation framework.

## Дизайн-скиллы для AI-агентов (anti-slop / motion)

Сторонние скиллы, на принципах которых построены наши дизайн-доки. Конспекты — в вики
(single source); сами репозитории — внешняя зависимость, обновляются upstream.

- [emilkowalski/skill](https://github.com/emilkowalski/skill) — Emil Kowalski (Sonner/Vaul), motion/анимации. Установка: `npx skills add emilkowalski/skill`. Конспект → [docs/02-frontend/Motion.md](../docs/02-frontend/Motion.md). Проверено 2026-06-20.
- [pbakaus/impeccable](https://github.com/pbakaus/impeccable) — audited 2026-08-10: не устанавливается из-за широкого trigger, дублирующих commands/hooks и слабой добавочной ценности detector в локальном пилоте. Контекстные surface modes и bounded visual QA вынесены в [anti-ai-slop pattern](../patterns/frontend/anti-ai-slop-design.md).
- [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) — audited 2026-08-10: v2 experimental и строгие варианты не устанавливаются. Качественные оси variance/density/motion и preservation при redesign вынесены в [anti-ai-slop pattern](../patterns/frontend/anti-ai-slop-design.md) без AIDA, GSAP и стилевых квот.
