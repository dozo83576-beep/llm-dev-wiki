---
title: "Cloudflare"
category: "devops"
updated: "2026-05-24"
status: "active"
tags: ["cloudflare", "edge", "dns", "cdn"]
source_priority: "vendor-docs"
---

# Cloudflare

Cloudflare закрывает несколько слоёв инфраструктуры: DNS, CDN, WAF, rate limiting, edge runtime (Workers/Pages), R2-storage, Tunnel. Каждый слой меняется отдельно, и каждый влияет на доступность продукта — потому изменения требуют отдельной проверки.

## Когда использовать

- Перед сайтом нужен managed CDN с WAF и DDoS-защитой "из коробки".
- Глобальный edge-runtime (Workers/Pages) даёт ощутимый latency-выигрыш и подходит под use case.
- Нужен managed DNS с быстрой пропагацией и API-управлением.

## Когда не использовать

- Простой статический сайт на одном регионе — нет смысла усложнять.
- Требуется long-running compute или большой in-memory state — Workers не подходят, бери Render/Fly.
- Корпоративные политики запрещают proxy через сторонний CDN.

## Production-паттерны

- DNS-зоны хранятся как код (Terraform/Pulumi или экспорт зоны) и ревьюятся через PR.
- WAF-правила версионируются; критичные правила имеют owner и changelog.
- Rate limiting на login, password-reset, signup, AI-endpoints и поиск.
- Page Rules / Rulesets описаны в репо, не правятся через UI без коммита.
- Cache key явно проектируется (varied by auth, locale), а не оставляется default.
- Cloudflare Access для админок и pre-prod окружений вместо публичного доступа.

## Частые ошибки

- Изменить DNS через UI без записи в git — следующее обновление перетрёт.
- Включить "Proxied" на mail-серверах или legacy-сервисах, которым нужен прямой TCP.
- Забыть про cache invalidation после релиза — пользователи видят старую сборку.
- Оставить WAF в "Log only" после теста и считать, что он защищает.

## Security risks

Mis-configured WAF bypass, утечка origin IP (нужен Argo Tunnel или Authenticated Origin Pulls), забытый API token с правами на всю учётку, открытые публичные R2-bucket.

## Performance risks

Холодные старты Workers, неправильный cache key, отсутствие compression на edge, лишние redirect-чейны через rules.

## Testing strategy

- Smoke-тест после изменения DNS: `dig`, проверка SSL chain, проверка кеша.
- WAF rule tests на staging-зоне с тем же ruleset.
- Synthetic checks на критичных страницах (auth, checkout) после релиза.

## Edge cases

- Несколько zones (preview/staging/prod) с разными rulesets — расхождения нужно ловить diff-ом.
- Сертификаты SSL для apex и wildcard — обновление и edge-case для cross-domain cookies.
- Workers KV/D1 eventual consistency между регионами.

## Источники

- [Cloudflare Developers](https://developers.cloudflare.com/) — проверено 2026-05-24.
- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/) — проверено 2026-05-24.
- См. [Release flow](Release-flow.md), [Rollback](Rollback.md), [CORS-CSRF-CSP](../05-auth-security/CORS-CSRF-CSP.md).
