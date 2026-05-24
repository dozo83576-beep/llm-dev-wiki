---
title: "Failure case studies"
category: "case-study"
updated: "2026-05-24"
status: "active"
tags: []
source_priority: "internal"
---

# Failure case studies

В этой папке хранятся ошибки, анти-паттерны и правила предотвращения повторения.

## Когда добавлять запись

- Ошибка привела к багу, задержке, security-регрессии, data loss risk или rework.
- Причина повторяемая и может возникнуть снова.
- Нужно обновить чеклист, prompt или pattern.

## Формат

Используй `_template.md`. Каждый failure case обязан содержать “Как не повторять” и ссылку на обновленный checklist или pattern.

## Правило

Не ищи виноватого. Фиксируй систему, которая позволила ошибке случиться.
