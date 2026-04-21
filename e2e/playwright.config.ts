import { defineConfig, devices } from '@playwright/test';

/**
 * Luxlog E2E Test Configuration
 *
 * Flutter Web (CanvasKit) renders to <canvas>, so standard DOM selectors
 * won't work for most elements. We rely on:
 * - Accessibility tree (getByRole, getByLabel)
 * - Text content via Flutter's semantics layer (getByText)
 * - Visual regression (toHaveScreenshot) as fallback
 * - data-testid where available in Flutter semantics
 */
export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { open: 'never' }],
    ['list'],
  ],
  use: {
    baseURL: process.env.E2E_BASE_URL || 'https://luxlog.vercel.app',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
    // Flutter Web takes time to initialize (CanvasKit download + boot)
    actionTimeout: 15_000,
    navigationTimeout: 30_000,
  },
  // Give Flutter Web extra time to boot (CanvasKit + Dart VM)
  timeout: 60_000,
  expect: {
    timeout: 10_000,
  },
  projects: [
    // Setup project for authentication state
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
    },
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        // Reuse auth state from setup
        storageState: './fixtures/.auth/user.json',
      },
      dependencies: ['setup'],
    },
    {
      name: 'firefox',
      use: {
        ...devices['Desktop Firefox'],
        storageState: './fixtures/.auth/user.json',
      },
      dependencies: ['setup'],
    },
    {
      name: 'webkit',
      use: {
        ...devices['Desktop Safari'],
        storageState: './fixtures/.auth/user.json',
      },
      dependencies: ['setup'],
    },
    {
      name: 'mobile-chrome',
      use: {
        ...devices['Pixel 7'],
        storageState: './fixtures/.auth/user.json',
      },
      dependencies: ['setup'],
    },
    {
      name: 'mobile-safari',
      use: {
        ...devices['iPhone 14'],
        storageState: './fixtures/.auth/user.json',
      },
      dependencies: ['setup'],
    },
    // Tests that don't need authentication
    {
      name: 'no-auth',
      use: { ...devices['Desktop Chrome'] },
      testMatch: /.*\.(public|seo|a11y)\.spec\.ts/,
    },
  ],
});
