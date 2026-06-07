---
title: "Agent self-improvement loop"
category: "ai-tools"
updated: "2026-06-07"
status: "active"
tags: ["agents", "learning", "knowledge-capture"]
source_priority: "internal"
---

# Agent self-improvement loop

Agent self-improvement в этой wiki означает улучшение решений через внешнюю память: wiki retrieval, checklists, evals, case studies и lessons learned. Это не меняет веса модели и не заменяет fine-tuning.

Перед началом задачи агент должен использовать wiki как первый инженерный источник: найти релевантные playbooks, stack docs, patterns, failures и checklists, а затем сверять свежие факты с официальной документацией.

## Когда использовать

Используй loop после значимой задачи: новый стек, нестандартная архитектура, инцидент, провал проверки, удачный reusable pattern, новая интеграция, security-sensitive изменение.

## Когда не использовать

Не создавай wiki artifact после мелкого terminal/debug шага, если не появилось повторяемого знания. Не сохраняй временные гипотезы, неподтвержденные выводы или опыт, который нельзя проверить командами, diff, тестами, источниками или user feedback.

## Production-паттерны

1. **Intent classification**: определить тип задачи: сайт, backend, security, AI/RAG, deploy, maintenance.
2. **Wiki retrieval first**: прочитать релевантные docs, playbooks, patterns, checklists, failures.
3. **Official docs fallback**: для latest versions, security, API changes, licenses, pricing и platform behavior сверяться с официальными источниками.
4. **Execution with evidence**: фиксировать команды, тесты, diff summary, failures и причины решений.
5. **Post-task learning review**: решить, нужен ли artifact: success, failure, lesson, pattern, checklist update, golden Q&A.
6. **Retrieval reinforcement**: добавить links, synonyms или golden question, если будущий агент должен находить новый опыт по пользовательскому запросу.

## Routing

- `case-studies/successes/` — решение с доказанным результатом, которое стоит повторять.
- `case-studies/failures/` — ошибка, регрессия, плохое предположение или incident с правилом предотвращения.
- `lessons-learned/` — короткое правило, применимое шире одного проекта.
- `patterns/` — повторяемый технический прием с границами применимости.
- `checklists/` — новый block/warn gate для review.
- `docs/14-llm-indexing/golden-qa.yaml` — вопрос, по которому будущий агент обязан находить нужный документ.

## Частые ошибки

Называть это самообучением модели, сохранять всё подряд, писать lesson без доказательства, плодить дубликаты existing patterns, не добавлять cross-links, не обновлять golden Q&A после нового важного сценария.

## Security/privacy risks

В wiki нельзя сохранять секреты, токены, cookies, private keys, PII, customer payloads, закрытый код и коммерческие данные. Для case studies используй anonymized summaries и ссылки только на безопасные внутренние документы.

## Проверка

Перед завершением значимой задачи запусти [post-task learning review](../../prompts/post-task-learning-review.md). После изменения wiki запускай `pwsh tools/ci-local.ps1 -IncludeToolTests`; если менялся corpus, commit должен включать актуальные `docs/INDEX.md` и `embeddings/manifest.json`.

## Источники

- См. [Agent memory](Agent-memory.md), [Agent workflows](Agent-workflows.md), [AI evaluation](Evaluation.md), [post-project knowledge capture](../../prompts/post-project-knowledge-capture.md), [wiki maintenance checklist](../../checklists/wiki-maintenance.md).
