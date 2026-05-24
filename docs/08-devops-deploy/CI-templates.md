---
title: "CI templates"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["ci", "github-actions"]
source_priority: "official-docs"
---

# CI templates

Минимальный CI для web-проекта: install, lint, typecheck, tests, build, security scan.

## GitHub Actions skeleton

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
      - run: pnpm test
      - run: pnpm build
```

Источник: [GitHub Actions](https://docs.github.com/en/actions).

