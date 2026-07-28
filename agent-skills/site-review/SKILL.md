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
- Все зависимости `site-review` закрыты по contract v2: `done` или профильный `not-applicable`.
- Phase evidence из `_backend-gate.md`, `_frontend-smoke.md` и `_seo-report.md` прочитан до повторных прогонов.

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
1. Потреби phase evidence и повторяй только интеграционные, security, legal и acceptance-boundary
   проверки. Не пересоздавай уже доказанные unit/component gates без причины.
1.5. По умолчанию helper не нужен. При конкретном пробеле допустим максимум один review helper;
   он не отменяет локальные checklist gates и фактический прогон тестов.
2. Security review: OWASP Top-10, authz на сервере, CORS/CSRF/CSP, секреты, dependency scan.
3. Для UI повтори единый smoke-набор из `_frontend-smoke.md` в integration environment и запусти
   site audit для публичных routes. Если smoke отсутствует, верни дефект в `site-frontend`, не
   создавай второй набор внутри review.
4. Для портфолио/кейсов: smoke изображений case gallery — preview и fullImage загружаются, lightbox закрывается по `Esc`/фону/кнопке, mobile без horizontal scroll; для lead-form проверить happy/error/fallback.
4.5. Для service/portfolio сайта: проверить analytics без PII, CTA-paths, FAQ, proof-блоки, блок подготовки заявки
   и отсутствие шаблонного вида «hero + одинаковые карточки».
5. Сухой прогон: логика, гонки, утечки, права доступа, крайние случаи.
6. Проверка тестов: unit/integration/E2E/contract/security по рискам; зафиксируй фактический статус прогона.
7. UAT readiness: прогон `qa-acceptance.md`, маппинг acceptance criteria, cross-browser/device и
   defect-triage. Фаза фиксирует готовность к UAT, но не подменяет approval на promotion или
   финальную production-приёмку.
8. Legal/152-ФЗ: для РФ-аудитории прогон `legal-compliance.md` — политика/согласие/локализация ПДн, ИИ-юр-тексты проверены человеком.
9. release-readiness: env vars, миграции, rollback, monitoring, alerts.
10. **Артефакт.** Сохрани в корень проекта `_review-report.md`: свод чек-листов (block/warn по
   областям), security-находки и их закрытие, статус тестов, маппинг UAT на acceptance criteria и
   статус UAT readiness. Это evidence фазы для `_pipeline-status.md`
   и обязательный вход `site-deploy`.

## Quality gate
- Нет открытых block-пунктов в чеклистах (включая `qa-acceptance`).
- Security review без критических находок; зависимости без известных уязвимостей.
- Site audit smoke пройден для public routes или есть documented exception.
- Для портфолио/кейсов: screenshot/lightbox smoke и lead-form smoke пройдены или есть documented exception.
- Для lead analytics: нет имени, контакта, сообщения, IP, user-agent и raw payload в событиях.
- Тесты прогнаны, статус отражён честно (если падают — указать вывод).
- UAT readiness подтверждена; promotion approval и production acceptance ещё не присваиваются.
- Свод ревью зафиксирован в `_review-report.md` проекта.
- Для РФ-аудитории `legal-compliance` пройден (нет block): политика/согласие/локализация ПДн, юр-тексты проверены человеком.
- Проверяет: профильные чеклисты и integration/security/legal tools; внешний acceptance остаётся handoff gate.

## Передача дальше
`site-deploy` — выпуск. Найденные новые критерии ревью предлагай в вики через `capture-learnings`.
