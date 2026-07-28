# Ревью и усиление системы создания сайтов

Дата: 2026-07-21. Скоуп: contract, 17-фазный workflow, router/preflight, canonical skills,
runtime parity, два pilot status и локальные gates.

## Итог

17 контрольных фаз сохранены, но система переведена с жёсткой линейности на проверяемый dependency
graph. Единственный источник правды — `resources/site-pipeline-contract.json` v2. Bootstrap,
verifier, карта и оркестратор больше не должны поддерживать независимые массивы фаз.

## Исправленные критические дефекты

- Verifier теперь отклоняет неизвестные playbook/profile/guides, неверные `not-applicable`/`skipped`,
  несуществующие календарные даты, пустые или неканонические artifacts, выход из project root и
  symlink/junction escape.
- Проверка готовности идёт по зависимостям. Design и backend могут закрываться независимо;
  frontend ждёт оба применимых результата.
- Bootstrap status v2 использует `FileMode.CreateNew`, остаётся dry-run-first и безопасен при гонке.
- Добавлены `-RequirePhase` и `-RequireComplete`.

## Contract v2

- Метаданные status: `Contract-Version`, один primary `Playbook`, `Supporting-Guides`,
  `Delivery-Profile`.
- Profiles: `public-static`, `public-fullstack`, `private-app`, `api-only`.
- Статусы: `pending`, `in-progress`, `done`, `not-applicable`, `skipped`.
- Только `post-release` может быть осознанно `skipped`; неприменимость остальных фаз задаётся profile.
- Добавлен primary playbook `content-site`; headless commerce и Shopify Hydrogen переведены в guides.

## Router и preflight

Классификация разделена на продуктовую и платформенную оси. JSON output содержит
`recommendedPlaybook`, `recommendedDeliveryProfile`, `supportingGuides`. Shopify выбирается только
по явному положительному ограничению; отрицание «Shopify не используется» учитывается. Покрыты
landing, content/CMS, SaaS, e-commerce, admin, marketplace, API-only, AI/RAG и real-time.

## Границы skills

Все 14 canonical skills сохранены.

- `build-modern-site` сокращён до orchestration/resume/contract verification.
- `site-stack` не повторяет preflight.
- `site-competitive-analysis` владеет market/reference/standards benchmark и visual signals.
- `site-design` потребляет готовые signals и не повторяет competitor outlier research.
- `site-frontend` создаёт один smoke-набор; review/deploy/handoff повторяют его в своих окружениях.
- Review фиксирует UAT readiness, deploy — approval на promotion, handoff — production acceptance.
- Optional helpers централизованы: default zero, максимум один узкий helper на фазу с обоснованием.

## Pilot migration

- `D:\Work\ferrolease-ural-site`: `landing`, `public-fullstack`.
- `D:\Work\local-market-woo`: `marketplace`, `public-fullstack`, guide `wordpress-woocommerce`.

Все исторические фазы оставлены `pending`: evidence не выдумывалось. Оба status v2 проходят verifier.

## Проверка

- Финальный full pytest: `113 passed, 1 skipped` (file symlink test требует недоступную локальную
  привилегию; Windows junction regression выполнена и прошла).
- `ci-local.ps1 -IncludeToolTests -SkipGeneratedDiffCheck`: passed; wiki audit `Failures: 0`,
  pipeline verifier `Failures: 0`, Node tests `6 passed`.
- Offline retrieval: `Precision@5 = 1.000`, weak warnings `0`, missing paths `0`.
- Canonical/runtime sync: 14 skills; runtime cache, Claude Code и Codex; `Failures: 0`.
- Оба pilot status v2: `Failures: 0`.

Wiki quality оставляет три stamp-warning до будущего commit: изменённые документы имеют дату
2026-07-21, а последний commit у них старше. Это не content defect; commit в этот scope не входит.

## Оставшееся ограничение

Механика полного перехода по графу доказана интеграционными fixtures для четырёх profiles, но реальный
проект всё ещё не прошёл все 17 фаз до production evidence. Pilot status честно остаются `pending`;
это операционная следующая проверка, а не основание искусственно помечать историю `done`.

## Learning review

Decision: update existing artifact and canonical project-local skills.

Reusable knowledge: contract v2, двухосевой router, profile applicability, dependency gates и
границы review/deploy/handoff закреплены в этом отчёте, профильных docs и
`llm-dev-wiki/agent-skills`. Отдельный lesson/case-study не создан, чтобы не дублировать аудит.
Глобальные skills и `AGENT-PREFERENCES.local.md` не менялись: это системный контракт проекта, а не
личное предпочтение. Evidence — verifier, 113 Python tests, 6 Node tests, runtime parity и retrieval evals.
