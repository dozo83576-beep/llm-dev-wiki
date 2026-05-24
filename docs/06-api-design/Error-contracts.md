---
title: "API error contracts"
category: "api"
updated: "2026-05-24"
status: "active"
tags: ["errors", "contract"]
source_priority: "internal"
---

# API error contracts

Единый контракт ошибок упрощает frontend, поддержку и observability.

Рекомендуемая форма: `code`, `message`, `details`, `correlationId`. Не возвращай stack trace, SQL, секреты или внутренние enum без необходимости.

