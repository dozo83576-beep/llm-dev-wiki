---
title: "Pattern: LocalStorage mini-CRM (клиентский CRUD без бэкенда)"
category: "pattern"
updated: "2026-06-11"
status: "active"
tags: ["frontend", "localstorage", "crud", "mvp", "static-site"]
source_priority: "internal"
area: "frontend"
date: "2026-06-11"
---

# Pattern: LocalStorage mini-CRM (клиентский CRUD без бэкенда)

## Назначение

Дать статическому сайту простую «CRM»-функциональность без сервера и БД: публичная форма создаёт
записи (заявки), отдельная служебная страница читает их, меняет статус и удаляет. Подходит для
MVP/демо/учебных проектов, где реальный backend ещё не нужен.

## Когда использовать

- Статический сайт (HTML/CSS/vanilla JS) без бэкенда, нужно «куда-то складывать» заявки локально.
- Демо/прототип/учебный проект, где данные нужны только в этом браузере.

## Когда не использовать

- Реальные, мульти-пользовательские или долговечные данные (LocalStorage привязан к одному браузеру
  и легко теряется).
- Нужны авторизация, серверная валидация, аудит, синхронизация между устройствами, защита данных →
  нужен backend. См. [server/client boundary](./server-client-boundary.md) и
  [form validation boundary](./form-validation-boundary.md).

## Структура

- **Единый ключ-контракт** — один ключ LocalStorage (напр. `requests`), общий между страницей-писателем
  (форма) и страницей-читателем (admin). Это явный контракт; задокументировать его в README.
- **Схема записи** — стабильная форма объекта, например:
  `{ id, name, phone, email, service, message, createdAt, status }`.
- **Статусы** — фиксированный перечень: `new` / `in_progress` / `done` / `canceled`.
- **Писатель** (публичная форма): валидирует UX, формирует запись со статусом `new`, добавляет в
  массив, пишет обратно.
- **Читатель** (admin): читает массив, рендерит таблицу, меняет статус, удаляет, очищает; каждое
  изменение сразу пишется обратно.
- **Кросс-вкладочная синхронизация** — слушать событие `window` `storage`, чтобы открытая в соседней
  вкладке admin-страница обновлялась автоматически.
- **Экранирование** — пользовательский текст рендерить через `textContent`/escape, не `innerHTML`.

## Реализация (пример)

```js
var KEY = 'requests';
function readAll() {
  try { return JSON.parse(localStorage.getItem(KEY)) || []; }
  catch (e) { return []; }
}
function writeAll(list) { localStorage.setItem(KEY, JSON.stringify(list)); }

function addRequest(data) {
  var list = readAll();
  list.push(Object.assign({
    id: 'req_' + Date.now().toString(36),
    createdAt: new Date().toISOString(),
    status: 'new'
  }, data));
  writeAll(list);
}

// admin: автообновление при изменении в другой вкладке
window.addEventListener('storage', function (e) {
  if (e.key === KEY) renderTable(readAll());
});
```

## Production-паттерны

- Версионировать схему (`schemaVersion`) — чтобы при изменении полей можно было мигрировать старые
  записи, а не падать.
- Оборачивать чтение/запись в `try/catch` (LocalStorage может быть недоступен/переполнен).
- Деструктивные действия (удалить, очистить) — с подтверждением.
- Чётко коммуницировать пользователю/в README: данные хранятся только в этом браузере.

## Частые ошибки

- Считать LocalStorage «безопасным хранилищем» — это публичные данные клиента, без приватности.
- Рендерить значения через `innerHTML` без экранирования → XSS.
- Нет версии схемы → ломается при первом же изменении полей.
- Полагаться на сохранность данных (чистка кэша/инкогнито их стирает).

## Альтернативы

- IndexedDB — для больших объёмов/структурированных запросов на клиенте.
- Backend + БД (или serverless endpoint + Telegram/email-уведомление) — как только данные становятся
  реальными или мульти-пользовательскими. См. [telegram lead notification](../backend/telegram-lead-notification.md).

## Источники

- Внутренний кейс: [Статический сайт автосервиса ТУРБОСЕРВИС](../../case-studies/successes/2026-06-11-turboservice-static-autoservice.md).
