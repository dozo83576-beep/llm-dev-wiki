# Frontend review checklist

- [ ] Нет необоснованного переноса страницы в client-only режим.
- [ ] Формы имеют loading, error, success и disabled states.
- [ ] Валидация есть на клиенте и сервере.
- [ ] Текст не выходит за контейнеры на mobile/desktop.
- [ ] Компоненты имеют доступные labels, roles и focus states.
- [ ] Критичные сценарии покрыты Playwright или ручным smoke.
- [ ] Bundle не содержит тяжелых библиотек без причины.
- [ ] Нет секретов в client bundle.

