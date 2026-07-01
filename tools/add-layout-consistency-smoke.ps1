param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,
    [string]$OutputPath = "tests/layout-consistency.smoke.spec.ts",
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
    throw "Layout consistency smoke spec already exists: $targetPath. Use -Force to overwrite."
}

$spec = @'
import { expect, test } from "@playwright/test";

const viewports = [
  { name: "desktop", size: { width: 1183, height: 920 }, tolerance: 4 },
  { name: "wide", size: { width: 1920, height: 920 }, tolerance: 4 },
  { name: "mobile", size: { width: 390, height: 900 }, tolerance: 2 },
];

const sectionSelectors = [
  "#hero",
  "#equipment",
  "#calculator",
  "#deal-flow",
  "#advantages",
  "#offers",
  "#faq",
  "#contacts",
];

const contentSelector = [
  "header .mx-auto",
  "footer .mx-auto",
  "section > .mx-auto",
  "#hero .mx-auto",
].join(", ");

type Box = {
  selector: string;
  left: number;
  right: number;
  width: number;
};

async function boxes(page: import("@playwright/test").Page, selector: string): Promise<Box[]> {
  return page.locator(selector).evaluateAll((nodes, sourceSelector) =>
    nodes
      .map((node) => {
        const rect = node.getBoundingClientRect();
        return {
          selector: sourceSelector as string,
          left: rect.left,
          right: rect.right,
          width: rect.width,
        };
      })
      .filter((rect) => rect.width > 0)
  );
}

function expectInsideViewport(rect: Box, viewportWidth: number, label: string) {
  expect(rect.left, `${label} left overflow`).toBeGreaterThanOrEqual(-2);
  expect(rect.right, `${label} right overflow`).toBeLessThanOrEqual(viewportWidth + 2);
}

test.describe("layout consistency smoke", () => {
  for (const viewport of viewports) {
    test(`${viewport.name}: no horizontal overflow`, async ({ page }) => {
      await page.setViewportSize(viewport.size);
      await page.goto("/");

      const metrics = await page.evaluate(() => ({
        scrollWidth: document.documentElement.scrollWidth,
        bodyScrollWidth: document.body.scrollWidth,
        viewportWidth: window.innerWidth,
      }));

      expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.viewportWidth + 2);
      expect(metrics.bodyScrollWidth).toBeLessThanOrEqual(metrics.viewportWidth + 2);
    });

    test(`${viewport.name}: sections stay inside viewport`, async ({ page }) => {
      await page.setViewportSize(viewport.size);
      await page.goto("/");

      for (const selector of sectionSelectors) {
        const locator = page.locator(selector);
        if ((await locator.count()) === 0) continue;
        const rects = await boxes(page, selector);
        for (const rect of rects) {
          expectInsideViewport(rect, viewport.size.width, selector);
        }
      }
    });

    test(`${viewport.name}: content gutters are consistent`, async ({ page }) => {
      await page.setViewportSize(viewport.size);
      await page.goto("/");

      const rects = (await boxes(page, contentSelector)).filter(
        (rect) => rect.width >= Math.min(320, viewport.size.width - 32)
      );
      expect(rects.length, "content containers found").toBeGreaterThan(2);

      const lefts = rects.map((rect) => Math.round(rect.left));
      const rights = rects.map((rect) => Math.round(viewport.size.width - rect.right));
      const minLeft = Math.min(...lefts);
      const maxLeft = Math.max(...lefts);
      const minRight = Math.min(...rights);
      const maxRight = Math.max(...rights);

      expect(maxLeft - minLeft, `left gutters: ${lefts.join(", ")}`).toBeLessThanOrEqual(viewport.tolerance);
      expect(maxRight - minRight, `right gutters: ${rights.join(", ")}`).toBeLessThanOrEqual(viewport.tolerance);
    });

    test(`${viewport.name}: cards and forms do not exceed viewport`, async ({ page }) => {
      await page.setViewportSize(viewport.size);
      await page.goto("/");

      const rects = await boxes(page, "article, form, details, [role='dialog']");
      for (const rect of rects) {
        expectInsideViewport(rect, viewport.size.width, rect.selector);
      }
    });
  }
});
'@

Set-Content -LiteralPath $targetPath -Value $spec -Encoding utf8
Write-Host "Created layout consistency smoke spec: $targetPath"
