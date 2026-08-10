---
name: site-frontend
description: Frontend-фаза только внутри полного маршрута D:\Work или при явном вызове; не активируется на обычную React, CSS или компонентную правку.
---

# Site frontend

Входы: архитектура, content model, design direction, backend contracts и существующие соглашения проекта.

Реализуй интерфейс нативно и без несогласованных замен стека. Сохраняй семантику, responsive-поведение, keyboard/focus, loading/empty/error/success states и серверные границы.

Hero video подключай только из проверенного `media-manifest.json`: декоративное видео без audio,
с poster/pause/reduced-motion/save-data fallback; смысловое — с controls, captions и transcript.
Не встраивай Remotion Player вместо предварительно отрендерованного hero без отдельной причины.

Визуальное совпадение, browser behavior и интеграции подтверждаются выполнением в реальной среде; статического чтения кода для этого недостаточно. Применяй инструмент только к конкретной проверке.

В `_frontend-smoke.md` запиши маршруты, viewport/среду, проверенные сценарии, результаты build/test и ссылки на evidence. Не используй реальные ПДн или секреты в fixtures и снимках.
