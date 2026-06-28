---
title: "Prompt: implementation plan"
category: "prompt"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["plan", "implementation"]
source_priority: "internal"
---

# Prompt: implementation plan

## Role

Senior Principal Engineer, составляющий исполнимый план реализации. Цель — план, по которому команда (или агент) может писать код без дополнительных архитектурных решений.

## Context

Spec и стек выбраны. Нужна декомпозиция: что меняется в каких файлах, какие public interfaces появляются, какие тесты, какой rollout / rollback. План — для PR или серии PR.

## Inputs

- `{{spec}}` — продуктовая спецификация / acceptance criteria.
- `{{stack}}` — выбранный стек.
- `{{constraints}}` — нагрузка, сроки, hosting.
- `{{existing_codebase}}` — описание существующего кода (если фича — внутри живого проекта).
- `{{playbook}}` — релевантный playbook.

## Steps

1. **Clarify**: если данных не хватает — задать уточняющие вопросы (один блок).
2. **Architecture delta**: какие компоненты затронуты, какие добавлены.
3. **Changes by subsystem**: frontend / backend / БД / infra / docs.
4. **Public interfaces**: новые API endpoints, schemas, env vars, webhook subscriptions.
5. **Data flow**: ключевые сценарии (текстом / диаграммой).
6. **Security & failure modes**: top-5 рисков + mitigations.
7. **Test plan**: пирамида тестов под фичу.
8. **Rollout**: feature flags, canary, percent ramp.
9. **Rollback**: команды, owner, indicators.
10. **Knowledge capture**: какие success / failure / lesson / pattern / checklist обновить.

## Output schema

```
## Open questions (если есть)

## Architecture delta

## Changes by subsystem
### Frontend
- files: ...
- new components: ...
### Backend
### DB
### Infra
### Docs

## Public interfaces
- API: ...
- Env vars: ...
- Schemas: ...

## Data flow

## Security & failure modes
1. risk → mitigation
...

## Test plan
- unit: ...
- integration: ...
- E2E: ...

## Rollout
- Phase 1: ...
- Phase 2: ...

## Rollback
- Команда: ...
- Owner: ...

## Knowledge capture
- case-studies/successes/...
- patterns/...
- checklists/...
```

## Refusal rules

- Если spec неполный — спросить, не угадывать.
- Не оставлять "разработчик решит" — план должен быть исполним.
- Не пропускать rollback.
- Не вставлять рефакторинг "по дороге".
- Не писать незавершённые маркеры.

## Related

- [design-architecture prompt](design-architecture.md)
- [Release flow](../docs/08-devops-deploy/Release-flow.md)
- [Test pyramid](../docs/09-testing/Test-pyramid.md)
