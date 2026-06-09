---
title: "Webflow"
category: "frontend"
updated: "2026-06-10"
status: "active"
tags: ["webflow", "visual-builder", "cms", "marketing"]
source_priority: "official-docs"
---

# Webflow

Webflow — visual builder/CMS/developer platform для marketing sites, брендовых страниц и команд, где скорость визуального редактирования важнее code ownership.

## Когда использовать

- Marketing/design team должна сама менять страницы, CMS entries and layout.
- Нужен быстрый брендовый сайт, campaign pages, landing pages or resource hub.
- Product logic минимальна, integrations идут через forms, embeds, APIs or light custom code.
- Важны visual workflow, hosted CMS and designer-owned iteration.

## Когда не использовать

- Custom SaaS, complex auth, RBAC, transactional flows, checkout logic or internal dashboards.
- Требуется strict code review для каждого UI/content change.
- Нужны сложные backend workflows, typed contracts and monorepo CI.
- Vendor lock-in неприемлем.

## Production-паттерны

- Разделяй Webflow marketing site и product app boundary.
- CMS collections проектируй как content model with slugs, SEO fields, images and redirects.
- Custom code минимизируй и документируй: analytics, forms, consent, embeds.
- Integrations проходят security/privacy review, особенно forms and scripts.
- Export/API sync не должен становиться скрытым backend.

## Частые ошибки

- Строить business-critical app как набор visual pages.
- Добавлять third-party scripts без performance/privacy review.
- Нет redirect/SEO governance после быстрых правок.
- CMS collection превращается в неструктурированный page builder без ownership.

## Проверка

Проверь SEO metadata, redirects, forms, analytics consent, accessibility, mobile layouts, third-party scripts and `pwsh tools/site-audit.ps1 -Url <url>`.

## Источники

- [Webflow Developer Platform](https://developers.webflow.com/)
- [Webflow CMS API](https://developers.webflow.com/data/reference)
- См. [CMS content](CMS-content.md), [Landing playbook](../13-playbooks/landing.md), [Site audit tooling](../09-testing/Site-audit-tooling.md).
