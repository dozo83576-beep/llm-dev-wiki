---
title: "Agent workflows"
category: "ai-tools"
updated: "2026-05-24"
status: "active"
tags: ["agents", "workflow"]
source_priority: "internal"
---

# Agent workflows

Хороший агентный workflow: уточнение цели, план, ограниченные инструменты, маленькие изменения, проверка, diff review, сохранение уроков.

Запрещенный паттерн: агент получает широкие права, меняет много файлов без проверки и не фиксирует причины решений.

## Когда использовать

Используй agent workflow для разработки, code review, debugging, RAG maintenance, research synthesis и post-project knowledge capture.

## Когда не использовать

Не используй автономного агента для production mutation, billing, DNS, secret rotation или destructive operations без явного подтверждения.

## Production-паттерны

Small scoped task, explicit plan, limited tools, diff review, verification commands, commit hygiene, knowledge capture после завершения.

## Частые ошибки

Слишком широкий prompt, write tools без границ, отсутствие проверки, игнорирование user changes, нет записи success/failure.

## Проверка

Проверь plan, diff, test output, audit logs, отсутствие секретов и обновление relevant wiki knowledge.

## Источники

См. [Tool permissions](Tool-permissions.md), [Prompt injection](Prompt-injection.md), [AI agent review](../../checklists/ai-agent-review.md).

