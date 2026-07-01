---
title: "Lead landing Playwright smoke"
category: "testing"
updated: "2026-06-29"
status: "active"
tags: ["playwright", "landing", "viewport", "lead-generation", "visual-testing"]
source_priority: "internal"
---

# Lead landing Playwright smoke

Шаблон для быстрых проверок lead-generation лендинга с экранными секциями, каталогом, калькулятором, FAQ и fixed CTA/квизом. Его цель — поймать визуальные дефекты, которые не видны в unit-тестах: обрезанные формы, перекрытые кнопки, пустые grid-зоны и секции, не помещающиеся в экран.

## Когда использовать

- Есть правило "один смысловой блок на экран".
- На странице есть fixed header, floating CTA или квиз.
- Есть длинные блоки: каталог, калькулятор, FAQ, контакты.
- Визуальный reference нужно проверять не только скриншотом, но и DOM-метриками.

## Когда не использовать

- Простая статическая страница без fixed UI, каталога, калькулятора и экранных ограничений.
- Проект уже покрыт более точным E2E-smoke с теми же viewport и overlap-проверками.

## Быстрая установка

Из корня `llm-dev-wiki`:

```powershell
pwsh tools/add-lead-landing-smoke.ps1 -ProjectRoot D:\Work\my-site
pwsh tools/add-layout-consistency-smoke.ps1 -ProjectRoot D:\Work\my-site
```

Скрипты создадут `tests/lead-landing.smoke.spec.ts` и `tests/layout-consistency.smoke.spec.ts`; существующие файлы не перезаписываются без `-Force`.

## Минимальный spec

Если скрипт недоступен, скопируй в проект как `tests/lead-landing.smoke.spec.ts` и адаптируй селекторы под реальные `id` секций.

```ts
import { expect, test } from "@playwright/test";

const desktop = { width: 1183, height: 920 };
const wide = { width: 1920, height: 920 };
const mobile = { width: 390, height: 900 };

async function sectionBox(page: import("@playwright/test").Page, selector: string) {
  return page.locator(selector).evaluate((node) => {
    const rect = node.getBoundingClientRect();
    return {
      top: rect.top,
      bottom: rect.bottom,
      height: rect.height,
      scrollHeight: (node as HTMLElement).scrollHeight,
      clientHeight: (node as HTMLElement).clientHeight,
    };
  });
}

async function expectVisibleInViewport(page: import("@playwright/test").Page, selector: string) {
  const box = await page.locator(selector).boundingBox();
  expect(box, `${selector} must exist`).not.toBeNull();
  const viewport = page.viewportSize();
  expect(viewport).not.toBeNull();
  expect(box!.y).toBeGreaterThanOrEqual(0);
  expect(box!.y + box!.height).toBeLessThanOrEqual(viewport!.height);
}

test.describe("lead landing viewport smoke", () => {
  test("hero fits desktop viewport and does not show accidental next-section tail", async ({ page }) => {
    await page.setViewportSize(desktop);
    await page.goto("/");

    await expect(page.locator("header")).toBeVisible();
    await expect(page.locator("#hero")).toBeVisible();

    const hero = await sectionBox(page, "#hero");
    expect(hero.bottom).toBeLessThanOrEqual(desktop.height + 2);
  });

  test("calculator shows form, result CTA and disclaimer without clipping", async ({ page }) => {
    await page.setViewportSize(wide);
    await page.goto("/#calculator");

    await expect(page.locator("#calculator")).toBeVisible();
    await expectVisibleInViewport(page, "#calculator button, #calculator [role='button']");
    await expect(page.locator("#calculator").getByText(/предварительн/i)).toBeVisible();
  });

  test("FAQ uses bounded scroll instead of stretching page", async ({ page }) => {
    await page.setViewportSize(desktop);
    await page.goto("/#faq");

    const faq = await sectionBox(page, "#faq");
    expect(faq.height).toBeLessThanOrEqual(desktop.height);
  });

  test("catalog categories do not leave empty grid space", async ({ page }) => {
    await page.setViewportSize(wide);
    await page.goto("/#equipment");

    await page.getByRole("button", { name: /экскаваторы|самосвалы|автокраны/i }).first().click();
    const cards = page.locator("#equipment article");
    await expect(cards).toHaveCount(2);
    await expect(cards.first().locator("img")).toBeVisible();
  });

  test("floating CTA does not cover the last calculator control", async ({ page }) => {
    await page.setViewportSize(desktop);
    await page.goto("/#calculator");

    const cta = await page.locator("body > button:visible").last().boundingBox();
    const lastControl = await page.locator("#calculator input, #calculator button, #calculator select").last().boundingBox();

    if (cta && lastControl) {
      const overlap =
        cta.x < lastControl.x + lastControl.width &&
        cta.x + cta.width > lastControl.x &&
        cta.y < lastControl.y + lastControl.height &&
        cta.y + cta.height > lastControl.y;

      expect(overlap).toBe(false);
    }
  });

  test("mobile first viewport keeps headline and primary CTA visible", async ({ page }) => {
    await page.setViewportSize(mobile);
    await page.goto("/");

    await expectVisibleInViewport(page, "h1");
    await expect(page.getByRole("link", { name: /рассчитать|заявк|подобрать/i }).first()).toBeVisible();
  });
});
```

