---
title: "Prompt: post-project knowledge capture"
category: "prompt"
updated: "2026-05-24"
status: "active"
tags: ["knowledge-capture", "retro", "lessons"]
source_priority: "internal"
---

# Prompt: post-project knowledge capture

## Role

Tech lead, превращающий завершённый проект (или большой этап) в воспроизводимое знание для будущих проектов.

## Context

Без явной фиксации опыт растворяется. Что делать с опытом после завершения проекта: выполнить knowledge capture и оставить хотя бы один артефакт — success / failure / lesson / pattern / checklist update. Это требование зафиксировано в [AGENTS.md](../AGENTS.md).

## Inputs

- `{{project_name}}` — slug проекта.
- `{{date}}` — YYYY-MM-DD.
- `{{outcome}}` — что произошло (launch / pivot / incident / shipped on time).
- `{{stack}}` — стек.
- `{{diff_summary}}` — ключевые PR / решения.
- `{{incidents}}` — список инцидентов.
- `{{retro_notes}}` — заметки с retrospective.

## Steps

1. **Inventory artifacts**: на основе входных данных определить, какие записи нужны после завершения проекта.
2. **Success cases**: решения, которые стоит повторять (используем `case-studies/_template-success.md`).
3. **Failure cases**: ошибки и их корни (используем `case-studies/_template-failure.md`).
4. **Lessons learned**: короткие правила-в-одно-предложение (используем `lessons-learned/_template.md`).
5. **Patterns**: повторяющийся приём (используем `patterns/_template.md`).
6. **Checklist updates**: новые `block`/`warn` пункты в существующие checklists.
7. **Experience routing**: опыт проекта направить в success/failure/lesson/pattern, а не оставлять только в чате.
8. **Playbook updates**: если опыт ломает текущий playbook — поправить.
9. **Cross-links**: убедиться, что каждый артефакт ссылается на другие связанные.
10. **Anonymize**: удалить PII, секреты, customer-specific identifiers.

## Output schema

```
## Created / updated artifacts

### case-studies/successes/2026-MM-DD-<slug>.md
... summary ...

### case-studies/failures/2026-MM-DD-<slug>.md
... summary ...

### lessons-learned/2026-MM-DD-<slug>.md
... summary ...

### patterns/<area>/<name>.md
... summary ...

### Updated checklists
- checklists/<file>.md → added: ...

### Updated playbooks
- docs/13-playbooks/<file>.md → updated: ...

## Files NOT created (and why)
- success — нечего повторять, проект тривиальный
- failure — обошлось без инцидентов
```

## Refusal rules

- Не сохранять секреты, PII, приватные payload'ы, закрытый код.
- Не создавать пустые / TODO-only артефакты.
- Не дублировать существующий pattern / lesson — обновить, а не плодить.
- Если retro / diff не предоставлены — спросить, не выдумывать опыт.

## Related

- [update-wiki prompt](update-wiki.md)
- [case-studies/](../case-studies)
- [lessons-learned/](../lessons-learned)
- [patterns/](../patterns)
- [AGENTS.md](../AGENTS.md)
