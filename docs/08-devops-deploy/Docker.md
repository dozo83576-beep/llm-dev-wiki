---
title: "Docker"
category: "devops"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["docker", "containers"]
source_priority: "official-docs"
---

# Docker

Docker фиксирует runtime окружение и упаковывает приложение со всеми зависимостями. Цель — воспроизводимая, маленькая, безопасная image, одинаковая для CI, staging и production.

## Когда использовать

- Backend-сервисы с явными системными зависимостями.
- Workers, cron-jobs, ML-инференс с заданным runtime.
- Локальная разработка через docker-compose с реальной БД/Redis.

## Когда не использовать

- Чистый serverless / edge (Vercel/Cloudflare Workers) — runtime управляет провайдер.
- Простой статический сайт — CDN достаточно.
- Когда команда не готова поддерживать build-pipeline и security-обновления базовых образов.

## Production-паттерны

- Multi-stage build: отдельная stage для зависимостей и финальный slim-image.
- Не-root user (`USER node` / `USER app`) и read-only filesystem где возможно.
- Маленькие базовые образы: `node:22-alpine`, `python:3.12-slim`, `distroless` для prod.
- `HEALTHCHECK` инструкция или k8s liveness/readiness probes.
- `.dockerignore` исключает `.git`, `node_modules`, `.env`, тесты, fixtures.
- Pin базового образа на digest (`@sha256:...`) для воспроизводимости.
- Build args для версий, не для секретов.

## Частые ошибки

- Копировать `.env` или приватные ключи в image.
- Запускать `apt-get update && apt-get install` без `--no-install-recommends` и `rm -rf /var/lib/apt/lists/*`.
- Делать одну гигантскую stage без cache-friendly layering.
- Использовать `latest` тег базового образа — невоспроизводимая сборка.
- Запускать `npm install` в production stage вместо `npm ci --omit=dev`.

## Security risks

CVE в базовых образах без regular rebuild, утечка секретов в build cache/layers, `--privileged` контейнеры, exposed ports на 0.0.0.0 без firewall.

## Performance risks

Большие images (медленный pull), холодный cache в CI, плохое layering ломает re-use слоёв.

## Testing strategy

- `docker build` в CI как часть verify.
- Trivy / Grype скан на CVE.
- Smoke run контейнера с healthcheck.
- Размер image отслеживается (порог в CI).

## Edge cases

- Несколько архитектур (`linux/amd64,linux/arm64`) — buildx с правильным platform.
- Build на M-серии Mac vs deploy на amd64 — нужны cross-builds.
- Локальный bind-mount с правами пользователя контейнера.

## Источники

- [Docker Docs](https://docs.docker.com/) — проверено 2026-05-24.
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html) — проверено 2026-05-24.
- См. [Docker Compose](Docker-compose.md), [Secrets](../05-auth-security/Secrets.md), [Dependency security](../05-auth-security/Dependency-security.md).
