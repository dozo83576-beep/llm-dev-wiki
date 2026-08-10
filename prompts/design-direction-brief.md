---
title: "Prompt: design direction brief"
category: "prompt"
updated: "2026-08-10"
status: "active"
tags: ["design", "landing", "brief", "anti-ai-slop"]
source_priority: "internal"
---

# Design direction brief

Используй для крупной design-фазы или когда пользователь явно просит создать либо зафиксировать направление.
Локальная правка может идти `direct` без отдельного артефакта.

## Входы

- surface: marketing / product / content / experience;
- аудитория, задача и целевое действие;
- brand system, существующий UI и то, что нельзя менять;
- реальный контент и assets либо честно обозначенные пробелы;
- предоставленные референсы и локальные preferences.

Если критичный выбор нельзя вывести из контекста, задай один короткий вопрос. В остальных случаях
сформулируй одно обоснованное направление. Несколько вариантов нужны только при материальной
неопределённости, которую должен разрешить пользователь.

Внешний поиск выполняй только когда нужны актуальные референсы, конкурентное evidence, лицензии или
доступность шрифтов/assets. Не выдавай модельное знание за проверенный внешний факт.

## Артефакт `DESIGN-DIRECTION.md`

```markdown
# Design direction

## Context
- Surface:
- Audience and task:
- Brand constraints:
- Preserved incumbent system:

## Direction
- Rationale:
- Visual variance: restrained | balanced | expressive
- Information density: spacious | balanced | dense
- Motion budget: static | functional | expressive
- Motion purpose and interaction tier: base | cinematic | specialized
- Hero media purpose: none | decorative | meaningful | synchronized
- Playback, pause, poster, reduced-motion and save-data behavior:
- Asset provenance and optional `hero-media-brief.json`:
- Typography and licensing:
- Palette and surface tokens:
- Spacing, layout and image language:

## Components and states
- Key components:
- Loading / empty / error / success / disabled / focus where applicable:

## Responsive and accessibility
- Desktop/mobile behavior:
- Contrast, keyboard, reduced motion and content overflow:

## Evidence and acceptance
- References and assets:
- Visual acceptance criteria:
- Unknowns requiring an external tool or user input:
```

Не выдумывай кейсы, цифры, отзывы, лицензии или подтверждение браузерной проверки. Пользовательские
вкусы применяй как preference layer: project brief, бренд и accessibility имеют приоритет.

## Связанное

- [Contextual anti-AI-slop design](../patterns/frontend/anti-ai-slop-design.md)
- [Design inspiration](../resources/design-inspiration.md)
- [Typography fonts](../docs/02-frontend/Typography-fonts.md)
- [External design skills and tools](../docs/07-mcp-and-ai-tools/External-design-skills.md)
