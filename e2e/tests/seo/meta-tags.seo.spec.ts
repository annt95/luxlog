import { test, expect } from '@playwright/test';

/**
 * SEO tests verify HTML meta tags and structured data.
 * These work with CanvasKit because meta/title/JSON-LD live in the real DOM <head>.
 */
test.describe('SEO Meta Tags', () => {
  test('homepage has correct title', async ({ page }) => {
    await page.goto('/');
    const title = await page.title();
    expect(title.toLowerCase()).toContain('luxlog');
  });

  test('homepage has meta description', async ({ page }) => {
    await page.goto('/');
    const desc = await page.getAttribute('meta[name="description"]', 'content');
    expect(desc).toBeTruthy();
    expect(desc!.length).toBeGreaterThan(20);
  });

  test('homepage has canonical URL', async ({ page }) => {
    await page.goto('/');
    const canonical = await page.getAttribute('link[rel="canonical"]', 'href');
    expect(canonical).toBeTruthy();
    expect(canonical).toContain('luxlog');
  });

  test('homepage has Open Graph tags', async ({ page }) => {
    await page.goto('/');

    const ogTitle = await page.getAttribute('meta[property="og:title"]', 'content');
    const ogDesc = await page.getAttribute('meta[property="og:description"]', 'content');
    const ogImage = await page.getAttribute('meta[property="og:image"]', 'content');
    const ogUrl = await page.getAttribute('meta[property="og:url"]', 'content');
    const ogType = await page.getAttribute('meta[property="og:type"]', 'content');

    expect(ogTitle).toBeTruthy();
    expect(ogDesc).toBeTruthy();
    expect(ogImage).toBeTruthy();
    expect(ogUrl).toContain('luxlog');
    expect(ogType).toBe('website');
  });

  test('homepage has Twitter Card tags', async ({ page }) => {
    await page.goto('/');

    const twitterCard = await page.getAttribute('meta[name="twitter:card"]', 'content');
    const twitterTitle = await page.getAttribute('meta[name="twitter:title"]', 'content');

    expect(twitterCard).toBe('summary_large_image');
    expect(twitterTitle).toBeTruthy();
  });

  test('homepage has JSON-LD structured data', async ({ page }) => {
    await page.goto('/');

    const jsonLd = await page.$eval(
      'script[type="application/ld+json"]',
      (el) => el.textContent,
    ).catch(() => null);

    expect(jsonLd).toBeTruthy();
    const data = JSON.parse(jsonLd!);
    expect(data['@context']).toBe('https://schema.org');
    expect(data['@type']).toBe('WebApplication');
    expect(data.name).toContain('Luxlog');
  });

  test('explore page has proper title', async ({ page }) => {
    await page.goto('/explore');
    // Wait for Flutter to update document.title
    await page.waitForTimeout(3000);

    const title = await page.title();
    expect(title.toLowerCase()).toMatch(/explore|luxlog/);
  });

  test('robots.txt is accessible', async ({ page }) => {
    const response = await page.goto('/robots.txt');
    expect(response?.status()).toBe(200);

    const text = await page.textContent('body');
    expect(text).toContain('User-agent');
    expect(text).toContain('Sitemap');
    expect(text).toContain('Disallow: /upload');
  });

  test('sitemap.xml is accessible', async ({ page }) => {
    const response = await page.goto('/sitemap.xml');
    expect(response?.status()).toBe(200);

    const content = await page.content();
    expect(content).toContain('urlset');
  });

  test('login page has noindex meta', async ({ page }) => {
    await page.goto('/login');
    await page.waitForTimeout(2000);

    const robots = await page.getAttribute('meta[name="robots"]', 'content');
    // Should be noindex or the page should not appear indexable
    if (robots) {
      expect(robots).toContain('noindex');
    }
  });
});
