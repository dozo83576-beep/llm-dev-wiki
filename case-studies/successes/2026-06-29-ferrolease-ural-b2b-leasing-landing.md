---
title: "Успешное решение: B2B leasing landing с каталогом, калькулятором и Vercel deploy"
category: "case-study"
updated: "2026-06-29"
status: "validated"
tags: ["nextjs", "tailwind", "landing", "lead-generation", "vercel", "github", "b2b"]
source_priority: "internal"
date: "2026-06-29"
project_type: "B2B lead-generation landing"
stack: ["Next.js", "TypeScript", "Tailwind CSS", "Framer Motion", "Vitest", "Playwright", "Vercel"]
---

# Контекст

Нужно было собрать продающий B2B лендинг для лизинга спецтехники: каталог моделей, предварительный калькулятор, квиз-подбор, FAQ, форма заявки, SEO и деплой. В проекте использовались demo-контакты, demo-адрес и demo-условия; их нельзя фиксировать как реальные данные.

# Решение

- Сайт собран на Next.js App Router + Tailwind + TypeScript с dry-run endpoint для лидов.
- В проект добавлен локальный visual reference как project-local source of truth.
- Шрифты self-host: Cyrillic-compatible display/body/mono стек.
- Фото техники сохранены локально с attribution и `photo-sourcing.md`; дилерские фото без прав не копировались.
- Каталог получил 20 моделей, разные layouts для общего режима и выбранной категории.
- Квиз не отправляет пользователя в отдельный тупик: ответы преобразуются в preset калькулятора.
- Карта сделана как локальная OSM-вырезка с attribution, без внешнего API на runtime.
- Проект опубликован через private GitHub repo и production deployment на Vercel.

# Почему сработало

- Project-local reference удержал визуальную целостность: карточки, секции, CTA и типографика сверялись с одним источником.
- Экранные секции дали управляемый rhythm: короткие блоки занимают viewport, длинные блоки имеют bounded scroll.
- DOM-метрики Playwright поймали проблемы, которые скриншот не доказывает: нижний чекбокс калькулятора, CTA, scroll-зоны FAQ.
- Финансовые предложения строились из каталога и калькулятора, а не из выдуманных "реальных кейсов".
- GitHub/Vercel pipeline дал воспроизводимый deploy и публичный smoke после публикации.

# Кодовые и архитектурные паттерны

- `CalculatorPreset`: общий контракт между квизом и калькулятором.
- `screen-section lead landing`: bounded viewport для каталога, калькулятора и FAQ.
- Dry-run lead API до выбора реального канала заявок.
- Локальные legal/stock images + отдельный sourcing документ.
- Private GitHub repo перед Vercel production deploy для проектов с demo-юридическими данными.

# Ограничения

- Demo-адрес, demo-контакты и demo-условия нужно заменить перед реальным запуском.
- OSM static image подходит для макета; для production-навигации может понадобиться полноценная карта или ссылка на карты.
- Внутренние scroll-зоны не стоит применять без проверки keyboard/focus и mobile UX.

# Проверка

- `npm run check`: lint, Vitest, production build.
- Playwright smoke: hero fit, catalog photos, category cards, calculator fit, FAQ scroll, contact map, quiz-to-calculator.
- Production smoke: Vercel URL отвечает 200, бренд и обновленный адрес присутствуют, старый demo-prefix отсутствует.

# Ссылки

- [Pattern: Screen-section lead landing](../../patterns/frontend/screen-section-lead-landing.md)
- [Playbook: Landing](../../docs/13-playbooks/landing.md)
- [Frontend review checklist](../../checklists/frontend-review.md)
- [Pattern: Cyrillic self-host fonts](../../patterns/frontend/cyrillic-self-host-fonts.md)
- [Pattern: Проверка stock-фото](../../patterns/frontend/stock-photo-id-verification.md)
