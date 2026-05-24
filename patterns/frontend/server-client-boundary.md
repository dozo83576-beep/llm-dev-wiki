---
title: "Pattern: Server/client boundary"
category: "patterns"
updated: "2026-05-24"
status: "active"
tags: ["nextjs", "react"]
source_priority: "internal"
---

# Server/client boundary

В Next.js держи страницу серверной по умолчанию. Клиентскими делай только компоненты, которым нужны events, local state, browser API или imperative UI.

Проверка: если `"use client"` стоит в верхнем layout/page без причины, архитектуру нужно пересмотреть.
