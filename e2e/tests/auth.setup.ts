import { test as setup, expect } from '@playwright/test';
import path from 'path';

const authFile = path.join(__dirname, '../fixtures/.auth/user.json');

/**
 * Authentication setup — runs once before all authenticated tests.
 * Saves browser storage state (cookies, localStorage) so subsequent
 * tests can skip the login flow.
 *
 * NOTE: Flutter Web CanvasKit renders into a <canvas> element.
 * We interact via the accessibility/semantics tree that Flutter exposes.
 */
setup('authenticate', async ({ page }) => {
  const email = process.env.E2E_TEST_EMAIL;
  const password = process.env.E2E_TEST_PASSWORD;

  if (!email || !password) {
    console.warn(
      '⚠️  E2E_TEST_EMAIL or E2E_TEST_PASSWORD not set. Skipping auth setup.',
    );
    // Save empty state so tests can still run (will hit auth guards)
    await page.context().storageState({ path: authFile });
    return;
  }

  await page.goto('/login');

  // Wait for Flutter to fully initialize (splash disappears)
  await page.waitForSelector('flt-glass-pane', { timeout: 30_000 });
  // Wait for the semantics tree to be ready
  await page.waitForTimeout(3000);

  // Fill login form via Flutter semantics
  const emailInput = page.getByRole('textbox', { name: /email/i });
  const passwordInput = page.getByRole('textbox', { name: /password/i });

  if (await emailInput.isVisible({ timeout: 10_000 })) {
    await emailInput.fill(email);
    await passwordInput.fill(password);

    // Submit
    const signInButton = page.getByRole('button', { name: /sign in/i });
    await signInButton.click();

    // Wait for navigation to home (discover page)
    await page.waitForURL('/', { timeout: 15_000 });
  }

  // Save authenticated state
  await page.context().storageState({ path: authFile });
});
