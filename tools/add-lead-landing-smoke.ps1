param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,
    [string]$OutputPath = "tests/lead-landing.smoke.spec.ts",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path -LiteralPath $ProjectRoot).Path
$targetPath = Join-Path $rootPath $OutputPath
$targetDir = Split-Path -Parent $targetPath

if (-not (Test-Path -LiteralPath $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

if ((Test-Path -LiteralPath $targetPath) -and -not $Force) {
    throw "Smoke spec already exists: $targetPath. Use -Force to overwrite."
}

$spec = @'
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
'@

Set-Content -LiteralPath $targetPath -Value $spec -Encoding utf8
Write-Host "Created lead landing smoke spec: $targetPath"
