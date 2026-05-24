---
title: "Урок: cache policy должна быть явной"
date: "2026-05-24"
project_type: "SaaS"
tags: ["cache", "nextjs", "data-fetching"]
---

# Вывод

Данные, которые пользователь может изменить, должны иметь явную cache/revalidate policy и проверенный refresh path.

# Контекст

Next.js production caching может отличаться от ожиданий в dev mode.

# Новое правило

Для каждого server fetch фиксировать, почему он cached, dynamic или revalidated.

# Обновленные документы

[Data fetching](../docs/02-frontend/Data-fetching.md), [cache assumption failure](../case-studies/failures/2026-05-24-nextjs-cache-assumption.md).

