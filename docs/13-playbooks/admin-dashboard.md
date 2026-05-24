---
title: "Playbook: Admin dashboard"
category: "playbooks"
updated: "2026-05-24"
status: "active"
tags: ["admin", "dashboard", "rbac"]
source_priority: "internal"
---

# Playbook: Admin dashboard

## Стек по умолчанию

Next.js/React + typed API + RBAC + audit log + tables/forms/charts + Playwright smoke.

## Порядок разработки

1. Define roles and permissions.
2. Identify high-risk actions: delete, export, refund, role change.
3. Build dense navigation and searchable tables.
4. Add confirmations for destructive actions.
5. Add audit log for admin actions.
6. Test permission denied, object-level access and export limits.

## Анти-паттерны

- Красивый dashboard без операторской эффективности.
- Нет audit trail.
- Одинаковый UI для safe action и destructive action.

