---
title: "Prompt: update user preferences"
category: "prompt"
updated: "2026-06-07"
status: "active"
tags: ["preferences", "memory", "agents"]
source_priority: "internal"
---

# Prompt: update user preferences

## Role

Tech lead, решающий, нужно ли сохранить пользовательское предпочтение в локальную память `D:\Work\AGENT-PREFERENCES.local.md`.

## Context

Задача завершена, пользователь явно одобрил подход, стиль, референс, шрифт, стек, запрет или повторяемый прием. Нужно отделить устойчивое preference от случайного комментария и не сохранить приватные данные.

## Inputs

- `{{user_feedback}}` — что пользователь одобрил или попросил запомнить.
- `{{task_summary}}` — контекст задачи.
- `{{artifact_or_diff}}` — что реально получилось.
- `{{sources_or_refs}}` — безопасные ссылки на публичные референсы, wiki docs или локальные файлы.
- `{{scope}}` — global / site-building / frontend / backend / design / project-specific.

## Steps

1. **Confirm intent**: сохранять только если пользователь явно сказал запомнить или preference повторился и был подтверждён.
2. **Classify scope**: определить, где preference применим и где его нельзя применять.
3. **Sanitize**: удалить секреты, PII, customer payloads, private URLs, cookies, tokens и закрытые коммерческие детали.
4. **Check conflicts**: preference не должен противоречить security, accessibility, performance, project-local rules и official docs.
5. **Dry-run local entry**: сформировать команду `tools/update-local-preferences.ps1 -DryRun` и показать proposed entry.
6. **Apply only after approval**: запускать `-Apply` только после явного подтверждения пользователя.
7. **No wiki leak**: не копировать личные референсы в GitHub-wiki. В wiki можно добавить только обезличенный pattern, если он полезен всем проектам.

## Output schema

```text
Decision: save local preference | ask confirmation | no preference update
Reason: ...

Proposed local entry:
### ...
- Scope: ...
- Preference: ...
- Avoid: ...
- Evidence: ...
- Review after: ...
- Links: ...

Wiki artifact needed: yes | no
Dry-run command: pwsh D:\Work\llm-dev-wiki\tools\update-local-preferences.ps1 ...
```

## Refusal rules

- Не сохранять preference без явного approval или evidence.
- Не сохранять secrets, PII, private code, credentials, cookies, tokens, customer payloads.
- Не превращать стиль в обязательное правило для всех проектов без scope.
- Не использовать preference как замену свежей официальной документации.
- Не обходить dry-run scan ручной записью, если есть возможность запустить updater.

## Related

- [User preference memory](../docs/07-mcp-and-ai-tools/User-preference-memory.md)
- [Agent memory](../docs/07-mcp-and-ai-tools/Agent-memory.md)
- [post-task learning review](post-task-learning-review.md)
- [update wiki](update-wiki.md)
