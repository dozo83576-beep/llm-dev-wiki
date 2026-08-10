---
name: site-design
description: Дизайн-фаза только внутри полного маршрута D:\Work или при явном вызове; не активируется на любую frontend/UI задачу.
---

# Site design

Входы: discovery, конкурентный evidence, content model, project/brand constraints и
`AGENT-PREFERENCES.local.md`, если он доступен. Project brief, бренд и accessibility выше preferences.

Нативно выбери одно обоснованное направление и проработай ключевые поверхности. Несколько направлений нужны только при реальной неопределённости, влияющей на решение пользователя.

Локальные gates:

- направление связано с аудиторией и задачей, а не с модой;
- типографика поддерживает кириллицу и имеет допустимую лицензию;
- цвета, состояния, responsive-поведение, accessibility и motion описаны проверяемо;
- qualitative axes `visual variance`, `information density` и `motion budget` следуют задаче;
- interaction tier и hero media выбираются по назначению, а не для обязательного wow-эффекта;
- референсы служат evidence, но не копируются;
- реальные пользовательские данные и секреты не входят в макеты.

Сохрани `DESIGN-DIRECTION.md`: surface, аудитория, brand constraints, направление, tokens,
qualitative axes, компоненты/состояния, responsive и визуальные acceptance criteria. При наличии
hero media укажи purpose, interaction tier, fallback/reduced-motion, controls, provenance и acceptance;
для full-pipeline подготовь вспомогательный `hero-media-brief.json`. В direct такой brief создаёт
нативная модель без запуска phase skill. Реализация может начаться после подтверждения направления,
если оно требовалось пользователем.
