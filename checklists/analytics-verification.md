---
title: "Analytics verification checklist"
category: "checklist"
updated: "2026-06-19"
status: "active"
tags: ["analytics", "tracking", "consent", "launch"]
source_priority: "internal"
---

# Analytics verification checklist

Gate проверки аналитики перед передачей клиенту. Доказывает, что события реально приходят, согласие
уважается, а воронка считается. Срабатывает в фазе SEO/ревью. Формат: критерий — проверка — owner — severity.

## Подключение

- [ ] **Счётчик активен** на всех публичных страницах (page view приходит) — frontend — block — [Analytics](../docs/02-frontend/Analytics.md).
- [ ] **Прод и dev разделены**: dev-трафик не льётся в продакшен-проект аналитики — devops — block.
- [ ] **ID/ключи** в env, не захардкожены в бандл — devops — block.

## События и воронка

- [ ] **Ключевые события** определены и срабатывают: CTA click, form submit, покупка/заявка — product owner — block.
- [ ] **Воронка** собирается из событий и видна в дашборде — product owner — warn.
- [ ] **Нет дублей** событий (один submit = одно событие) — frontend — warn.

## Согласие (consent)

- [ ] **Не-essential аналитика** грузится только после согласия (см. [Privacy and consent](../docs/05-auth-security/Privacy-policy-and-consent.md)) — frontend — block.
- [ ] **Отказ** реально отключает трекинг — frontend — block.

## Производительность

- [ ] **Скрипты аналитики** не блокируют первый рендер (async/defer, ниже критичного пути) — frontend — warn — [Performance](../docs/02-frontend/Performance.md).

## Stop conditions

Любой `block` не выполнен → аналитику нельзя считать готовой к передаче. Зафиксировать ссылку на дашборд в `handoff.md`.

## Источники

- [Analytics](../docs/02-frontend/Analytics.md)
- [Privacy and consent](../docs/05-auth-security/Privacy-policy-and-consent.md)
- [Performance](../docs/02-frontend/Performance.md)
