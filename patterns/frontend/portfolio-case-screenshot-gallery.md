---
title: "Pattern: Portfolio case screenshot gallery"
category: "pattern"
updated: "2026-06-20"
status: "active"
tags: ["portfolio", "screenshots", "playwright", "lightbox", "case-study"]
source_priority: "internal"
area: "frontend"
date: "2026-06-20"
---

# Pattern: Portfolio case screenshot gallery

## Назначение

Показывать кейсы портфолио через реальные скриншоты проектов без выдуманных клиентов, отзывов и метрик. Галерея должна быть компактной в списке, но позволять рассмотреть страницу полностью.

## Когда использовать

- Портфолио фрилансера или студии.
- Демо-кейсы вместо коммерческих NDA-кейсов.
- Нужно показать несколько страниц проекта: главная, услуги, контакты, админка, галерея.

## Когда не использовать

- Есть реальные публичные кейсы с разрешёнными метриками и отзывами — лучше использовать их.
- Проект нельзя показывать визуально из-за NDA или приватных данных.
- Скриншоты содержат персональные данные, токены, внутренние заявки или админские секреты.

## Структура

- `image`: короткое preview-изображение `1365x768` для карточки.
- `fullImage`: отдельное изображение для lightbox.
- `gallery`: массив страниц кейса с title, image, fullImage.
- Playwright capture-script поднимает локальные проекты на фиксированных портах и сохраняет изображения в `public/cases` и `public/cases-full`.
- Lightbox берёт `fullImage`, а не preview.

## Реализация (пример)

```ts
{
  title: "Главная",
  image: "/cases/project/home.png",
  fullImage: "/cases-full/project/home.png",
}
```

```html
<button data-lightbox-src={shot.fullImage}>
  <img src={shot.image} alt={`${caseTitle}: ${shot.title}`} />
</button>
```

## Production-паттерны

- Превью оставлять стабильными `1365x768`, чтобы списки не прыгали.
- Full-page хранить отдельно; для страниц с пустым хвостом или декоративным фоном использовать viewport/section crop.
- Lightbox должен закрываться по `Esc`, фону и кнопке, а на mobile не создавать horizontal scroll.
- Добавить cache-busting plan, если имена файлов не меняются.

## Частые ошибки

- Использовать full-page изображение как preview — сетка ломается или показывает пустой участок.
- Снимать только верх страницы и обещать “полную страницу”.
- Не проверять lightbox на mobile.
- Публиковать демо-проекты как коммерческие кейсы с выдуманными результатами.

## Альтернативы

- Видео walkthrough — лучше для интерактивных продуктов, но тяжелее и хуже для SEO.
- Ссылка на live demo — полезна, но не заменяет снимок состояния проекта.
- PDF case study — подходит для продаж, но неудобен как web-gallery.

## Источники

- [Успешное решение: портфолио услуг Заявки.Site](../../case-studies/successes/2026-06-20-zayavki-site-portfolio.md)
- [Frontend review checklist](../../checklists/frontend-review.md)
- [Visual testing](../../docs/09-testing/Visual-testing.md)