## Что адаптировать

- `#hero`, `#equipment`, `#calculator`, `#faq` — реальные id секций.
- Selector floating CTA, если кнопка не является прямым потомком `body`.
- Категории каталога и ожидаемое число карточек.
- Текстовые matchers под язык проекта.

## Обязательные проверки

- Hero полностью помещается в desktop viewport и не показывает случайный хвост следующего блока.
- Calculator показывает последнюю опцию, CTA результата и disclaimer без прокрутки страницы на desktop.
- FAQ имеет bounded internal scroll, если вопросов больше высоты экрана.
- Категории каталога с 1-2 карточками растягивают карточки, а не оставляют пустой фон.
- Floating CTA/quiz не перекрывает форму, нижние controls и disclaimer.
- Mobile first viewport показывает H1 и главный CTA без наложений.
- Layout consistency smoke проверяет отсутствие horizontal overflow и единые боковые gutters у content containers.

## Production-паттерны

- Запускать smoke после dev-server или staging deploy, а не только на статическом HTML, если проект использует Next.js routing.
- Сохранять screenshots только для спорных визуальных состояний; DOM-метрики должны быть главным gate для "поместилось в экран".
- Добавлять `scroll-margin-top` на якорные секции до проверки `/#calculator`, `/#faq`, `/#contacts`.

## Частые ошибки

- Запустить тест без адаптации селекторов и получить ложный красный результат.
- Проверять только wide desktop и пропустить viewport `1183x920`, где чаще всплывает обрезка.
- Оставить floating CTA поверх последнего input/checkbox и считать блок видимым по скриншоту.

## Проверка

- `pwsh tools/add-lead-landing-smoke.ps1 -ProjectRoot <project>` создает spec и не перезаписывает файл без `-Force`.
- `pwsh tools/add-layout-consistency-smoke.ps1 -ProjectRoot <project>` создает spec проверки ширины и отступов.
- `npx playwright test tests/lead-landing.smoke.spec.ts` проходит на локальном dev URL после адаптации селекторов.
- `npx playwright test tests/layout-consistency.smoke.spec.ts` проходит без horizontal overflow и gutter-разброса.
- При fixed header переходы на hash routes открывают секции без перекрытия шапкой.

## Источники

- Связано: [Playwright](Playwright.md), [Visual testing](Visual-testing.md), [screen-section lead landing](../../patterns/frontend/screen-section-lead-landing.md), [Frontend review checklist](../../checklists/frontend-review.md).
