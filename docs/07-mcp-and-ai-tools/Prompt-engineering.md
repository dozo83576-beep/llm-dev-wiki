---
title: "Prompt engineering"
category: "ai-tools"
updated: "2026-05-24"
status: "active"
tags: ["prompting", "agents"]
source_priority: "internal"
---

# Prompt engineering

Промпт должен задавать роль, цель, входные данные, ограничения, формат результата, критерии приемки, требования к проверке и порядок действий.

Для программирования добавляй: стек, версии, окружение, архитектура перед кодом, тесты, безопасность, edge cases, запрет незавершенных маркеров.

## Когда использовать

Используй prompt engineering для повторяемых AI-задач: code review, implementation planning, debugging, RAG answers, extraction, agent workflows.

## Когда не использовать

Не пытайся prompt-ом исправить отсутствие данных, плохие tools, слабую архитектуру или отсутствие evals.

## Production-паттерны

Явные role, goal, context, constraints, output format, acceptance criteria, tool policy, security policy и verification requirements.

## Частые ошибки

Слишком широкий prompt, нет критериев приемки, нет запрета секретов, нет указания источников, нет проверки результата.

## Проверка

Prompt evals, regression examples, adversarial cases, review output against acceptance criteria.

## Источники

См. [Evaluation](Evaluation.md), [Prompt injection](Prompt-injection.md), [create project prompt](../../prompts/create-new-project.md).

