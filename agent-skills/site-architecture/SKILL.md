---
name: site-architecture
description: >-
  Фаза проектирования архитектуры сайта в D:\Work: компоненты, границы ответственности, data flow, API,
  модель данных, auth, очереди, интеграции и deploy, с разбивкой реализации на 3–6 проверяемых этапов.
  Использовать после выбора стека и до написания кода. Маршрутизирует в design-architecture,
  implementation-plan, design-database и профильный playbook из D:\Work\llm-dev-wiki.
---

# site-architecture — архитектура и план

Тонкий роутер. Источник правды — `D:\Work\llm-dev-wiki`. Перед кодом всегда сначала архитектура.

## Requires
- `site-stack` завершён (стек выбран и обоснован) и есть план сайта из `site-competitive-analysis`.

## Сначала прочитай
- `D:\Work\llm-dev-wiki\prompts\design-architecture.md` — каркас архитектуры.
- `D:\Work\llm-dev-wiki\prompts\implementation-plan.md` — разбивка на этапы с acceptance.
- `D:\Work\llm-dev-wiki\prompts\design-database.md` — модель данных, индексы, миграции.
- `D:\Work\llm-dev-wiki\docs\13-playbooks\` — профильный playbook выбранного типа продукта.
- `D:\Work\llm-dev-wiki\patterns\` — применимые паттерны (api, backend, database, security, devops).
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\External-site-skills.md` — optional helpers для API/БД,
  если они установлены. Конфликтующий внешний `site-architecture` не использовать вместо этого локального скилла.

## Шаги
1. Опиши компоненты и границы ответственности: frontend, backend, данные, auth, API, очереди, интеграции, deploy.
2. Нарисуй data flow и ключевые контракты (REST/OpenAPI, события, вебхуки).
2.5. Если доступны `api-design-reviewer` или `database-designer`, используй их как ревью контрактов/схем,
   но итоговую архитектуру фиксируй по локальным prompts и playbook.
3. Спроектируй модель данных: сущности, связи, индексы, миграции, audit log, backup.
4. Перечисли top-5 security-рисков и mitigations; отметь edge cases (≥5).
5. Разбей реализацию на 3–6 этапов, каждый с измеримым acceptance.

## Quality gate
- Есть карта компонентов, data flow, модель данных и API-контракты.
- План этапов с acceptance; top-5 рисков; ≥5 edge cases.
- Проверяет: self-check агента по prompts/implementation-plan; план зафиксирован как артефакт.

## Передача дальше
Порядок: `site-content` (контент-модель) → `site-design` (визуальный слой) → затем `site-frontend` и
`site-backend` по этапам плана (parallel/sequenced), `site-seo` параллельно frontend.
