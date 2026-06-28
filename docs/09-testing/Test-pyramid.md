---
title: "Test pyramid"
category: "testing"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["test-strategy", "testing"]
source_priority: "internal"
---

# Test pyramid

Test pyramid — это распределение тестов по слоям так, чтобы быстрых, дешёвых, детерминированных тестов было много, а медленных и хрупких — мало. Цель — быстрый feedback и устойчивая suite.

## Когда использовать

- Любой production-проект, начиная с MVP.
- При планировании test-стратегии новой фичи.
- При диагностике "почему CI стал медленным и flaky".

## Когда не использовать

- Pet-проект без планов на поддержку — достаточно happy-path смоук.
- Pure UX-эксперимент с горизонтом 1–2 недели.

## Слои (снизу вверх)

- **Unit**: чистая логика, validators, mappers, reducers, permission rules, pricing — миллисекунды, изолированы. Их много (60–70%).
- **Integration**: API + DB + external adapter с реальной БД и mock'нутыми внешними. Секунды на тест, ~20–30%.
- **Contract**: границы между producer и consumer (OpenAPI / Pact). Перед deploy.
- **E2E**: критичные user-journey через реальный браузер. Минимум, 5–10%.
- **Smoke**: < 5 мин, прогон после deploy. Подмножество E2E.

## Production-паттерны

- Покрывать unit'ами всё, что можно — самый дешёвый канал отлова регрессий.
- Integration вокруг каждой важной БД-операции (создать, обновить, найти с фильтром, удалить с permissions).
- E2E ровно столько, чтобы покрыть money-paths и compliance-flow.
- Coverage не как самоцель, а как инструмент: 80%+ для критичной логики, остальное — по риску.
- Контрактные тесты обязательны для каждого внешнего API-потребителя.

## Анти-паттерны

- **Ice-cream cone** (перевёрнутая пирамида): много E2E, мало unit — медленно, flaky, дорого.
- **Hourglass**: много unit и E2E, мало integration — слой DB / адаптеров не покрыт, регрессии прямо в продакшен.
- **Testing through UI** того, что можно проверить unit'ом.
- Дублирование тестов на разных уровнях без добавочной ценности.

## Частые ошибки

- Замерять только числа тестов, не время и flaky-rate.
- Считать coverage 100% самоцелью — пишутся пустые тесты ради числа.
- Не удалять старые тесты при удалении фичи.
- E2E на минорный UI-вариант, который мог быть component-тестом.

## Security testing в пирамиде

- Auth/authz unit-тесты — обязательно.
- Integration на permission boundary — обязательно.
- E2E smoke на login/logout/signup.
- Security scan / DAST — отдельный track (см. [Security testing](Security-testing.md)).

## Testing strategy

- Pyramid health metrics: число тестов по уровням, время прогона, flaky-rate.
- Quarterly retro: какие тесты приносят сигнал, какие — шум.
- Один failing test блокирует merge, не "перезапусти".

## Edge cases

- Микросервисы: пирамида у каждого сервиса + контрактные тесты между.
- Frontend monorepo: компонент-тесты как доп. уровень между unit и E2E.
- Mobile / native: emulator-based, отдельная стратегия по нагрузке на CI.

## Источники

- [Testing Pyramid (Martin Fowler)](https://martinfowler.com/articles/practical-test-pyramid.html) — проверено 2026-05-24.
- См. [Unit testing](Unit-testing.md), [Integration testing](Integration-testing.md), [E2E testing](E2E-testing.md), [Contract testing](Contract-testing.md).
