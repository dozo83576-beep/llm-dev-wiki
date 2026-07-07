---
title: "Agent workflows"
category: "ai-tools"
updated: "2026-07-07"
status: "active"
tags: ["agents", "workflow"]
source_priority: "internal"
---

# Agent workflows

Хороший агентный workflow: уточнение цели, plan, retrieval по wiki, ограниченные инструменты, маленькие изменения, проверка, diff review, сохранение уроков.

Запрещенный паттерн: агент получает широкие права, меняет много файлов без проверки и не фиксирует причины решений.

Wiki работает как внешняя память агента. Она улучшает следующие решения через retrieval, checklists, golden Q&A и case studies, но не меняет веса модели.

## Когда использовать

Используй agent workflow для разработки, code review, debugging, RAG maintenance, research synthesis и post-project knowledge capture.

## Когда не использовать

Не используй автономного агента для production mutation, billing, DNS, secret rotation или destructive operations без явного подтверждения.

## Production-паттерны

Small scoped task, explicit plan, limited tools, diff review, verification commands, commit hygiene, post-task learning review после значимой задачи.

## Частые ошибки

Слишком широкий prompt, write tools без границ, отсутствие проверки, игнорирование user changes, нет записи success/failure, называть wiki-memory "самообучением модели".

## Проверка

Проверь plan, diff, test output, audit logs, отсутствие секретов и результат learning review: artifact создан/обновлен или есть причина `no artifact needed`.

## Источники

См. [Tool permissions](Tool-permissions.md), [Prompt injection](Prompt-injection.md), [Agent self-improvement loop](Agent-self-improvement.md), [Claude Code best practices](Claude-Code-best-practices.md), [AI agent review](../../checklists/ai-agent-review.md).
