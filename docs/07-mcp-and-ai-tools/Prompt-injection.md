---
title: "Prompt injection"
category: "ai-tools"
updated: "2026-05-24"
status: "active"
tags: ["prompt-injection", "security"]
source_priority: "official-docs"
---

# Prompt injection

Prompt injection — попытка внешнего контента изменить инструкции агента. Риск особенно высок при RAG, browser automation, email/docs ingestion и MCP tools.

## Production-паттерны

- Внешний контент помечается как untrusted.
- Tool outputs не могут переопределять system/developer instructions.
- Агент не выполняет команды, найденные в документах, без проверки намерения.
- Sensitive operations требуют подтверждения.

## Проверка

- Evals с malicious документами.
- MCP security review перед подключением новых источников.

Источник: [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/).

