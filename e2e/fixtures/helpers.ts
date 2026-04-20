import { Page } from '@playwright/test';

/**
 * Helper to wait for Flutter Web (CanvasKit) to fully initialize.
 * The splash screen disappears and the semantics tree becomes available.
 */
export async function waitForFlutterReady(page: Page): Promise<void> {
  // Wait for the Flutter glass pane to appear
  await page.waitForSelector('flt-glass-pane', { timeout: 30_000 });

  // Wait for splash to disappear (the branded HTML splash has id="splash")
  await page.waitForFunction(
    () => {
      const splash = document.getElementById('splash');
      return !splash || splash.style.display === 'none' || splash.style.opacity === '0';
    },
    { timeout: 20_000 },
  );

  // Give Flutter a moment to render first frame and enable semantics
  await page.waitForTimeout(2000);
}

/**
 * Get text content from Flutter's semantics tree.
 * Flutter Web exposes semantics as aria-label attributes on elements
 * inside the flt-semantics container.
 */
export async function getFlutterText(page: Page, text: string) {
  return page.getByText(text, { exact: false });
}

/**
 * Navigate via Flutter's bottom navigation bar.
 * Tabs are: Discover (home), Feed, Explore, Profile
 */
export async function navigateToTab(page: Page, tabName: string): Promise<void> {
  const tab = page.getByRole('tab', { name: new RegExp(tabName, 'i') });
  if (await tab.isVisible({ timeout: 5000 })) {
    await tab.click();
    await page.waitForTimeout(1000);
  }
}
