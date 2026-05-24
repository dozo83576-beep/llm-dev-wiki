---
title: "Prompt: choose stack"
category: "prompt"
updated: "2026-05-24"
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

- `{{product_type}}` — тип проекта (SaaS / e-commerce / landing / marketplace / AI app / admin / API-only / real-time).
- `{{constraints}}` — сроки, бюджет, hosting policy, compliance, размер команды, опыт.
- `{{traffic_profile}}` — ожидаемые RPS / DAU / data volume.
- `{{integrations}}` — обязательные внешние сервисы.

## Steps

1. **Compare alternatives**: сравни минимум 3 варианта стека по матрице stack-selection.
2. **Score** по критериям: SEO, real-time, AI, auth, data scale, team fit, hosting, time-to-market.
3. **Pick one**: выбери стек, объясни почему НЕ выбраны остальные.
4. **Specify** компоненты: frontend, backend, БД, ORM, auth, hosting, testing, observability, payments (если нужно).
5. **Risks**: что может сломаться в этом стеке через 6–12 месяцев.
6. **Migration path**: если стек предполагает позднюю замену части — опиши когда и как.

## Output schema

```
1. Сравнительная таблица (стек × критерий)
2. Выбранный стек с компонентами
3. Причины не выбирать альтернативы (по одной на каждую)
4. Риски и митигации
5. Migration path (опционально)
```

## Refusal rules

- Не предлагай стек без явных требований — задай вопросы.
- Не голосуй за хайповый стек без production-track record.
- Если команда не имеет опыта в выбранном стеке — блокер, нужно обучение или другой стек.

## Related

- [stack-selection](../docs/01-development-process/stack-selection.md)
- [stacks/](../stacks)
- [playbooks](../docs/13-playbooks/index.md)
