---
name: site-content
description: >-
  Фаза контента и информационной структуры сайта в D:\Work: модель контента, иерархия страниц,
  копирайтинг по секциям, выбор CMS, многоязычность (i18n) и юридический/consent-контент (политики,
  cookie, согласия). Использовать при наполнении лендинга, маркетингового, корпоративного или
  контентного сайта. Маршрутизирует в CMS-content, Payload-CMS, I18n и compliance-доки из
  D:\Work\llm-dev-wiki.
---

# site-content — контент и информационная структура

Тонкий роутер. Источник правды — `D:\Work\llm-dev-wiki`. Контент-модель влияет на дизайн, frontend и SEO — фиксируй её до вёрстки финальных страниц.

## Requires
- `site-architecture` завершён (контент-модель ложится на модель данных/CMS).
- Реальные тексты/медиа от заказчика или явные плейсхолдеры (не выдумывать).

## Когда использовать
- Наполнение публичного сайта; проектирование контент-модели и CMS.
- Многоязычные сайты; страницы с юридическим/consent-контентом.

## Сначала прочитай
- `D:\Work\llm-dev-wiki\docs\02-frontend\CMS-content.md` — выбор и модель контента.
- `D:\Work\llm-dev-wiki\docs\02-frontend\Payload-CMS.md` — headless CMS, если нужен редактируемый контент.
- `D:\Work\llm-dev-wiki\docs\02-frontend\I18n.md` — многоязычность и структура переводов.
- `D:\Work\llm-dev-wiki\docs\05-auth-security\Compliance-baseline.md`,
  `D:\Work\llm-dev-wiki\docs\05-auth-security\Privacy-policy-and-consent.md` и
  `D:\Work\llm-dev-wiki\docs\05-auth-security\RU-152fz-and-ai-data-handling.md` — политики, cookie-consent, согласия, 152-ФЗ и локализация ПДн.
- `D:\Work\llm-dev-wiki\docs\02-frontend\Content-migration.md` — инвентаризация и перенос реального контента.
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\AI-chat-widget.md` и
  `D:\Work\llm-dev-wiki\prompts\chat-widget-system-prompt.md` — если сайт включает AI-консультанта,
  чат-виджет, lead qualification или sales assistant.
- `D:\Work\llm-dev-wiki\patterns\frontend\semantic-theme-text-tokens.md` — читаемость текста на поверхностях.
- `D:\Work\llm-dev-wiki\docs\07-mcp-and-ai-tools\External-site-skills.md` — optional helpers
  `content-strategy`, `copywriting`, `copy-editing`, `brand-guidelines`, если они установлены.

## Шаги
1. Контент-модель: типы контента, поля, связи; что статично, а что редактируется через CMS.
2. Информационная архитектура: карта страниц, навигация, хлебные крошки, внутренняя перелинковка.
3. Копирайтинг по секциям: заголовки, CTA, ценность, FAQ; единый tone of voice.
3.1. Если доступны external content helpers, используй их для черновиков/ревью копирайтинга; факты, цены,
   кейсы и юридические формулировки не выдумывать и не публиковать без подтверждения.
3.5. Для service/portfolio сайта обязательны: FAQ, блок «что нужно от клиента/что прислать для оценки»,
   честные proof-блоки без выдуманных метрик, и объяснение пользы решений в кейсах.
3.6. Если нужен AI chat widget, сначала собрать проверенные факты, CTA, tone, forbidden claims и handoff rules.
   Prompt писать по `chat-widget-system-prompt.md`; provider key только backend-side, не во frontend.
4. i18n-готовность: вынос строк, форматы дат/чисел/валют, hreflang (синхронно с `site-seo`).
5. Юридический контент: privacy/terms, cookie-consent, формы согласия — без сбора лишних данных.

## Quality gate
- Есть контент-модель и карта страниц; строки готовы к i18n (не захардкожены).
- Реальный контент перенесён или стоят явные плейсхолдеры; нет lorem ipsum; старые URL → 301 при переносе.
- Для service/portfolio сайта есть FAQ, блок подготовки заявки и proof-блоки без фейковых отзывов/конверсий.
- Для AI chat widget есть refusal rules, few-shot examples, lead handoff и запрет на выдуманные цены/обещания.
- Юридические страницы и consent присутствуют там, где собираются персональные данные/cookies; объём решает product/legal owner по `Privacy-policy-and-consent.md`.
- Текст читается на всех поверхностях (см. предпочтение по токенам текста).
- Проверяет: self-check агента + подтверждение контента заказчиком (тексты/медиа — внешний вход).

## Передача дальше
`site-frontend` и `site-seo` — **параллельные соседи после site-content** (вёрстка по контенту/токенам и метаданные/hreflang/structured data соответственно).
