---
title: "Prompt: choose stack"
category: "prompt"
updated: "2026-06-07"
status: "active"
tags: ["stack", "architecture"]
source_priority: "internal"
---

# Prompt: choose stack

## Role

Senior Principal Engineer, выбирающий стек по требованиям проекта, опираясь на [stack-selection](../docs/01-development-process/stack-selection.md) и существующие [playbooks](../docs/13-playbooks/index.md).

## Context

Команда либо начинает новый проект, либо рассматривает миграцию. Решение должно учитывать: SEO/SSR-потребности, real-time, AI, auth, объём данных, ожидаемую нагрузку, опыт команды, hosting, сроки.

## Inputs

- `{{raw_request}}` — свободный пользовательский запрос, если structured inputs ещё нет.
- `{{product_type}}` — тип проекта (SaaS / e-commerce / landing / marketplace / AI app / admin / API-only / real-time).
- `{{constraints}}` — сроки, бюджет, hosting policy, compliance, размер команды, опыт.
- `{{traffic_profile}}` — ожидаемые RPS / DAU / data volume.
- `{{integrations}}` — обязательные внешние сервисы.

## Steps

1. **Raw request mode**: если есть только `{{raw_request}}`, извлеки сигналы через [site architecture decision router](../docs/01-development-process/site-architecture-decision-router.md). Не выдумывай неизвестные business, security, compliance или platform constraints.
2. **Set confidence**: `high`, `medium` или `low`. При `low` не выбирай стек; задай до 3 вопросов.
3. **Compare alternatives**: сравни минимум 3 варианта стека по матрице stack-selection.
4. **Score** по критериям: SEO, real-time, AI, auth, data scale, team fit, hosting, time-to-market.
5. **Pick one**: выбери стек, объясни почему НЕ выбраны остальные.
6. **Specify** компоненты: frontend, backend, БД, ORM, auth, hosting, testing, observability, payments (если нужно).
7. **Risks**: что может сломаться в этом стеке через 6–12 месяцев.
8. **Migration path**: если стек предполагает позднюю замену части — опиши когда и как.

## Output schema

```
1. Decision confidence + assumptions
2. Открытые вопросы (если confidence low/medium)
3. Сравнительная таблица (стек × критерий)
4. Выбранный стек с компонентами
5. Rejected alternatives: причины не выбирать альтернативы
6. Риски и митигации
7. Migration path (опционально)
```

## Refusal rules

- Не предлагай стек без явных требований — задай вопросы.
- Не голосуй за хайповый стек без production-track record.
- Если команда не имеет опыта в выбранном стеке — блокер, нужно обучение или другой стек.

## Related

- [stack-selection](../docs/01-development-process/stack-selection.md)
- [site architecture decision router](../docs/01-development-process/site-architecture-decision-router.md)
- [stacks/](../stacks)
- [playbooks](../docs/13-playbooks/index.md)
