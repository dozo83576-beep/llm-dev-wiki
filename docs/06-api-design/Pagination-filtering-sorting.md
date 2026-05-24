---
title: "Pagination, filtering, sorting"
category: "api"
updated: "2026-05-24"
status: "active"
tags: ["pagination", "filtering", "sorting"]
source_priority: "internal"
---

# Pagination, filtering, sorting

Для маленьких списков можно offset pagination. Для больших и live-changing списков используй cursor pagination.

Фильтры и сортировки должны иметь allowlist полей, иначе появляются security и performance риски.

