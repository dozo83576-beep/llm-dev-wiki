---
name: build-modern-site
description: >-
  Карта работ по созданию сайта или веб-приложения в D:\Work: 17 фаз с зависимостями, resume и
  contract v2. Реализацию ведут профильные site-* скиллы. Маршрут берётся под масштаб задачи.
---

# build-modern-site

Карта сборки сайта. Машиночитаемый источник фаз, зависимостей, канонических артефактов, playbook'ов
и delivery profiles: `D:\Work\llm-dev-wiki\resources\site-pipeline-contract.json`.

## Масштаб

Маршрут выбирается под задачу, а не наоборот. Правка страницы или простой лендинг проходят коротким
путём — вход в фазу оправдан, когда она снимает реальную неопределённость. Полная карта нужна
крупному проекту с бэкендом, CMS, оплатой или нетривиальной интеграцией. Пропущенные фазы отмечай
с причиной, чтобы при возврате было видно, что осознанно не делалось.

Независимо от масштаба на публичном сайте остаются юрстраницы и 152-ФЗ.

## Вход

Для нового сайта прогони preflight — он подбирает playbook, delivery profile и показывает
lessons learned по похожим проектам:

```
pwsh D:\Work\llm-dev-wiki\tools\new-site-preflight.ps1 -Request "<запрос>" -OutputJson
```

При `needs-discovery` scaffold не создавай — закрой вопросы и повтори. Зафиксируй рекомендации
в `_preflight.md`, затем создай status-файл (`new-site-pipeline-status.ps1`, сначала dry-run).

Один primary playbook на проект. Ограничения платформы оформляются supporting guides, а не
смешением playbook'ов.

## Resume

Если `_pipeline-status.md` существует — прогони verifier, прочитай артефакты закрытых зависимостей
и продолжай с любой фазы, чьи зависимости закрыты. Ориентируйся на артефакты, а не на номер строки.

Статусы: `pending`, `in-progress`, `done`, `not-applicable`, `skipped`. После фазы обновляй статус:

```
pwsh D:\Work\llm-dev-wiki\tools\verify-site-pipeline.ps1 -ProjectRoot <project> -RequirePhase <phase>
```

Design и backend идут независимо после своих зависимостей; frontend ждёт оба применимых результата.
Перед финальным завершением — `-RequireComplete`.

## Кто что делает

`site-discovery` — требования и критерии приёмки · `site-competitive-analysis` — единственный
владелец исследования конкурентов и референсов · `site-stack` — выбор стека · `site-architecture` —
границы, данные, API, риски, этапы · `site-content` — контент-модель, юрстраницы, фактические
утверждения · `site-design` — направление и токены из готовых visual signals · `site-backend` —
API, данные, серверная безопасность · `site-frontend` — реализация и browser smoke ·
`site-seo` — публичный SEO или `noindex` по профилю · `site-review` — интеграция, безопасность,
UAT readiness · `site-deploy` — preview и promotion · `site-handoff` — production-приёмка ·
`capture-learnings` — фиксация опыта.

Профильные приёмы — в `llm-dev-wiki`; карта фаз — `docs/01-development-process/site-pipeline-map.md`.

## Границы

- Фаза `done` — когда её артефакт существует внутри проекта и непуст.
- Frontend smoke пишется один раз, а review/deploy/handoff прогоняют его в своих окружениях.
- Prod, DNS, оплата, секреты и внешние мутации — только с явным подтверждением.
- ПДн и секреты не уходят во внешние инструменты.
