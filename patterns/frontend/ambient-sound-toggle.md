---
title: "Pattern: Тумблер ambient-звука (опциональный, real audio)"
category: "patterns"
updated: "2026-06-23"
status: "active"
tags: ["frontend", "audio", "ux", "accessibility", "licensing"]
source_priority: "internal"
area: "frontend"
date: "2026-06-23"
---

# Тумблер ambient-звука (опциональный, real audio)

## Назначение

Атмосферный звук (мурчание кошки, шум кофейни, камин) усиливает вайб сайта,
но звук без спроса раздражает и нарушает автоплей-политику браузеров. Паттерн
даёт ненавязчивый, доступный и юридически чистый тумблер.

## Когда использовать

- Нишевый бренд-сайт, где звук — часть атмосферы (кото-кафе, спа, бар).
- Нужен реальный звук (запись), а не синтез — синтезированный тон звучит
  дёшево и «не по-настоящему».

## Production-паттерны

- **Off by default, только по клику.** Никакого автоплея; браузеры всё равно
  заблокируют `audio.play()` без жеста пользователя.
- **Реальная запись + self-host.** Бери файл с чистой лицензией (public domain
  / CC0 — напр. Wikimedia Commons), клади в `public/audio/`, не хотлинкай.
  Указывай источник и лицензию в коммите/handoff.
- **Мягкий fade in/out** по громкости (interval по 40ms) вместо резкого старта;
  комфортный целевой уровень (~0.5), `loop`.
- **Деградация по кодеку.** `.oga/.ogg` не играет в iOS Safari. Проверяй
  `audio.canPlayType('audio/ogg')` и **прячь кнопку**, если не поддержано, —
  не обманывай пользователя «мёртвым» тумблером. Для полного охвата добавь
  второй `<source>` mp3.
- **Доступность.** `aria-pressed` на кнопке, понятные подписи вкл/выкл,
  `preload="none"` чтобы не тянуть аудио до клика.

## Реализация (суть)

```js
const audio = document.getElementById('purr-audio');     // <audio loop preload=none>
if (!audio.canPlayType('audio/ogg')) btn.style.display = 'none';
btn.addEventListener('click', async () => {
  on = !on; btn.setAttribute('aria-pressed', String(on));
  if (on) { audio.volume = 0; await audio.play(); fadeTo(0.5); }
  else fadeTo(0, () => audio.pause());
});
```

## Частые ошибки

- Автоплей или звук на каждый ховер.
- Синтез осциллятором вместо записи там, где обещан «настоящий» звук.
- Один `.ogg` без проверки кодека → iOS-кнопка молча не работает.
- Хотлинк аудио с чужого сайта / без проверки лицензии.

## Связано

- [Pattern: purposeful motion](purposeful-motion.md)
- [docs/02-frontend/Performance.md](../../docs/02-frontend/Performance.md)
