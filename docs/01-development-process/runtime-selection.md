---
title: "Runtime selection"
category: "process"
updated: "2026-06-04"
status: "active"
tags: ["runtime", "node", "bun", "deno", "edge"]
source_priority: "mixed"
---

# Runtime selection

Runtime choice defines available APIs, deployment targets, dependency compatibility and security model. Choose runtime separately from frontend framework.

## Когда использовать

- Project starts greenfield or changes deploy target.
- Considering Node.js, Bun, Deno, Cloudflare Workers, Vercel Edge or browser-only static hosting.
- Dependencies include database drivers, file uploads, crypto, queues, WebSocket or native modules.

## Когда не использовать

- Existing production app has no runtime bottleneck and migration risk is higher than benefit.
- The framework/provider already mandates a runtime for the selected deployment.

## Production-паттерны

- Node.js remains conservative default for broad compatibility.
- Bun can be tooling-first before production runtime adoption.
- Deno/Fresh is a deliberate ecosystem choice, not a transparent Node replacement.
- Workers/edge runtimes use Web APIs and bindings; Node APIs are not assumed.
- Runtime decision includes CI commands, Docker/base image, deploy provider and rollback path.

## Частые ошибки

- Mixing runtime and framework decisions without checking provider support.
- Testing in Node while deploying to Workers.
- Ignoring native module/database driver compatibility.
- Treating package manager speed as enough reason to change production runtime.

## Security risks

Secrets, permissions, dependency scanning, sandbox model and supply-chain controls change by runtime. Edge preview environments must not share production bindings.

## Performance risks

Runtime startup speed is only one factor. Database region, cache policy, bundle size, third-party APIs and cold starts often dominate.

## Testing strategy

Run build/test/smoke in target runtime, verify database/file/crypto APIs, deploy preview, check provider logs, and document fallback runtime.

## Edge cases

ESM/CJS, native modules, binary dependencies, timezone/locale, file system access, WebSocket support, streaming APIs, serverless limits.

## Источники

- [Node.js Docs](https://nodejs.org/en/learn)
- [Bun Docs](https://bun.com/docs)
- [Deno Docs](https://docs.deno.com/)
- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
