---
name: site-review
description: Review-фаза только внутри полного маршрута D:\Work или при явном вызове; не подменяет нативное ревью любой кодовой задачи.
---

# Site review

Проверь фактический diff и поведение против discovery, architecture, content, design и acceptance gates. Приоритет — дефекты, безопасность и регрессии, а не пересказ реализации.

Используй свежие build/test/browser evidence. Отдельно проверь server validation, authz, секреты, ПДн/152-ФЗ, legal/consent, accessibility, critical flows и rollback readiness — только там, где это применимо.

Для motion/media проверь poster до первого кадра, pause с клавиатуры, reduced-motion/save-data,
mobile crop, отсутствие layout shift/audio в decorative loop и фактический page-weight/CWV.

Если внешний факт не проверен, пометь его непроверенным и укажи нужный инструмент. Отсутствие необязательного helper не является блокером.

В `_review-report.md` запиши находки по приоритету с местом и доказательством, выполненные проверки и остаточный риск. Gate проходит после устранения блокирующих находок или явного принятия риска владельцем.
