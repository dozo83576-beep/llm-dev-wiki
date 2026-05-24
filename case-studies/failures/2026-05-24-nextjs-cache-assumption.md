---
title: "Ошибка: неявное предположение о cache в Next.js"
project_type: "SaaS"
stack: ["Next.js"]
severity: "high"
date: "2026-05-24"
tags: ["nextjs", "cache", "data-fetching"]
---

# Что пошло не так

Страница показывала устаревшие данные после mutation, потому что cache/revalidate policy не была явно задана.

# Причина

Команда считала локальное поведение dev-сервера эквивалентным production caching.

# Как проявилось

После обновления настройки пользователь видел старое значение до refresh или revalidation.

# Как исправили

Определили cache policy для server fetch, добавили invalidation после mutation и E2E-сценарий обновления.

# Как не повторять

- Для каждого server fetch фиксировать cache/revalidate policy.
- После mutation проверять UI refresh path.
- Не переносить production caching assumptions из dev mode.

# Анти-паттерн

Не оставляй cache behavior неявным для данных, которые пользователь только что изменил.

# Связанные чеклисты

[Data fetching](../../docs/02-frontend/Data-fetching.md), [Frontend review](../../checklists/frontend-review.md).

