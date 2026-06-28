---
title: "Environment variables"
category: "devops"
updated: "2026-05-24"
reviewed: "2026-06-29"
status: "active"
tags: ["env", "config", "secrets"]
source_priority: "internal"
---

# Environment variables

Env vars — главный интерфейс между приложением и средой. Их нужно валидировать на старте, типизировать в коде, разделять по областям видимости и не путать с секретами.

## Когда использовать

- Конфигурация, зависящая от окружения (DB URL, base URL, feature flags).
- Секреты (через secret manager, инжектируемые как env).
- Переключатели и пороги, которые меняются без релиза кода.

## Когда не использовать

- Большие структурированные конфиги — лучше JSON/YAML в config-сервисе.
- Часто меняющиеся данные (списки, лимиты на пользователя) — это уже данные, а не конфиг.
- Личные dev-настройки разработчика — `.env.local`, не общий `.env`.

## Production-паттерны

- `.env.example` всегда в репо, без секретов, с описанием каждой переменной.
- Runtime-валидация через `zod` / `pydantic` / `envalid` — приложение падает с понятным сообщением, если переменная отсутствует.
- Разделение по scope: `PUBLIC_*` / `NEXT_PUBLIC_*` для client; всё остальное серверное.
- Source of truth — secret manager (Vault, AWS SSM, Doppler, 1Password Connect), а не `.env` в репо.
- Документировать каждую переменную: назначение, формат, дефолт, обязательность, owner.
- Не использовать env для feature flags динамического переключения — для этого есть flag-системы.

## Частые ошибки

- `NEXT_PUBLIC_API_SECRET` — попадает в bundle и сразу публично.
- Хранить JSON в одной переменной без валидации — невозможно ревьюить.
- Не валидировать на старте — ошибки всплывают на первом запросе в production.
- Дублировать одно и то же значение в трёх местах (`.env`, CI secret, vault) без single source of truth.
- Логировать `process.env` целиком при debug — секреты в логах.

## Security risks

Утечка секретов через build logs / SSR errors / error tracker, разделяемые admin-credentials, секреты в Git history, exposed `NEXT_PUBLIC_*` переменные с чувствительными данными.

## Performance risks

Чтение env в hot path вместо кеширования значений в модуле, JSON-парсинг на каждый запрос.

## Testing strategy

- Smoke-старт приложения с тестовым `.env` — проверка валидации.
- CI-проверка: все ключи из `.env.example` присутствуют в production secret manager (через скрипт).
- Secret scanning (TruffleHog, gitleaks) в CI.

## Edge cases

- Multi-environment (preview/staging/prod) с разным набором переменных.
- Build-time vs runtime env в Next.js / Vite — разная семантика.
- Длинные значения (приватные ключи PEM) и переносы строк — экранирование зависит от платформы.

## Источники

- [12 Factor App: Config](https://12factor.net/config) — проверено 2026-05-24.
- См. [Secrets](../05-auth-security/Secrets.md), [Secrets rotation](Secrets-rotation.md), [Release flow](Release-flow.md).
