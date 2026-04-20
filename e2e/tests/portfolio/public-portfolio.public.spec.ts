import { test, expect } from '@playwright/test';
import { waitForFlutterReady } from '../../fixtures/helpers';

test.describe('Public Portfolio', () => {
  test('public portfolio route is accessible without auth', async ({ page }) => {
    // Test that the route pattern works (even if slug doesn't exist)
    const response = await page.goto('/p/test-portfolio');
    await waitForFlutterReady(page);

    // Should not crash (500) — either shows content or empty state
    expect(response?.status()).toBeLessThan(500);
  });

  test('public user profile is accessible without auth', async ({ page }) => {
    const response = await page.goto('/u/testuser');
    await waitForFlutterReady(page);

    // Should not crash
    expect(response?.status()).toBeLessThan(500);
  });
});
