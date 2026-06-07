---
title: "Styling systems"
category: "frontend"
updated: "2026-06-07"
status: "active"
tags: ["css", "tailwind", "panda", "design-system"]
source_priority: "mixed"
---

# Styling systems

Styling system decides how tokens, layout, variants, responsive behavior and component states are expressed. It should support design quality, not just fast class writing.

Freshness note: Panda CSS watchlist refreshed to `@pandacss/dev` `1.11.3` on 2026-06-07. Guidance remains focused on build-time type-safe tokens/recipes and static atomic CSS.

## Когда использовать

- Starting a new site/app and choosing between Tailwind, CSS Modules, Panda CSS, vanilla CSS or component library styling.
- Design system needs tokens, variants, recipes and consistent responsive rules.
- Team sees palette drift, arbitrary spacing and one-off component styles.

## Когда не использовать

- Tiny prototype with no design lifecycle.
- Existing mature design system already has enforced conventions and migration would create churn.

## Production-паттерны

- Tailwind 4 is default for fast utility-first UI when tokens and component extraction are enforced.
- CSS Modules work for small/medium apps needing local scoped CSS without utility-heavy markup.
- Panda CSS fits type-safe tokens/recipes and design-system-heavy apps.
- Vanilla CSS custom properties are useful for simple static sites and framework-independent tokens.
- Styling choice documents typography scale, color tokens, spacing, radius, shadows, motion and responsive constraints.

## Частые ошибки

- Treating Tailwind as a design system by itself.
- Mixing multiple styling systems without ownership boundaries.
- Arbitrary values everywhere instead of tokens.
- No rules for long text, mobile wrapping, dark/light surfaces and media aspect ratios.

## Security risks

User-generated HTML/CSS must be sanitized. Theme editors must not allow unsafe CSS injection into public pages.

## Performance risks

Runtime CSS-in-JS can increase client cost; build-time CSS avoids that but requires deterministic generation. Large unused CSS and font/style churn affect LCP/CLS.

## Testing strategy

Visual regression for core components, contrast/a11y checks, responsive smoke, token snapshot review, Storybook states and Lighthouse for public pages.

## Edge cases

Theming, localization, high contrast mode, reduced motion, print styles, user-generated content, embedded widgets, CMS rich text.

## Источники

- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [Panda CSS Docs](https://panda-css.com/docs/overview/getting-started) — refreshed 2026-06-07.
- См. [Tailwind](Tailwind.md), [Design systems](Design-systems.md), [Component-driven development](Component-driven-development.md), [Frontend review checklist](../../checklists/frontend-review.md).
