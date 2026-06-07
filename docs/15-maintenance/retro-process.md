---
title: "Retro-процесс после инцидентов и провальных релизов"
category: "maintenance"
updated: "2026-06-07"
status: "active"
tags: ["maintenance", "retro", "incident", "process"]
source_priority: "internal"
---

# Retro-процесс после инцидентов и провальных релизов

Структурированный разбор причин инцидента или неудачного релиза. Цель — извлечь action items, а не найти виноватых. Результат retro всегда попадает в `case-studies/failures/` и `lessons-learned/`.

Используй этот процесс, когда нужно превратить неудачную задачу в lesson learned: сначала доказанный failure case, затем короткое правило, checklist update и retrieval coverage для будущих похожих запросов.

## Когда использовать

- Production-инцидент: сервис упал, данные повреждены, безопасность нарушена.
- Неудачный релиз: откат, hotfix в течение 24 ч после деплоя.
- Срыв дедлайна больше чем на 30% от запланированного.
- Критический баг, найденный клиентом, а не командой.

## Когда не использовать

- Регулярные ретроспективы спринта (другой формат, другая цель).
- Мелкие задержки или незначительные баги — достаточно фиксации в lessons-learned.

## Production-паттерны

**Структура retro (blameless):**

1. **Timeline** — восстановить хронологию событий по логам, метрикам, чатам. Не "кто сделал", а "что произошло и когда".
2. **Root cause** — применить 5 Whys: спрашивать "почему?" пять раз подряд, пока не упрёшься в системную причину, а не в человеческую ошибку.
3. **Impact** — задокументировать: количество затронутых пользователей, время даунтайма, потерянные транзакции, репутационный ущерб.
4. **What went well** — зафиксировать, что помогло быстро обнаружить или ограничить инцидент (alerts, playbooks, on-call).
5. **Action items** — каждый пункт имеет: формулировку проблемы, конкретный шаг исправления, owner (имя или роль), deadline. Без owner и deadline action item не считается.

**Шаблон action item:**
```
- [ ] [Проблема]: <что нужно исправить> — owner: <имя> — deadline: <YYYY-MM-DD>
```

**Формат записи:**
- Заполнить `case-studies/failures/_template.md` сразу после retro.
- Короткий вывод на 2–3 строки добавить в `lessons-learned/`.
- Если выявился повторяемый анти-паттерн — добавить в `patterns/<area>/`.

## Частые ошибки

- **Retro без action items** — разбор ради разбора, ничего не меняется.
- **Поиск виноватых** — подавляет честное обсуждение, следующий инцидент замалчивается.
- **Retro через неделю и позже** — детали теряются, timeline размывается; оптимально в течение 24–48 ч.
- **Action items без deadline** — "сделаем когда-нибудь" = никогда.
- **Только технические action items** — если root cause в процессе (нет code review, нет staging), фиксировать процессный action item.

## Security risks

- Retro-документы могут содержать детали уязвимостей — не публиковать без sanitization.
- Timeline из логов не должен включать PII, токены, raw credentials.

## Проверка

- Action items закрыты в указанные сроки (проверять на ближайшем sprint review).
- `case-studies/failures/` пополнен записью с полным front matter.
- `lessons-learned/` содержит вывод.
- `checklists/release-readiness.md` обновлён, если инцидент обнажил пропущенный пункт.

## Edge cases

- Инцидент затронул несколько команд — retro проводится совместно, action items назначаются по команде.
- Root cause в сторонней зависимости (npm-пакет, провайдер API) — action item: пинить версию, добавить circuit breaker, найти альтернативу.
- Повторный инцидент с тем же root cause — флаг: предыдущий action item не был выполнен; escalate.

## Источники

- Принципы blameless postmortem: [Google SRE Book — Postmortem Culture](https://sre.google/sre-book/postmortem-culture/) (2016).
- Шаблоны: [case-studies/failures/_template.md](../../case-studies/failures/_template.md), [lessons-learned/_template.md](../../lessons-learned/_template.md).
- Смежные документы: [Release readiness](../../checklists/release-readiness.md), [Observability](../08-devops-deploy/Observability.md), [update-monitoring](update-monitoring.md).
