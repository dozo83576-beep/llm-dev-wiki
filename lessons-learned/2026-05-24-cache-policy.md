---
title: "Урок: cache policy должна быть явной"
category: "lesson"
updated: "2026-05-24"
status: "active"
tags: ["cache", "nextjs", "data-fetching"]
source_priority: "internal"
date: "2026-05-24"
project_type: "SaaS"
---

# Вывод

Данные, которые пользователь может изменить, должны иметь явную cache/revalidate policy и проверенный refresh path.

# Контекст

Next.js production caching может отличаться от ожиданий в dev mode.

# Новое правило

Для каждого server fetch фиксировать, почему он cached, dynamic или revalidated.

# Обновленные документы

[Data fetching](../docs/02-frontend/Data-fetching.md), [cache assumption failure](../case-studies/failures/2026-05-24-nextjs-cache-assumption.md).
