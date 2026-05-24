---
title: "CI templates"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["ci", "github-actions", "templates"]
source_priority: "internal"
---

# CI templates

CI должен закрывать минимальный квалити-гейт за обозримое время (< 10 мин на PR) и быть одинаковым для всех проектов команды.

## Когда использовать

- Любой production-проект: lint, typecheck, tests, build, security scan, dep audit.
- Mono- и polyrepo с общими шаблонами через reusable workflows.

## Когда не использовать

- Sandbox / POC без планов деплоя — достаточно local `pnpm verify`.
- Скрипты с private credentials, которые нельзя положить в GitHub Secrets.

## Базовый skeleton (GitHub Actions)

```yaml
name: ci
on:
  pull_request:
  push:
    branches: [main]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm typecheck
      - run: pnpm test -- --coverage
      - run: pnpm build
      - run: pnpm audit --prod
```

## Production-паттерны

- Lockfile проверка обязательна (`--frozen-lockfile`).
- Кеширование зависимостей по hash lockfile.
- Параллельные job-ы (lint/test/build) для скорости; зависимости через `needs:`.
- Concurrency group по PR, чтобы старые ранов отменялись на новом push.
- Required checks в branch protection — PR не мерджится без зелёного CI.
- Отдельные workflow для security/perf, не блокирующие основной.

## Частые ошибки

- Запускать `pnpm install` без lockfile-режима — расхождение между local и CI.
- Хранить секреты в env шагов, а не в repository secrets / OIDC.
- Не настроить timeout — зависшие job блокируют ранеры.
- Игнорировать flaky тесты вместо починки — доверие к CI пропадает.

## Security risks

Утечка секретов через `echo $TOKEN`, выполнение untrusted PR-кода с доступом к secrets (`pull_request_target` без guard'ов), supply chain через third-party actions без pin'а на SHA.

## Performance risks

Холодный install без кеша, лишние шаги в горячем пути, тяжёлые матрицы (`os × node × pnpm`) когда достаточно одной комбинации.

## Testing strategy

- Smoke-job на every push (быстрый), полный — на PR.
- Отдельный workflow для contract tests против staging.
- Periodic schedule для security/audit чтобы ловить новые CVE.

## Edge cases

- Monorepo с changed-files filter — Turborepo/Nx affected build.
- Self-hosted runners — отдельная политика безопасности.
- Matrix-тесты с allow-failure для experimental версий.

## Источники

- [GitHub Actions Docs](https://docs.github.com/en/actions) — проверено 2026-05-24.
- См. [GitHub Actions](GitHub-actions.md), [Release flow](Release-flow.md), [Dependency security](../05-auth-security/Dependency-security.md).
