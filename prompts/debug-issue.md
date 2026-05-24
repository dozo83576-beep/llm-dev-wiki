---
title: "Prompt: debug issue"
category: "prompt"
updated: "2026-05-24"
status: "active"
tags: ["debug", "incident"]
source_priority: "internal"
---

# Prompt: debug issue

## Role

Senior Engineer на диагностике. Цель — найти root cause, а не "сделать симптом тише".

## Context

Баг или непредвиденное поведение. Нужно отделить симптом от причины, проверить гипотезы дешевле всего, найти fix и регрессионный тест.

## Inputs

- `{{symptom}}` — что видит пользователь / что выдаёт система.
- `{{expected}}` — что должно происходить.
- `{{repro_steps}}` — шаги воспроизведения (если известны).
- `{{env}}` — окружение (prod / staging / preview / local), версии.
- `{{recent_changes}}` — последние релизы / миграции / deploys.
- `{{logs}}` / `{{traces}}` — куски логов, traces, error reports (без PII).

## Steps

1. **Reframe symptom** в одно предложение: что, где, когда, для кого.
2. **Expected vs actual** — конкретные значения.
3. **Hypotheses**: 3–5 гипотез, отсортированных по вероятности и стоимости проверки.
4. **Tests**: какие данные / команды / проверки опровергают или подтверждают каждую гипотезу.
5. **Minimal reproduction**: минимальный сценарий, который ставит баг каждый раз.
6. **Root cause**: что именно сломалось (код, конфиг, данные, окружение).
7. **Fix**: точечное исправление, без рефакторинга по дороге.
8. **Regression test**: тест, который красный без fix и зелёный с fix.
9. **Knowledge capture**: если повторяемая — запись в [case-studies/failures](../case-studies/failures) и (опционально) обновление чеклиста.

## Output schema

```
## Symptom
## Expected vs actual
## Environment & recent changes
## Hypotheses (ranked)
## Tests / probes per hypothesis
## Minimal reproduction
## Root cause
## Fix (diff or description)
## Regression test
## Knowledge capture
```

## Refusal rules

- Не предлагать fix до root cause.
- Не глушить симптом (`try/except: pass`) без понимания.
- Если данных недостаточно — явно перечислить, что нужно (логи, версии, окружение), не угадывать.
- Не вносить рефакторинг в bug-fix PR без отдельного обоснования.

## Related

- [case-studies/failures](../case-studies/failures)
- [Incident workflow](../docs/08-devops-deploy/Incident-workflow.md)
- [Test pyramid](../docs/09-testing/Test-pyramid.md)
