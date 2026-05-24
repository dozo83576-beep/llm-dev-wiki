---
title: "API versioning"
category: "api"
updated: "2026-05-24"
status: "active"
tags: ["versioning", "api"]
source_priority: "internal"
---

# API versioning

Версионируй публичные API. Для внутренних API предпочтительнее backward-compatible изменения и contract tests.

Правила: не ломай поля без deprecation window, добавления должны быть совместимыми, breaking changes документируются и тестируются.

