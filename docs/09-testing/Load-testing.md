---
title: "Load testing"
category: "testing"
updated: "2026-05-24"
status: "active"
tags: ["load-tests", "performance", "k6"]
source_priority: "official-docs"
---

# Load testing

Load testing отвечает на вопросы "выдержим ли N rps", "где первая точка отказа", "что произойдёт под пиком в 5× от плана". Он не заменяет real-user-monitoring, но защищает от сюрпризов в первый день большого запуска.

## Когда использовать

- Перед маркетинговым запуском / Black Friday.
- Изменения в hot path (checkout, login, search, AI endpoint).
- После архитектурных изменений (новая БД, кеш, очередь).
- Webhooks с непредсказуемым trafic burst.
- Real-time / WebSocket с большим concurrency.

## Когда не использовать

- POC и MVP без планов на масштаб.
- Internal admin с известным малым числом пользователей.
- Когда нет baseline — сначала собери метрики, потом нагружай.

## Типы тестов

- **Smoke**: 1–5 VUs, проверка что endpoint вообще отвечает.
- **Load**: целевая нагрузка по SLO в течение длительного времени.
- **Stress**: ramp up до точки отказа.
- **Spike**: внезапный пик трафика.
- **Soak**: длительный (часы) на выявление утечек памяти / лимитов.

## Production-паттерны

- Инструменты: **k6** (рекомендуется), Locust, Artillery, Gatling.
- Тесты в репо как код, привязаны к user-journey.
- Realistic data: разные user-tier, разные tenants, разные query patterns.
- Запуск против staging с realistic-set данных (не пустая БД).
- Метрики собираются на стороне target-системы (DB, queue, app), а не только клиент.
- Acceptance criteria: p95 latency, error rate, ресурс-saturation — заданы заранее.
- Регулярный прогон (раз в спринт / релиз) с trend-отчётом.

## Частые ошибки

- Нагружать production без подготовки — реальный outage.
- Сравнивать с прошлым тестом, забыв изменение схемы данных.
- Считать "выдержали" по error rate, игнорируя latency.
- Все virtual users делают один и тот же запрос — нерепрезентативно.
- Не сбрасывать кеши / connections между прогонами.

## Security risks

Нагрузка-как-DoS на shared staging инфраструктуру, утечка test-данных через логи, exposure внутренних endpoint при перенаправлении трафика.

## Что измерять

- Latency: p50, p95, p99, max.
- Error rate по коду (4xx, 5xx, timeout).
- DB saturation: connections, CPU, IO, lock waits.
- Queue lag, worker throughput.
- External API timeouts / rate limits.

## Edge cases

- Cold start (serverless / контейнеры) vs warm.
- Connection pool exhaustion раньше, чем CPU.
- Rate limits / WAF блокируют тест из одного IP.
- Geographic latency — нужен распределённый load.

## Источники

- [k6 Docs](https://grafana.com/docs/k6/latest/) — проверено 2026-05-24.
- [Performance Testing Patterns](https://k6.io/docs/test-types/introduction/) — проверено 2026-05-24.
- См. [Performance](../02-frontend/Performance.md), [Observability](../08-devops-deploy/Observability.md), [Query optimization](../04-databases/Query-optimization.md).
