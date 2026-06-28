---
title: "Docker Compose"
category: "devops"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["docker-compose", "local-dev"]
source_priority: "official-docs"
---

# Docker Compose

Docker Compose описывает локальное окружение разработки: app, PostgreSQL, Redis, workers, vector DB, mailcatcher. Цель — `docker compose up` на чистой машине поднимает рабочую среду без ручных шагов.

## Когда использовать

- Локальная разработка с реальными зависимостями (БД, очереди, S3-compatible storage).
- Integration tests в CI против настоящих сервисов.
- Demo / preview окружения для shared dev-серверов.

## Когда не использовать

- Production — для prod бери Kubernetes / managed-сервисы / Render / Fly.
- Высокая нагрузка / HA — Compose не оркестратор.
- Когда сервисы уже в Vercel/Render и локально достаточно SQLite + dev-server.

## Production-паттерны (для dev/CI)

- `docker-compose.yml` — базовая конфигурация, `docker-compose.override.yml` — локальные override (не коммитится).
- Health-checks для зависимых сервисов (`depends_on: condition: service_healthy`).
- Named volumes для БД, чтобы данные переживали restart.
- `.env` для локальных переменных, `.env.example` коммитится без секретов.
- Версия Compose-файла указана явно (`name:` + `services:` без `version:` в новых версиях).
- Service-имена совпадают с DNS — приложение обращается по имени (`postgres`, `redis`), а не localhost.

## Частые ошибки

- Хранить production-credentials в compose-файле.
- Не выставить `restart: unless-stopped` на dev-сервисах — упавший Postgres ломает день.
- Прокидывать `network_mode: host` для удобства и потом нести это в prod.
- Жёстко прибитые `ports: "5432:5432"` конфликтуют с системным Postgres.
- Использовать `latest` для образов БД — внезапные мажорные апгрейды ломают volumes.

## Security risks

Секреты в compose-yaml в открытом виде, открытые порты на `0.0.0.0` на dev-сервере с публичным IP, дефолтные admin-пароли БД.

## Performance risks

Большие volume mounts с миллионами файлов (node_modules) сильно тормозят на macOS/Windows — нужен named volume или delegated mount.

## Testing strategy

- `docker compose up --wait` в CI с healthchecks.
- Pytest / Jest integration tests против поднятых сервисов.
- Cleanup в CI: `docker compose down -v` после job.

## Edge cases

- WSL2 vs нативный Windows Docker — разная производительность IO.
- Конфликты портов с локально установленным Postgres/Redis.
- Compose v1 (python) vs v2 (плагин) — синтаксис почти совпадает, но команды разные.

## Источники

- [Docker Compose Docs](https://docs.docker.com/compose/) — проверено 2026-05-24.
- См. [Docker](Docker.md), [Environment variables](Environment-variables.md), [Integration testing](../09-testing/Integration-testing.md).
