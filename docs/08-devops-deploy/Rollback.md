---
title: "Rollback"
category: "devops"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["rollback", "incident", "deploy"]
source_priority: "internal"
---

# Rollback

Rollback план должен существовать до релиза, а не во время инцидента. Код откатить относительно легко; данные — почти всегда нет. Поэтому изменения проектируются так, чтобы можно было откатить именно код.

## Когда использовать

- Релиз вызвал measurable деградацию (error rate, latency, бизнес-метрика).
- Обнаружена security regression или data corruption.
- Feature flag не помогает (нельзя выключить через config).

## Когда не использовать

- Случайный спайк ошибок от vendor — сначала диагностика, потом решение.
- Минимальный косметический баг — fix forward быстрее.
- Изменения данных уже применены и не backward-compatible — только fix forward.

## Production-паттерны

- **Backward-compatible миграции** (expand → migrate → contract): на старте контрактуется минимум, фактическое удаление колонки — отдельный релиз через несколько дней.
- **Feature flags** для рискованных функций: rollback = flip flag, не deploy.
- **Раздельный deploy кода и data migration** при опасных изменениях.
- **Runbook на конкретный сервис**: команды отката, владелец решения, expected duration, indicators "что стало лучше".
- **Immutable releases** с явным release id (git SHA) и быстрым switch обратно.
- **Canary / blue-green** — rollback = переключение трафика, секунды.

## Частые ошибки

- "Откатим миграцию" без проверки, что она reversible.
- Rollback без отключения уже отправленных webhooks / emails — состояние мира не откатить.
- Не задокументирован owner решения — команда спорит вместо действий.
- Считать, что rollback всегда возможен — backward-incompatible миграции уничтожают эту опцию.

## Security risks

Rollback может вернуть критическую CVE-версию или скомпрометированный код — нужно учитывать в decision. Откат security-фикса = ре-open уязвимости.

## Testing strategy

- **Smoke rollback на staging** перед каждым крупным релизом.
- **Game days** — реальный rollback на проде в обычное окно, не в инциденте.
- **Test reversible migrations** в CI: применить → откатить → применить.

## Когда откатывать (decision tree)

1. Inсident severity ≥ S2 и причина — недавний релиз? → rollback кандидат.
2. Rollback не вызовет data loss? → проверить миграции.
3. Rollback быстрее, чем fix forward? → откатывать.
4. Иначе — fix forward с явным communication.

## Edge cases

- Долгая миграция уже применена частично — нужен resume / replay.
- Webhook'и / events с side effects уже доставлены — нужны компенсирующие действия.
- Конфликт между rollback и горячими секретами (rotated keys).

## Knowledge capture

После каждого реального rollback — запись в [case-studies/failures](../../case-studies/failures) с симптомами, причиной, тем как обнаружили и решением.

## Источники

- [Google SRE — Postmortem culture](https://sre.google/sre-book/postmortem-culture/) — проверено 2026-05-24.
- См. [Release flow](Release-flow.md), [Incident workflow](Incident-workflow.md), [Migrations](../04-databases/Migrations.md), [expand-contract-migration pattern](../../patterns/database/expand-contract-migration.md).
