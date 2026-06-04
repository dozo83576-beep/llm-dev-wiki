---
title: "Bun"
category: "backend"
updated: "2026-06-04"
status: "active"
tags: ["bun", "runtime", "typescript", "tooling"]
source_priority: "official-docs"
---

# Bun

Bun — JavaScript/TypeScript runtime, package manager, bundler and test runner. Для wiki это runtime/tooling decision doc, а не automatic replacement for Node.js.

## Когда использовать

- Нужны быстрый package install, script runner or test runner in JS/TS projects.
- Проект greenfield and dependencies проверены на Bun compatibility.
- Runtime target допускает Bun server APIs and deployment environment supports it.
- Команда готова фиксировать compatibility policy and fallback to Node where needed.

## Когда не использовать

- Production runtime depends on Node-specific native modules or platform behavior.
- CI/deploy/providers standardized on Node and no measurable bottleneck exists.
- Enterprise compliance требует conservative LTS runtime.
- Framework docs officially recommend Node for target deployment.

## Production-паттерны

- Разделяй Bun as tooling and Bun as production runtime; это разные решения.
- Lockfile, install command and CI cache фиксируются явно.
- Production runtime smoke tests запускаются в том же runtime, что deploy.
- Native/npm dependency compatibility проверяется before adoption.
- For mixed repos document which packages use Bun and which remain Node.

## Частые ошибки

- Менять runtime ради скорости install без оценки production compatibility.
- Предполагать Jest/Node APIs compatibility.
- Не иметь rollback to Node in CI/deploy.
- Использовать Bun benchmarks вместо собственных latency/build measurements.

## Security risks

Supply-chain controls, lockfile review, secret handling and dependency audit remain required. Runtime change can bypass existing security tooling if CI scripts differ.

## Performance risks

Faster startup/install may not improve app latency. Long-running memory behavior, native dependencies and provider runtime support need project-specific validation.

## Testing strategy

Run unit/integration/build under Bun and Node where fallback matters. Add production smoke for runtime APIs, file uploads, crypto, HTTP server behavior and database clients.

## Edge cases

Native modules, Prisma/drivers, test runner semantics, ESM/CJS differences, Docker image availability, CI cache, deployment provider support.

## Источники

- [Bun Docs](https://bun.com/docs)
- См. [Runtime selection](../01-development-process/runtime-selection.md), [Node.js](Nodejs.md), [Dependency security](../05-auth-security/Dependency-security.md).
