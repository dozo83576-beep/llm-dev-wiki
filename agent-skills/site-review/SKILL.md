---
name: site-review
description: >-
  Фаза сводного ревью сайта в D:\Work перед релизом: проверяет frontend, backend, API, БД, безопасность
  (OWASP, authz, CORS/CSRF/CSP, секреты, dependency scan) и готовность к выпуску по чеклистам. Использовать
  после реализации и до деплоя, либо для аудита существующего кода. Маршрутизирует в review-чеклисты и
  prompts code-review/security-review из D:\Work\llm-dev-wiki.
---

# site-review — ревью перед релизом

Тонкий роутер. Источник правды — `D:\Work\llm-dev-wiki`. Оспаривай слабые решения аргументированно.

## Requires
- `site-frontend` завершён (и `site-backend`, если у проекта есть серверная часть, и `site-seo`,
  если сайт публичный).
- Для API-only backend (playbook `api-only-backend`, нет визуального UI): достаточно, что
  `site-backend` завершён — `site-design`/`site-frontend`/`site-seo` для этого типа проекта не
  применяются.

## Сначала прочитай
- Перед ревью: `pwsh D:\Work\llm-dev-wiki\tools\ask-wiki.ps1 "<стек + ревью/безопасность>"` — поднимет чеклисты и уроки, которых нет в списке ниже.
- Слои контекста: project `AGENTS.md` → `D:\Work\AGENTS.md` → `AGENT-PREFERENCES.local.md` → вики — один раз за сессию, не перечитывать, если уже в контексте (правила — оркестратор `build-modern-site`).
- `D:\Work\llm-dev-wiki\prompts\code-review.md`, `security-review.md`, `mcp-security-review.md`
  (если проект использует MCP/AI-инструменты).
- `D:\Work\llm-dev-wiki\prompts\write-tests.md` — каркас добавления недостающих тестов по найденным в ревью пробелам.
- `D:\Work\llm-dev-wiki\checklists\` — `frontend-review.md`, `backend-review.md`, `api-review.md`,
  `database-review.md`, `security-review.md`, `ai-agent-review.md` (если есть AI/MCP), `qa-acceptance.md`,
  `legal-compliance.md` (ПДн/152-ФЗ для РФ-аудитории), `release-readiness.md`.
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\External-site-skills.md` — optional helpers
  `code-reviewer`, `senior-qa`, `dependency-auditor`, `security-pen-testing`, `ship-gate`,
  `env-secrets-manager`, если они установлены.

## Шаги
1. Прогон профильных review-чеклистов по затронутым областям; зафиксируй block/warn пункты.
1.5. Если доступны review/release helpers, используй их как дополнительный взгляд. Они не отменяют локальные
   checklist gates и фактический прогон тестов.
2. Security review: OWASP Top-10, authz на сервере, CORS/CSRF/CSP, секреты, dependency scan.
3. Для публичного сайта запусти lightweight smoke: `pwsh D:\Work\llm-dev-wiki\tools\site-audit.ps1 -Url <dev-or-staging-url>` или зафиксируй documented exception. Это не pentest. Для интерактивной проверки UI используй **Preview MCP** (`preview_snapshot`/`preview_console_logs`/`preview_screenshot`/`preview_resize`) или **Playwright MCP**: первый экран, mobile/desktop, формы, navigation, CTA, отсутствие overlap.
4. Для портфолио/кейсов: smoke изображений case gallery — preview и fullImage загружаются, lightbox закрывается по `Esc`/фону/кнопке, mobile без horizontal scroll; для lead-form проверить happy/error/fallback.
4.2. Сгенерируй недостающие smoke-тесты инструментами вики и адаптируй селекторы под проект:
   для lead-generation лендинга с каталогом/калькулятором —
   `pwsh D:\Work\llm-dev-wiki\tools\add-lead-landing-smoke.ps1`; для многосекционных/многостраничных
   сайтов (консистентность layout между страницами/секциями) —
   `pwsh D:\Work\llm-dev-wiki\tools\add-layout-consistency-smoke.ps1`.
4.5. Для service/portfolio сайта: проверить analytics без PII, CTA-paths, FAQ, proof-блоки, блок подготовки заявки
   и отсутствие шаблонного вида «hero + одинаковые карточки».
5. Сухой прогон: логика, гонки, утечки, права доступа, крайние случаи.
6. Проверка тестов: unit/integration/E2E/contract/security по рискам; зафиксируй фактический статус прогона.
7. UAT и приёмка: прогон `qa-acceptance.md` — маппинг на acceptance criteria, cross-browser/device, defect-triage, **client sign-off** до релиза.
8. Legal/152-ФЗ: для РФ-аудитории прогон `legal-compliance.md` — политика/согласие/локализация ПДн, ИИ-юр-тексты проверены человеком.
9. release-readiness: env vars, миграции, rollback, monitoring, alerts.
10. **Артефакт.** Сохрани в корень проекта `_review-report.md`: свод чек-листов (block/warn по
   областям), security-находки и их закрытие, статус тестов, маппинг UAT на acceptance criteria,
   client sign-off (дата / кто / где зафиксирован). Это evidence фазы для `_pipeline-status.md`
   и обязательный вход `site-deploy`.

## Quality gate
- Нет открытых block-пунктов в чеклистах (включая `qa-acceptance`).
- Security review без критических находок; зависимости без известных уязвимостей.
- Site audit smoke пройден для public routes или есть documented exception.
- Для портфолио/кейсов: screenshot/lightbox smoke и lead-form smoke пройдены или есть documented exception.
- Для lead analytics: нет имени, контакта, сообщения, IP, user-agent и raw payload в событиях.
- Тесты прогнаны, статус отражён честно (если падают — указать вывод).
- Client sign-off получен письменно до передачи в `site-deploy`/`site-handoff`.
- Свод ревью зафиксирован в `_review-report.md` проекта.
- Для РФ-аудитории `legal-compliance` пройден (нет block): политика/согласие/локализация ПДн, юр-тексты проверены человеком.
- Проверяет: профильные чеклисты (self-check + tool) + приёмка заказчиком (внешний gate).

## Передача дальше
`site-deploy` — выпуск. Найденные новые критерии ревью предлагай в вики через `capture-learnings`.
