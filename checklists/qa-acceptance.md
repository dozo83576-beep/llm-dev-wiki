---
title: "QA / UAT acceptance checklist"
category: "checklist"
updated: "2026-06-19"
status: "active"
tags: ["qa", "uat", "acceptance", "sign-off", "release-gate"]
source_priority: "internal"
---

# QA / UAT acceptance checklist

Приёмочный gate перед релизом. Срабатывает в фазе ревью (`site-review`) после прохождения профильных
review-чеклистов и до [release-readiness](release-readiness.md). Доказывает, что сайт делает то, что
зафиксировано в discovery, и что заказчик это принял. Формат: критерий — проверка — owner — severity.

## Маппинг на acceptance criteria

- [ ] **Каждый acceptance criterion из discovery** имеет проверку и статус (pass/fail) — QA — block — [project-discovery](project-discovery.md).
- [ ] **Ключевые user journeys** пройдены вручную end-to-end (например: заявка, покупка, регистрация) — QA — block.
- [ ] **Нет тестовых данных, заглушек, debug-элементов** в продакшен-сборке — QA — block.

## Функциональный smoke

- [ ] **Формы**: happy / error / spam path, письма/заявки доходят в согласованный канал — QA — block — [Forms validation](../docs/02-frontend/Forms-validation.md).
- [ ] **Навигация и ссылки** работают, нет битых внутренних ссылок и 404 на ключевых страницах — QA — block.
- [ ] **Платёж / интеграции** (если есть) проверены в тестовом режиме — QA — block.

## Cross-browser / device

- [ ] **Десктоп**: Chrome, Safari, Firefox — основные страницы и формы — QA — warn.
- [ ] **Мобильный**: mobile Safari + Android Chrome, основной сценарий — QA — block.
- [ ] **Адаптив**: нет горизонтального скролла и обрезанного контента на 360px — QA — warn.

## Defect triage

- [ ] **Дефекты классифицированы** по severity: blocker / major / minor / cosmetic — QA — block.
- [ ] **Blocker и major закрыты** или явно отложены с письменным согласием заказчика — product owner — block.
- [ ] **Minor / cosmetic** занесены в backlog с приоритетом — product owner — warn.

## Client sign-off

- [ ] **Заказчик прошёл UAT** по согласованному списку сценариев — product owner — block.
- [ ] **Письменное подтверждение приёмки** получено (дата, кто принял, где) — project owner — block.
- [ ] **Граница «баг vs новая задача»** проговорена: правки по ТЗ — в релиз, новое — отдельная оценка — project owner — warn.

## Регрессия

- [ ] **Регрессионный объём** определён для изменённых областей; повторный smoke после фиксов — QA — warn — [E2E testing](../docs/09-testing/E2E-testing.md).

## Stop conditions

Любой `block` не выполнен → релиз и передача откладываются. Передача клиенту ([handoff template](../docs/10-templates/handoff.md)) начинается только после client sign-off.

## Источники

- [project-discovery](project-discovery.md)
- [release-readiness](release-readiness.md)
- [handoff template](../docs/10-templates/handoff.md)
- [E2E testing](../docs/09-testing/E2E-testing.md)
