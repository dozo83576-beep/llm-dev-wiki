---
title: "GitHub Actions"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["ci", "github-actions", "cd"]
source_priority: "official-docs"
---

# GitHub Actions

GitHub Actions — основной CI/CD-движок для проектов на GitHub. Минимальный продукт: lint, typecheck, tests, build, security scan, deploy с environment protection.

## Когда использовать

- Любой проект на GitHub без особых требований к self-host.
- Reusable workflows для общих job-ов между репозиториями.
- Deploy в облако через OIDC (AWS/Azure/GCP) без хранения долгоживущих ключей.

## Когда не использовать

- Тяжёлые ML-jobs или GPU — managed runner или self-hosted.
- Сложные DAG-пайплайны с условной логикой по графу артефактов — лучше Argo/Tekton.
- Если организация требует on-prem CI (бери Jenkins/Tekton).

## Production-паттерны

- Pin actions на SHA, а не на тег (`actions/checkout@a1b2c3...`), иначе supply-chain риск.
- Минимальные `permissions:` на job-уровне (default `contents: read`).
- OIDC + cloud federation вместо хранения long-lived deploy keys.
- `concurrency` groups, чтобы старые ранов на ветке отменялись.
- Reusable workflows (`workflow_call`) для общих verify/deploy шагов.
- Environment + required reviewers для production deploy.
- Branch protection требует зелёного CI и обзор.
- Caching через `actions/cache` или встроенный `cache:` в `setup-node` / `setup-python`.

## Частые ошибки

- `pull_request_target` без проверки автора — выполнение кода форка с доступом к secrets.
- Третьесторонние actions без pin'а на SHA.
- Логировать `${{ secrets.* }}` через echo для дебага.
- Один workflow на всё (verify + deploy + release) — медленно и нечитабельно.
- Игнорировать matrix-сбои через `continue-on-error: true` глобально.

## Security risks

Supply chain через скомпрометированные actions, утечка secrets через job outputs, неверные `permissions:` дают write-доступ к репо из любого workflow.

## Performance risks

Cold install без cache, ненужные matrix-комбинации, последовательные job-ы там, где можно параллельно, тяжёлый checkout с `fetch-depth: 0` когда нужен только HEAD.

## Testing strategy

- Тест workflow через `act` локально или dispatch на feature branch.
- Self-test job, который проверяет, что критичные required-checks существуют.
- Periodic security scan workflow (CodeQL, dependency-review).

## Edge cases

- Forks PR — secrets недоступны по умолчанию, deploy/preview нужно делать через отдельный mechanism.
- Несколько окружений с одинаковыми именами в разных репо — путаница в auditе.
- Workflow на push в tag — порядок событий vs PR.

## Источники

- [GitHub Actions Docs](https://docs.github.com/en/actions) — проверено 2026-05-24.
- [Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions) — проверено 2026-05-24.
- См. [CI templates](CI-templates.md), [Secrets](../05-auth-security/Secrets.md), [Release flow](Release-flow.md).
