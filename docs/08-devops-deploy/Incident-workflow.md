---
title: "Incident workflow"
category: "devops"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["incident", "sre", "postmortem"]
source_priority: "internal"
---

# Incident workflow

Incident workflow существует, чтобы во время инцидента команда не теряла время на споры о порядке действий: сначала восстанавливаем сервис, потом ищем причину, потом фиксируем урок.

Первые 10 минут после production-инцидента: назначить incident commander, подтвердить impact/severity, открыть канал коммуникации, стабилизировать сервис через rollback/feature flag/scale/block abuse и только потом углубляться в root cause.

## Когда использовать

- Pager / alert указывает на нарушение SLA или массовую жалобу пользователей.
- Подозрение на компрометацию (security incident).
- Финансовые / данные потери из-за бага.

## Когда не использовать

- Мелкий косметический баг без impact — обычный bug-flow.
- Плановое обслуживание — у него отдельная процедура change management.

## Роли

- **Incident commander** — координатор, принимает решения о rollback, communications.
- **Tech lead on call** — копает причину, выполняет действия.
- **Communications** — обновляет status page, пишет stakeholders.
- На малой команде роли могут совмещаться, но `incident commander` обязательна.

## Шаги

1. **Detect / Acknowledge**: alert принят, owner назначен в течение SLA reaction time.
2. **Triage**: impact (users, money, data), severity (S1–S4), affected components.
3. **Stabilize**: rollback релиза, выключить feature flag, scale up, block abuse, redirect traffic. Цель — остановить кровь, не лечить рану.
4. **Communicate**: status page, Slack-канал инцидента, обновление каждые 15–30 мин, нотификация key stakeholders.
5. **Root cause**: только после стабилизации; собирать логи, traces, metrics, hypothesis.
6. **Fix forward / patch**: код-фикс, hotfix-release, проверенный rollback-обратно если нужно.
7. **Post-incident review**: blameless retrospective в течение 5 рабочих дней.
8. **Prevention**: failing test для регрессии, alert на ранний сигнал, checklist update, обновление playbook.
9. **Knowledge capture**: запись в `case-studies/failures/YYYY-MM-DD-<short>.md`.

## Severity levels (предложение)

- **S1** — полный outage / data loss / security breach. Pager, всё бросаем.
- **S2** — серьёзная деградация для большой группы пользователей.
- **S3** — частичная деградация, есть workaround.
- **S4** — мелкий баг с impact, не блокирующий.

## Частые ошибки

- Прыгать в root cause до стабилизации.
- Не назначить incident commander — все ведут диагностику, никто не решает.
- Молчать в коммуникациях — стейкхолдеры начинают звонить и мешают.
- Делать blameful retrospective — следующий инцидент скрывают.
- Не закрывать prevention-таски после ретро — incident повторяется.

## Security risks

При security-инциденте — отдельный playbook: содержать вектор, ротировать credentials, оценить экспозицию данных, оповестить privacy/legal.

## Testing strategy

- Game days / chaos drills для проверки runbook-ов.
- Регрессионные тесты на каждый закрытый incident.
- Регулярный аудит pager-алертов на noise/silence.

## Edge cases

- Многокомпонентный инцидент (БД + CDN + третья сторона) — единый IC, разные tech-leads.
- Vendor outage — playbook по downgrade и коммуникациям клиентам.
- Ложные алерты — отдельный flow для tune'a без раскрутки инцидента.

## Источники

- [Google SRE Book — Managing Incidents](https://sre.google/sre-book/managing-incidents/) — проверено 2026-05-24.
- См. [Rollback](Rollback.md), [Observability](Observability.md), [Release flow](Release-flow.md), [case-studies/failures](../../case-studies/failures).
