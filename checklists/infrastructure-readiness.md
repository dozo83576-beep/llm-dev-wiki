---
title: "Infrastructure readiness checklist"
category: "checklist"
updated: "2026-06-19"
status: "active"
tags: ["dns", "ssl", "domain", "cdn", "deploy", "release-gate"]
source_priority: "internal"
---

# Infrastructure readiness checklist

Gate инфраструктуры перед production-релизом: домен, DNS, SSL, CDN. Срабатывает в фазе деплоя до
переключения трафика на production-домен. Формат: критерий — проверка — owner — severity.

## Домен и DNS

- [ ] **Домен** зарегистрирован/делегирован, владелец — заказчик или согласованный аккаунт — project owner — block.
- [ ] **DNS-записи** настроены (A/AAAA/CNAME) и распространились (propagation проверена) — devops — block.
- [ ] **www и apex** ведут на один канонический хост (редирект на выбранный) — devops — warn.
- [ ] **Почтовые записи** (MX/SPF/DKIM/DMARC) не сломаны изменением DNS, если домен используется для почты — devops — block.

## SSL / HTTPS

- [ ] **SSL-сертификат** выпущен и валиден для всех хостов; авто-обновление включено — devops — block.
- [ ] **HTTPS принудительный**: HTTP → HTTPS редирект, нет mixed content — devops — block.
- [ ] **HSTS** включён (после проверки, что весь трафик готов к HTTPS) — devops — warn.

## CDN / кэш

- [ ] **CDN/edge-кэш** настроен с long cache на статику и revalidate on deploy — devops — warn — [Vercel](../docs/08-devops-deploy/Vercel.md).
- [ ] **Кэш не кэширует** приватные/персонализированные ответы — devops — block.

## Окружение

- [ ] **Env vars и секреты** на проде заданы и совпадают с `.env.example` — devops — block — [Environment variables](../docs/08-devops-deploy/Environment-variables.md).

## Stop conditions

Любой `block` не выполнен → переключение на production-домен откладывается. Доступы к домену/DNS фиксируются в `handoff.md` (без секретов).

## Источники

- [Vercel](../docs/08-devops-deploy/Vercel.md)
- [Environment variables](../docs/08-devops-deploy/Environment-variables.md)
- [handoff template](../docs/10-templates/handoff.md)
