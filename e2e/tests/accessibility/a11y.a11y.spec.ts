import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

/**
 * Accessibility tests using axe-core.
 *
 * NOTE: Flutter Web (CanvasKit) has limited DOM accessibility.
 * Flutter provides a semantics tree that maps to ARIA attributes,
 * but axe-core may report false positives on the <canvas> element.
 * We focus on the HTML shell and critical interactive elements.
 */
test.describe('Accessibility', () => {
  test('homepage has no critical a11y violations in HTML shell', async ({ page }) => {
    await page.goto('/');
    // Wait for page to fully load
    await page.waitForTimeout(5000);

    const results = await new AxeBuilder({ page })
      .include('head')
      .include('body')
      // Exclude the Flutter canvas area (not standard DOM)
      .exclude('flt-glass-pane')
      .exclude('canvas')
      .analyze();

    // Only fail on critical/serious violations
    const critical = results.violations.filter(
      (v) => v.impact === 'critical' || v.impact === 'serious',
    );

    expect(critical).toHaveLength(0);
  });

  test('login page has accessible form labels', async ({ page }) => {
    await page.goto('/login');
    await page.waitForTimeout(5000);

    const results = await new AxeBuilder({ page })
      .exclude('flt-glass-pane')
      .exclude('canvas')
      .analyze();

    const critical = results.violations.filter((v) => v.impact === 'critical');
    expect(critical).toHaveLength(0);
  });

  test('page has lang attribute', async ({ page }) => {
    await page.goto('/');

    const lang = await page.getAttribute('html', 'lang');
    expect(lang).toBeTruthy();
    expect(lang!.length).toBeGreaterThanOrEqual(2);
  });

  test('page has viewport meta for responsive design', async ({ page }) => {
    await page.goto('/');

    const viewport = await page.getAttribute('meta[name="viewport"]', 'content');
    expect(viewport).toBeTruthy();
    expect(viewport).toContain('width=device-width');
  });

  test('images in HTML (non-canvas) have alt text', async ({ page }) => {
    await page.goto('/');
    await page.waitForTimeout(3000);

    // Check only HTML img elements (not Flutter canvas-rendered images)
    const imgsWithoutAlt = await page.$$eval(
      'img:not([alt])',
      (imgs) => imgs.map((img) => img.getAttribute('src')),
    );

    // All HTML images should have alt text
    expect(imgsWithoutAlt).toHaveLength(0);
  });
});
