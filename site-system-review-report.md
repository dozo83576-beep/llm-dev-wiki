# Финальное ревью системы создания сайтов — отчёт

Дата: 2026-07-11. Скоуп: работоспособность, сквозная связность 17 фаз, висящие ресурсы, ошибки, безопасность. Методика: автоматические гейты + 3 Explore-субагента (связность / сироты и синтаксис / безопасность) + функциональные прогоны + ручная верификация каждой находки по первоисточнику.

## Вердикт

**Система работоспособна и пригодна к реальной сборке сайтов.** Вход в пайплайн (hook-детект интента → preflight → router) работает end-to-end; все 17 фаз имеют исполнителя, входы/выходы и gate; связность канона полная (сирот и битых ссылок нет); инструменты синтаксически чисты; тесты 81/81; секретов/PII нет; хуки без инъекционных векторов. Найденные дефекты (2 block, 4 warn, 2 nit) исправлены в этом же ревью, кроме двух warn-рекомендаций ниже.

**Ограничение вердикта:** механизм `_pipeline-status.md` введён 2026-07-05 — позже всех 13 существующих проектов, поэтому сквозной прогон всех 17 фаз с файловыми статусами ещё ни разу не выполнялся на реальном проекте. Компонентно способность доказана; финальное доказательство даст первый новый сайт.

## Что проверено и зелено (evidence)

| Проверка | Результат |
|---|---|
| `ci-local.ps1` (аудит 350 md, quality, 17 фаз, синк скиллов, retrieval-эвалы) | EXIT=0; 0 failures; 0 warnings; Precision@5 = 1.000 |
| `pytest tests` (вики) | 81 passed |
| Синтаксис всех `.ps1` (wiki tools, agent-skills, hooks, D:\Work\tools) | 0 ошибок парсинга; python `py_compile` — чисто |
| Хук site-intent (функционально) | позитив → JSON-инъекция требования пайплайна; негатив → молчание; stdin-JSON, регэксп-матч data-only, без Invoke-Expression |
| Stop-хук capture-loop | `decision: block` + напоминание; записывает только маркер с датой в %TEMP% |
| `new-site-preflight.ps1` (функционально) | status ready, route/stack/вопросы/6 wiki-доков (все существуют)/audit-команда; аргументы экранируются |
| Связность канона (субагент + ручная верификация) | ~150 путей в SKILL.md существуют; 14/14 скиллов имеют `agents/openai.yaml`; карта↔скиллы↔артефакты без расхождений |
| Сироты | нет: все 26 промптов и все инструменты имеют входящие ссылки (перепроверено вручную, 1–7 ссылок на файл) |
| Секреты/PII | чисто; `AGENT-PREFERENCES.local.md` не в git; `update-local-preferences.ps1` — dry-run по умолчанию + скан секретов; pre-commit = wiki-audit + verify-agent-skills |
| Permission-allowlist `.claude/settings.json` | все 6 целей существуют; масок шире необходимых нет |
| `.github/workflows` | ссылаются на существующие скрипты |

## Findings и статус

### BLOCK — исправлено

1. **Отсутствовал `tools/new-site-pipeline-status.ps1`**, на который ссылается обновлённый `build-modern-site` (bootstrap статуса фазы 1). Команда входа в пайплайн падала бы. → **Создан** (dry-run по умолчанию, `-Apply` для записи, отказ при существующем файле и неизвестном playbook, авто-skip 4 фаз для `api-only-backend`). Протестирован: `verify-site-pipeline -ProjectRoot` на сгенерированных статусах (landing и api-only) — 0 failures; негативные кейсы отклоняются.
2. **Дрейф runtime ≠ canon в 5 скиллах** (`build-modern-site`, `site-architecture`, `site-design`, `site-frontend`, `site-handoff`): правки 2026-07-10 13:09 были сделаны в runtime-кэше `.agent-skills` вместо канона — следующий sync молча затёр бы их. Содержимое правок качественное (bootstrap-инструмент, единая политика пропусков: обычный проект — только `post-release`, `api-only-backend` — ровно 4 фазы, mix playbook запрещён; marketplace — одна фаза с секциями `Public storefront`/`Private console`). → **Перенесено в канон**, sync во все 3 рантайма, `verify-agent-skills` — 0 failures. Правило на будущее: скиллы правятся ТОЛЬКО в каноне `llm-dev-wiki\agent-skills\` + sync.

### WARN — исправлено

3. **`site-competitive-analysis` без prompt-injection guard** при WebFetch чужих сайтов. → Добавлено в SKILL.md (шаг извлечения) и `docs/01-development-process/competitive-analysis.md`: fetched-контент — недоверенный ввод, встроенные инструкции игнорируются, ссылка на `Prompt-injection.md`.
4. **`site-handoff` без 152-ФЗ чек-пункта.** → Добавлен в Quality gate: в handoff-материалах нет ПДн; обработка ПДн на сайте соответствует `RU-152fz-and-ai-data-handling.md`.

### WARN — рекомендации (не исправлялось)

5. **CI не проверяет `_pipeline-status.md` реальных проектов**: `verify-site-pipeline.ps1` делает это только при явном `-ProjectRoot` (иначе early-return). Рекомендация: на первом новом сайте пройти полный цикл со статусами; затем добавить в CI список активных проектов для сквозной проверки.
6. **Регэксп intent-хука не ловит редкие формулировки** («построить сайт», «нужен веб-сайт»). Основные варианты покрыты; при желании — расширить паттерны в `hooks/userpromptsubmit-site-intent.ps1` (канон) + sync.

### NIT

7. Маркеры хуков пишутся в общий `%TEMP%` — теоретический риск на мультиюзер-машине; практически незначим.
8. Методологическое: субагентские отчёты дали 3 ложные находки («check-ai-tools.ps1 отсутствует» — существует в `D:\Work\tools\`; «9 промптов-сирот» и «2 инструмента-сироты» — у всех 1–7 входящих ссылок). Сняты ручной верификацией; правило «finding без проверки по файлу не принимается» обязательно.

## Изменения, внесённые этим ревью

- `agent-skills/{build-modern-site,site-architecture,site-design,site-frontend,site-handoff}/SKILL.md` — порт дрейфа из runtime + 152-ФЗ и injection-guard.
- `tools/new-site-pipeline-status.ps1` — новый bootstrap-инструмент (создан и протестирован).
- `docs/01-development-process/competitive-analysis.md` — правило недоверенного ввода.
- `docs/10-templates/pipeline-status.md` — bootstrap-команда создания файла.
- Sync скиллов во все рантаймы; паритет подтверждён.

## Покрытие 17 фаз

Каждая фаза карты имеет исполнителя, артефакт и gate (проверено субагентом и вручную): preflight→`_preflight.md`, site-discovery→`_discovery.md`, playbook→строка в статусе, site-competitive-analysis→`_competitive-analysis.md`, site-stack→`_stack.md`, site-architecture→`_architecture.md`, project-agents→`AGENTS.md`, site-content→`_content-model.md`, site-design→`DESIGN-DIRECTION.md`/токены, site-backend→`_backend-gate.md`, site-frontend→`_frontend-smoke.md`, site-seo→`_seo-report.md`, site-review→`_review-report.md`, site-deploy→`_deploy.md`, site-handoff→`handoff.md`, post-release→`_post-release-plan.md` (optional, с причиной), capture-learnings→`_learning-review.md`. Историческая база: 13 проектов созданы до механизма статусов; частичные артефакты старого образца — DESIGN-DIRECTION.md (3 проекта), handoff.md (1), project-AGENTS.md (9).
