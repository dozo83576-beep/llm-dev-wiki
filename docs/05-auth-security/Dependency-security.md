---
title: "Dependency security"
category: "security"
updated: "2026-05-24"
status: "active"
tags: ["dependencies", "supply-chain"]
source_priority: "official-docs"
---

# Dependency security

Проверяй зависимости через npm audit/pnpm audit, GitHub Dependabot, lockfile review, минимизацию пакетов, pinned versions для критичной инфраструктуры.

Не добавляй пакет ради одной функции, если стандартная библиотека или маленький локальный helper решают задачу безопаснее.

Источник: [GitHub Dependabot Docs](https://docs.github.com/en/code-security/dependabot).

## Когда использовать

Всегда для npm, PyPI, Docker images, GitHub Actions, MCP servers и любых third-party SDK.

## Когда не использовать

Не блокируй релиз из-за low-risk dev dependency без exploit path, но документируй решение и срок обновления.

## Production-паттерны

Lockfile committed, Dependabot или аналог включен, package review для новых зависимостей, минимальный dependency surface, pinned CI actions.

## Частые ошибки

Добавить пакет ради одной функции, игнорировать transitive critical vulnerability, использовать unpinned GitHub Action, запускать неизвестный postinstall.

## Проверка

`npm audit`/`pnpm audit`/`pip-audit`, dependency review в PR, GitHub security alerts, SBOM для mature проектов.

