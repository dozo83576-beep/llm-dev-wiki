---
title: "AI evaluation"
category: "ai-tools"
updated: "2026-05-24"
status: "active"
tags: ["evals", "quality"]
source_priority: "official-docs"
---

# AI evaluation

AI-функции проверяются evals: набор вопросов, ожидаемые свойства ответа, источники, запрет hallucinations, security probes, tool-use checks.

Источник: [OpenAI Evals](https://github.com/openai/evals).

## Когда использовать

Используй evals для RAG, agents, prompt changes, tool-use workflows, classifiers, extraction и любых AI-функций, влияющих на пользователя.

## Когда не использовать

Не делай вид, что 3 ручных вопроса заменяют eval suite. Для одноразовой исследовательской задачи достаточно ручной проверки, но не для production.

## Production-паттерны

Golden set, regression questions, adversarial prompts, source citation checks, refusal checks, tool permission checks и cost/latency budgets.

## Частые ошибки

Оценивать только happy path, не фиксировать expected behavior, менять prompt без baseline, не проверять prompt injection.

## Проверка

Evals запускаются до prompt/model/tool changes, failures triaged, важные failures превращаются в case studies или checklist updates, gate в CI на минимальный pass-rate.

## Edge cases

- Stochastic outputs — нужно несколько прогонов и агрегация (не один-в-один сравнение).
- LLM-as-judge: судья сам подвержен bias и promt-injection — калибровать на reference set.
- Cost: full eval suite дорогой → разделение на smoke (every PR) и full (release / nightly).
- Drift: модель/prompt меняются под капотом провайдера — periodic re-baseline.
- Тесты на refusal: задавать запросы вне домена, ожидать вежливый отказ + объяснение.

## Security risks

Adversarial prompt injection в самом eval suite не проверяет реальный prompt injection в проде, если суит не обновляется; утечка eval-данных в logs провайдера.

## Источники

- [OpenAI Evals](https://github.com/openai/evals) — проверено 2026-05-24.
- См. [RAG](RAG.md), [Prompt injection](Prompt-injection.md), [Agent workflows](Agent-workflows.md), [golden-qa.yaml](../14-llm-indexing/golden-qa.yaml).

