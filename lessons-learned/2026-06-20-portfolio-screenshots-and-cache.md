---
title: "Lesson: скриншоты портфолио требуют двух слоёв и cache policy"
category: "lesson"
updated: "2026-06-20"
status: "active"
tags: ["portfolio", "screenshots", "cache", "lightbox"]
source_priority: "internal"
date: "2026-06-20"
project_type: "landing"
---

# Lesson: скриншоты портфолио требуют двух слоёв и cache policy

## TL;DR

Для портфолио не смешивай preview и full-page screenshots. Превью должно быть компактным и стабильным, а полный просмотр должен жить отдельным файлом и иметь понятную cache policy.

## Контекст

В портфолио услуг нужно было показать локальные демо-проекты. Сначала full-page скриншоты использовались прямо в галерее, из-за чего появлялись большие разрывы, пустые страницы и тёмные хвосты.

## Что произошло

После перехода на отдельные preview и fullImage галерея стала стабильной: карточки показывают верх страницы, lightbox открывает отдельный файл. Для главной автосервиса full-page был вреден из-за длинного пустого фона, поэтому для неё закрепили viewport crop.

## Корень

Скриншот — это не один универсальный артефакт. У preview и детального просмотра разные задачи, размеры и критерии качества.

## Новое правило

Когда делаешь портфолио с кейсами → храни `image` и `fullImage` отдельно; проверяй размеры, пустые хвосты, mobile lightbox и cache-busting до деплоя.

## Применимость

Работает для лендингов, портфолио, service-site и demo-case pages. Не нужно применять, если кейсы показываются через живые embed/demo URL без локальных изображений.

## Обновлённые документы

- [patterns/frontend/portfolio-case-screenshot-gallery.md](../patterns/frontend/portfolio-case-screenshot-gallery.md) — добавлен reusable pattern.
- [checklists/frontend-review.md](../checklists/frontend-review.md) — добавлен gate по preview/fullImage и lightbox.

## Ссылки

- [Успешное решение: портфолио услуг Заявки.Site](../case-studies/successes/2026-06-20-zayavki-site-portfolio.md)
- [Pattern: Portfolio case screenshot gallery](../patterns/frontend/portfolio-case-screenshot-gallery.md)
