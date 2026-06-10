---
title: "Успешное решение: статический сайт автосервиса ТУРБОСЕРВИС"
category: "case-study"
updated: "2026-06-11"
status: "validated"
tags: ["static-site", "frontend", "localstorage", "animation", "accessibility", "layout"]
source_priority: "internal"
date: "2026-06-11"
project_type: "landing"
stack: ["HTML", "CSS", "JavaScript", "LocalStorage", "Python http.server"]
---

# Контекст

Многостраничный статический сайт автосервиса (главная, услуги, галерея, контакты, служебная панель
заявок) на HTML5/CSS3/vanilla JS без сборщика и бэкенда. Тёмная тема по умолчанию + светлая,
адаптивная вёрстка, доступность. Заявки складываются в мини-CRM на LocalStorage. Сайт прошёл
несколько итераций: фотографический анимированный Hero, шрифты, «блоки доверия» (марки, процесс,
счётчики, цены), живые отзывы и серию точечных фиксов вёрстки.

# Решение

Сайт оставлен **статическим** (HTML/CSS/JS, дизайн-токены в `:root`, две темы через
`[data-theme]`) — это соответствовало задаче (публичный маркетинговый сайт с минимальной
интерактивностью) и упростило ревью. Локальная проверка — через HTTP-сервер из корня, не `file://`.

Ключевые переиспользуемые решения:

- **Мини-CRM на LocalStorage**: единый ключ-контракт между публичной формой (writer) и панелью заявок
  (reader), схема `{id,…,createdAt,status}`, статусы, кросс-вкладочная синхронизация через событие
  `storage`. MVP без бэкенда.
- **CSS-only анимированный Hero** (Ken-Burns/glow/sweep) — все анимации на CSS, отключаются при
  `prefers-reduced-motion`. Текст на тёмном фото читается за счёт scrim-градиента и `text-shadow`,
  на семантических токенах `text-on-dark`.
- **rAF-микроинтеракции** (магнитные кнопки + параллакс Hero) под guard `pointer: fine` +
  reduced-motion; кастомный курсор-фолловер по запросу убран — оставлены только «магнит» и параллакс.
- **Structural fold-control**: первый экран (Hero + лента марок) обёрнут в `.first-screen` с
  `min-height: calc(100dvh - header)`; Hero `flex:1`, полоса прижата к низу — следующая секция не
  выглядывает над сгибом.
- **Count-up статистики** на `IntersectionObserver`, зеркалит существующий scroll-reveal, с
  обязательным fallback на финальное значение при reduced-motion / отсутствии IO.
- **Компактная форма записи** в 2 колонки через переиспользуемый `.fields-grid` — влезает в один экран.
- **Изображения**: royalty-free фото с Pexels CDN (после исчерпания квоты AI-генерации); логотипы
  марок — **текстовые вордмарки** вместо реальных логотипов (товарные знаки).

# Почему сработало

- Статический стек соответствовал задаче и дал быстрый цикл правок/ревью без инфраструктуры.
- LocalStorage-CRM закрыл MVP-потребность «куда складывать заявки» без сервера, с явным
  ключ-контрактом между формой и админкой.
- Вся анимация — CSS/rAF под reduced-motion-guard: «живость» без ущерба доступности и без зависимостей.
- Fold-control решён **структурно** (flex + `dvh`), а не подгонкой чисел — устойчив к разной высоте окна.
- Верификация **computed-метриками** в headless-превью дала точные факты (позиции, размеры, число
  колонок), несмотря на то что скриншоты/скролл/IO в этом окружении недоступны.

# Кодовые и архитектурные паттерны

Повторять подходы:

- [Full-height first screen](../../patterns/frontend/full-height-first-screen.md): первый экран = Hero +
  полоса, следующая секция не выглядывает над сгибом; высоту задаёт контент, а не `min-height`.
- [LocalStorage mini-CRM](../../patterns/frontend/localstorage-mini-crm.md): клиентский CRUD без бэкенда
  для MVP с единым ключ-контрактом и cross-tab sync.
- [Scroll-triggered count-up](../../patterns/frontend/scroll-count-up.md): счётчики на IO с обязательным
  reduced-motion fallback; число и единицы — разные узлы.
- [Semantic theme text tokens](../../patterns/frontend/semantic-theme-text-tokens.md): текст на
  тёмном/светлом — разными токенами; Hero фиксированно-тёмный в обеих темах.

# Ограничения

- LocalStorage-CRM — только MVP/учебное: нет auth, серверной валидации, синхронизации между
  устройствами; данные живут в одном браузере. Реальные/мульти-пользовательские данные → backend.
- «Всё на первый экран» зависит от высоты окна: цель — типовой ноутбук (~768–900px); на очень низких
  окнах форма/полоса могут не влезть целиком (вертикальный скролл — это нормально).
- Фото с Pexels — стоковые, не брендовые; вордмарки марок — текст, не реальные логотипы.
- Статический HTML без сборщика плохо масштабируется при множестве повторяющихся компонентов, CMS,
  i18n или сложных формах — тогда нужен Astro/Next.js static export/CMS.

# Проверка

- Все правки верифицированы в headless-превью **computed-метриками** (скриншоты недоступны — см. урок):
  - Форма записи: высота карточки `831 → 541px`, низ `816 ≤ 820` — **влезает** в экран; `.fields-grid`
    даёт 2 колонки на десктопе и 1 на мобиле; пустой сабмит показывает 4 ошибки валидации.
  - Первый экран: `.first-screen` = `100dvh − header`; следующая секция стартует на сгибе
    (`greyStripVisible ≈ 0`) на 820/720/900px; Hero растягивается (~586–666px).
  - Карточки услуг: длинный заголовок + цена не переполняют карточку (`price.right ≤ card.right`).
  - Шрифты/изображения: `getComputedStyle` содержит `Unbounded`/`Manrope`; `naturalWidth > 0`.
- Консоль без ошибок; темы dark/light без регрессий.

# Ссылки

- [Lesson: Верификация статики в headless-превью](../../lessons-learned/2026-06-11-headless-preview-verification.md)
- [Pattern: Full-height first screen](../../patterns/frontend/full-height-first-screen.md)
- [Pattern: LocalStorage mini-CRM](../../patterns/frontend/localstorage-mini-crm.md)
- [Pattern: Scroll-triggered count-up](../../patterns/frontend/scroll-count-up.md)
- [Pattern: Semantic theme text tokens](../../patterns/frontend/semantic-theme-text-tokens.md)
- [Похожий кейс: статический лендинг ТВОЙ ХИТ](./2026-05-27-tvoi-hit-static-landing.md)
- [Frontend review checklist](../../checklists/frontend-review.md)
- [Playbook: Landing](../../docs/13-playbooks/landing.md)
