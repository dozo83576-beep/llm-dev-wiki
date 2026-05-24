---
title: "Prompt: update wiki"
category: "prompt"
updated: "2026-05-24"
status: "active"
tags: ["wiki", "knowledge-capture"]
source_priority: "internal"
---

# Prompt: update wiki

## Role

Tech lead, фиксирующий опыт проекта в LLM-вики. Цель — превратить разовый успех или ошибку в воспроизводимое знание.

## Context

Проект или этап завершён. Что делать с опытом после завершения проекта: выполнить knowledge capture, обновить вики и превратить опыт проекта в конкретные записи (success / failure / lesson / pattern / checklist update), а не общие "молодцы".

## Inputs

- `{{project_name}}` — короткое имя проекта.
- `{{date}}` — дата фиксации (YYYY-MM-DD).
- `{{outcome}}` — что произошло (запущено / выкатили без проблем / был incident / pivot).
- `{{stack}}` — стек, который использовали.
- `{{diff_summary}}` или `{{notable_prs}}` — ключевые PR / решения.
- `{{incidents}}` — список инцидентов, если были.

## Steps

1. **Decide artifact type**: success / failure / lesson / pattern / checklist update / новый playbook после завершения проекта.
2. **Use template**: соответствующий файл `_template-*.md` в [case-studies](../case-studies), [patterns](../patterns), [lessons-learned](../lessons-learned).
3. **Fill**: какая задача, какой стек, что сработало, что нет, как проверили, как повторить / предотвратить.
4. **Cross-links**: обновить related docs (playbooks, checklists), добавить ссылки в новый артефакт.
5. **Experience routing**: опыт проекта должен попасть в правильный раздел, чтобы будущий агент нашёл его через wiki retrieval.
6. **MEMORY**: ничего секретного / PII / приватного кода. Если есть — anonymize.
7. **Knowledge index**: обновить [docs/INDEX.md](../docs/INDEX.md), если затронуты основные разделы.

## Output schema

```
## Artifacts created / updated

### case-studies/successes/2026-MM-DD-<slug>.md
... content ...

### lessons-learned/2026-MM-DD-<slug>.md
... content ...

### patterns/<area>/<name>.md (новый)
... content ...

### Updated docs / checklists
- path → краткое описание изменения
```

## Refusal rules

- Не коммитить секреты, PII, приватные payload'ы, закрытый код.
- Не создавать пустые / "TODO" артефакты.
- Не дублировать существующий pattern / lesson — обновлять, не плодить.
- Не оставлять разделы шаблона незаполненными.

## Related

- [post-project-knowledge-capture prompt](post-project-knowledge-capture.md)
- [case-studies/](../case-studies)
- [lessons-learned/](../lessons-learned)
- [patterns/](../patterns)
- [AGENTS.md](../AGENTS.md)
