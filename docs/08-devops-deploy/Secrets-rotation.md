---
title: "Secrets rotation"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["secrets", "rotation", "security"]
source_priority: "mixed"
---

# Secrets rotation

Любой долгоживущий секрет рано или поздно утечёт. Ротация переводит управление от "если утечёт" к "когда обновляем", и тем самым ограничивает blast radius утечки.

## Когда использовать

- Регулярная ротация: 30/60/90/180 дней в зависимости от critical level.
- По событию: уход сотрудника с доступом, подозрение на компрометацию, изменение прав сервиса.
- После публикации в open-source / leak в logs / в git history.

## Когда не использовать

- Кратко-живущие OIDC / federated tokens — там нет ротации, они сами короткоживущие.
- Сертификаты с auto-renew (Let's Encrypt) — есть свой механизм.

## Производственные паттерны

- **Inventory**: каждый секрет имеет owner, location (Vault path / SSM name), scope, date_created, last_rotated, expires_at.
- **Categories**: API keys, OAuth client secrets, DB passwords, signing keys, encryption keys, third-party tokens.
- **Least privilege scopes**: один секрет — одна функция, не "admin для всего".
- **Separate per environment**: prod / staging / preview никогда не используют один токен.
- **Zero-downtime rotation**: для critical keys (signing, encryption) выпускается новый key id, оба валидны overlap window, потом старый отзывается.
- **Audit trail**: все access events логируются в неизменяемый журнал.
- **Automation**: ротация — скрипт, а не ручной шаг (Vault auto-rotation, AWS Secrets Manager rotation lambda).

## Частые ошибки

- Хранить секреты в git history (даже удалённые — остаются доступны).
- "Один токен на всю команду" — после ухода человека ротация откладывается.
- Ротация в production без overlap — даунтайм.
- Игнорировать `last_rotated` без алертов — секреты живут годами.
- Хранить новые секреты рядом со старыми в одном `.env.example`.

## Security risks

Утечка через CI logs, error tracker, frontend bundle (`NEXT_PUBLIC_*`), git history, container layers, screenshots в support tickets, browser history, локальная shell history.

## Процедура rotation (общий runbook)

1. Создать новый секрет с теми же или меньшими scopes.
2. Добавить новый секрет в secret manager (не удаляя старый).
3. Передеплоить приложение/обновить env vars в env, чтобы читал новый.
4. Дождаться окна валидации (метрики/логи без ошибок auth).
5. Отозвать старый секрет у провайдера.
6. Удалить старый из secret manager и из любых дублирующих мест.
7. Обновить inventory: `last_rotated`, `expires_at`.

## Testing strategy

- Periodic dry-run ротации на staging.
- Secret scanning в CI (TruffleHog, gitleaks, GitHub Secret Scanning).
- Alert на старые секреты (> X days since rotation).
- Тест отзыва: проверить, что старый ключ перестаёт работать в течение N минут.

## Edge cases

- Long-lived sessions, использующие старый JWT signing key — нужна grace period или forced re-login.
- Webhook subscriptions у третьих сторон ссылаются на старый secret — координировать.
- Multi-region — propagation delay secret manager.

## Источники

- [NIST SP 800-63B](https://pages.nist.gov/800-63-3/sp800-63b.html) — проверено 2026-05-24.
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html) — проверено 2026-05-24.
- См. [Secrets](../05-auth-security/Secrets.md), [Environment variables](Environment-variables.md), [Incident workflow](Incident-workflow.md).
