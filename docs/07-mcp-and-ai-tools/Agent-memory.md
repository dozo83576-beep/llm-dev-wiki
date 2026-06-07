---
title: "Agent memory"
category: "ai-tools"
updated: "2026-06-07"
status: "active"
tags: ["agents", "memory"]
source_priority: "internal"
---

# Agent memory

Agent memory хранит полезные предпочтения, проектные решения и ссылки на lessons learned. Она не должна хранить секреты и приватные данные.

Для этой wiki основная память агента — внешняя: documents, patterns, case studies, checklists и golden Q&A. Memory entry должна ссылаться на проверенный artifact, а не заменять его.

Личные preference entries пользователя отделены от wiki-memory. Они хранятся локально в `D:\Work\AGENT-PREFERENCES.local.md` и не коммитятся в GitHub-wiki. Wiki описывает только процесс и безопасные шаблоны; персональные референсы, любимые шрифты и taste choices остаются local-only.

## Что сохранять

- Предпочитаемые стеки и архитектурные решения.
- Проверенные паттерны со ссылкой на wiki artifact.
- Ошибки, которые нужно не повторять, со ссылкой на failure case или lesson.
- Ссылки на case studies.
- Ссылки на local preference memory только как указание процесса, без копирования личного содержимого в wiki.

## Что не сохранять

- API keys, tokens, cookies.
- Персональные данные клиентов.
- Закрытые коммерческие данные без разрешения.
- Временные гипотезы, которые не были проверены.
- Полный transcript задачи, если из него можно извлечь короткий sanitized lesson.
- Личные визуальные референсы, приватные moodboards, клиентские материалы и вкусовые предпочтения пользователя в публичную wiki.

## Когда использовать

Используй agent memory для устойчивых предпочтений, проверенных lessons learned, проектных решений и ссылок на case studies.

## Когда не использовать

Не сохраняй временные догадки, секреты, приватный код, персональные данные и информацию, которую нельзя безопасно показывать будущим агентам.

## Production-паттерны

Memory должна быть маленькой, проверенной, датированной и связанной с источником. Любое правило должно иметь область применимости, ссылку на wiki artifact и способ пересмотра.

Перед задачами “сделай в моём стиле” или “используй мои предпочтения” агент должен прочитать local preference memory, затем свериться с wiki playbooks/blueprints и official docs. Preference проигрывает security, accessibility, performance и project-local constraints.

## Частые ошибки

Сохранять все подряд, смешивать факты и гипотезы, хранить секреты, не удалять устаревшие предпочтения, считать memory заменой audit/evals, пушить личные preference entries в wiki.

## Проверка

Периодический review memory entries, secret scan, проверка ссылок на lessons/case studies.

## Источники

См. [User preference memory](User-preference-memory.md), [lessons template](../../lessons-learned/_template.md), [Agent workflows](Agent-workflows.md), [Agent self-improvement loop](Agent-self-improvement.md).
