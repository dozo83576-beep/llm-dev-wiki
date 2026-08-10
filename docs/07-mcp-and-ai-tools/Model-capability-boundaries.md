---
title: "Model capability boundaries"
category: "ai-tools"
updated: "2026-08-10"
status: "active"
tags: ["models", "skills", "tools", "codex", "claude"]
source_priority: "official-docs"
---

# Model capability boundaries

Политика рассчитана на GPT-5.6 Sol и Claude 5 family. Capability claims со временем меняются, поэтому конкретную доступность модели, режима и инструмента нужно проверять в текущем runtime.

## Когда использовать

Используй при выборе между нативной работой модели, локальным skill и внешним инструментом.

## Когда не использовать

Не используй как статический каталог всех функций модели или замену фактической runtime-проверки.

## Нативная модель

Без профильного skill модель выполняет анализ предоставленного контекста, планирование, архитектуру, data/API design, генерацию и статическое review кода, тестовые сценарии, UX/design direction, тексты и синтез документов.

Skill не должен повторно объяснять общие инженерные принципы, квоты вариантов или обязательный пошаговый процесс, если они не являются локальным контрактом.

## Агентский runtime

Runtime даёт модели чтение и изменение файлов, команды, тесты/build, диагностику репозитория и визуальную проверку. Это нативная агентская работа, а не основание для отдельного process skill.

## Локальный skill

Skill хранит только неизвестное модели: правила `D:\Work`, contract/resume, owner фазового артефакта, подтверждённые failure patterns, 152-ФЗ/обезличивание, запрет секретов и approval перед production/DNS/billing.

Подробности остаются в вики и читаются по условию. Машиночитаемые границы и владельцы: [skill-capability-policy.json](../../resources/skill-capability-policy.json).

## Внешний инструмент

Инструмент обязателен, когда ответ зависит от внешнего или текущего состояния: актуальные версии и документация, live сайты и выдача, browser measurements, внешние аккаунты, deploy, monitoring и production acceptance. Skill не может заменить evidence.

Для browser-работ действует один порядок: специализированный API/connector для provider-state → Browser для обычной визуальной приёмки → Chrome только для существующей авторизованной сессии → Playwright для воспроизводимого изолированного теста → computer-use для небраузерного Windows UI или обоснованного fallback.

## Правила

Нативная модель используется по умолчанию. Helper подключается только для конкретного пробела с проверяемой добавочной ценностью. Его отсутствие не блокирует задачу, если результат можно получить и подтвердить нативно.

## Частые ошибки

Объявлять helper обязательным, дублировать нативное planning/review, подменять внешний evidence инструкцией или оставлять неиспользуемые plugins always-on.

## Проверка

Сверь runtime с `skill-capability-policy.json`, запусти semantic verifier и убедись, что каждая capability имеет одного owner, а внешние факты подкреплены инструментом.

## Источники

- [GPT-5.6](https://openai.com/index/gpt-5-6/) — coding, tool coordination, computer use, design и knowledge work.
- [Claude Fable 5 and Mythos 5](https://www.anthropic.com/news/claude-fable-5-mythos-5).
- [Claude Sonnet 5](https://www.anthropic.com/news/claude-sonnet-5).
- [Agent Skills best practices](https://agentskills.io/skill-creation/best-practices) — concise instructions и progressive disclosure.
