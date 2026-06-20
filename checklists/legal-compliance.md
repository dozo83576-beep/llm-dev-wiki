---
title: "Legal compliance checklist (RU / 152-FZ)"
category: "checklist"
updated: "2026-06-19"
status: "active"
tags: ["legal", "152-fz", "privacy", "compliance", "release-gate"]
source_priority: "internal"
---

# Legal compliance checklist (RU / 152-ФЗ)

Pre-launch юридический gate для сайтов с РФ-аудиторией и обработкой персональных данных. Срабатывает в
фазе ревью и перед релизом. Не юр-заключение — спорное подтверждает юрист. Формат: критерий — проверка — owner — severity.

## Персональные данные (152-ФЗ)

- [ ] **Политика конфиденциальности** опубликована и проверена человеком/юристом (не ИИ-текст «как есть») — project owner — block — [RU 152-FZ and AI data handling](../docs/05-auth-security/RU-152fz-and-ai-data-handling.md).
- [ ] **Согласие на обработку ПДн** перед отправкой форм; чекбокс явный, не предотмеченный — frontend — block — [Privacy-policy-and-consent](../docs/05-auth-security/Privacy-policy-and-consent.md).
- [ ] **Минимизация**: формы не собирают ПДн сверх необходимого для задачи — product owner — warn.
- [ ] **Локализация ПДн** граждан РФ (хранение/обработка на серверах в РФ) определена; уведомление Роскомнадзора — проверено у юриста — project owner — block.

## Cookie и трекинг

- [ ] **Cookie-consent**: не-essential cookies/аналитика грузятся только после согласия — frontend — block — [Privacy-policy-and-consent](../docs/05-auth-security/Privacy-policy-and-consent.md).
- [ ] **Сторонние скрипты**, отправляющие данные за рубеж, проверены и раскрыты в политике — devops — warn.

## ИИ-контент и тексты

- [ ] **ИИ-сгенерированные юр-тексты** (политика, оферта, согласия) проверены человеком/юристом — project owner — block.
- [ ] **Фактические утверждения** на сайте (законы, цифры, гарантии) проверены, нет выдуманных ИИ норм — product owner — block.

## Данные заказчика при сборке

- [ ] **Реальные PII/секреты/договоры заказчика** не отправлялись в облачные ИИ; чувствительное обезличено — tech lead — block — [RU 152-FZ and AI data handling](../docs/05-auth-security/RU-152fz-and-ai-data-handling.md).

## Stop conditions

Любой `block` не выполнен → релиз и передача клиенту откладываются. Точные требования законодательства подтверждает юрист, агент их не выдумывает.

## Источники

- [RU 152-FZ and AI data handling](../docs/05-auth-security/RU-152fz-and-ai-data-handling.md)
- [Privacy-policy-and-consent](../docs/05-auth-security/Privacy-policy-and-consent.md)
- [Compliance baseline](../docs/05-auth-security/Compliance-baseline.md)
