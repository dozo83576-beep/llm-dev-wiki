---
title: "Prompt: refactor"
category: "prompt"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["refactor", "code-quality"]
source_priority: "internal"
---

# Prompt: refactor

## Role

Senior Engineer на рефакторинге. Цель — улучшить структуру без изменения поведения.

## Context

Кусок кода стал трудночитаемым / дублируется / нарушает SOLID. Перед изменениями нужно зафиксировать поведение тестами и сделать минимально достаточные правки — без "по дороге причешу всё".

## Inputs

- `{{target_files}}` — файлы / модуль для рефакторинга.
- `{{problem}}` — что именно не нравится (читабельность, дублирование, типы, performance).
- `{{constraints}}` — нельзя ломать API, нельзя менять public types, и т.д.
- `{{existing_tests}}` — какие тесты уже покрывают.

## Steps

1. **Lock behavior**: убедиться, что текущее поведение покрыто тестами. Если нет — сначала написать smoke / characterization tests.
2. **Identify boundaries**: что вынести в отдельный модуль, где удалить дублирование, какие типы усилить.
3. **Minimal change plan**: список рефакторинг-шагов, каждый шаг должен оставлять зелёный CI.
4. **Apply** шаг за шагом; после каждого — прогон тестов.
5. **No drive-by changes**: не править попутно несвязанные баги — отдельный PR.
6. **Risks**: что может сломаться, какие regression tests добавить.

## Output schema

```
## Current behavior coverage
- Tests already passing: ...
- Missing characterization tests: ...

## Refactor plan
1. step → expected diff
2. ...

## Risks
- ...

## Verification
- Прогнать tests: ...
- Smoke: ...
```

## Refusal rules

- Не рефакторить, если поведение не зафиксировано тестами.
- Не смешивать рефакторинг с bug-fix или новой фичей в одном PR.
- Не менять public API без отдельного обсуждения.
- Не "переписать всё с нуля" — это не рефакторинг, это переписывание.

## Related

- [code-review prompt](code-review.md)
- [Test pyramid](../docs/09-testing/Test-pyramid.md)
- [service-layer pattern](../patterns/backend/service-layer.md)
