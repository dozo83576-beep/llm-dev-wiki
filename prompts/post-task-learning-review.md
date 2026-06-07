---
title: "Prompt: post-task learning review"
category: "prompt"
updated: "2026-06-07"
status: "active"
tags: ["knowledge-capture", "agents", "learning-review"]
source_priority: "internal"
---

# Prompt: post-task learning review

## Role

Tech lead, решающий, должен ли опыт завершенной задачи попасть в wiki как reusable knowledge.

## Context

Задача завершена или достигнут значимый checkpoint. Нужно отделить подтвержденное знание от шума: сохранить только то, что поможет будущему агенту быстрее выбрать стек, избежать ошибки, проверить риск или повторить успешный прием.

Если задача была неудачной, review должен превратить неудачную задачу в lesson learned или failure case: зафиксировать симптом, неверное предположение, проверку, исправление и правило предотвращения.

## Inputs

- `{{task_summary}}` — что просили сделать и что реально сделано.
- `{{stack}}` — технологии, версии, runtime, deploy target.
- `{{commands_and_tests}}` — команды, проверки, failures, final status.
- `{{diff_summary}}` — какие файлы/модули изменены.
- `{{sources_used}}` — wiki docs, official docs, tickets, PRs.
- `{{user_feedback}}` — замечания пользователя или review.

## Steps

1. **Classify significance**: определить, был ли новый стек, риск, failure, reusable pattern, unusual trade-off или hard-won fix.
2. **Check evidence**: не фиксировать вывод без команд, diff, тестов, источников или явного user feedback.
3. **Route artifact**: выбрать `success`, `failure`, `lesson`, `pattern`, `checklist update`, `golden Q&A` или `no artifact needed`.
4. **Deduplicate**: найти существующие lessons/patterns/case studies и обновить их вместо создания дубля.
5. **Sanitize**: удалить секреты, PII, приватный код, customer payloads и коммерческие закрытые детали.
6. **Link back**: каждый новый artifact должен ссылаться на релевантные docs, checklists, playbooks или related cases.
7. **Verify retrieval**: если опыт важен для будущих запросов, добавить golden Q&A или retrieval synonyms.

## Output schema

```text
## Learning review

Decision: create artifact | update artifact | no artifact needed
Reason: ...
Evidence: commands/tests/sources/user feedback

## Artifact routing
- case-studies/successes/...: ...
- case-studies/failures/...: ...
- lessons-learned/...: ...
- patterns/...: ...
- checklists/...: ...
- docs/14-llm-indexing/golden-qa.yaml: ...

## No artifact rationale
Use only when the task produced no reusable knowledge.
```

## Refusal rules

- Не выдумывать success/failure без подтверждения.
- Не сохранять секреты, PII, приватный payload или закрытый код.
- Не создавать пустые artifacts ради формальности.
- Не считать отсутствие инцидента success case, если не было нового повторяемого приема.

## Related

- [Agent self-improvement loop](../docs/07-mcp-and-ai-tools/Agent-self-improvement.md)
- [post-project knowledge capture](post-project-knowledge-capture.md)
- [update wiki](update-wiki.md)
- [wiki maintenance checklist](../checklists/wiki-maintenance.md)
