const SITE_URL = 'https://luxlog.vercel.app';

function getSupabaseConfig() {
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
  return { supabaseUrl, supabaseAnonKey };
}

async function supabaseSelect(pathAndQuery) {
  const { supabaseUrl, supabaseAnonKey } = getSupabaseConfig();
  if (!supabaseUrl || !supabaseAnonKey) {
    return null;
  }

  const response = await fetch(`${supabaseUrl}/rest/v1/${pathAndQuery}`, {
    headers: {
      apikey: supabaseAnonKey,
      Authorization: `Bearer ${supabaseAnonKey}`,
      Accept: 'application/json',
    },
  });

  if (!response.ok) {
    return null;
  }

  return response.json();
}

function escapeHtml(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function renderSeoHtml({ title, description, canonicalPath, ogImage, jsonLd, heading, bodyText, ogType = 'website' }) {
  const canonical = `${SITE_URL}${canonicalPath}`;
  const safeTitle = escapeHtml(title);
  const safeDescription = escapeHtml(description);
  const safeOgImage = escapeHtml(ogImage || `${SITE_URL}/images/og-default.svg`);
  const safeHeading = escapeHtml(heading || title);
  const safeBody = escapeHtml(bodyText || description);
  const jsonLdText = jsonLd ? JSON.stringify(jsonLd) : '';

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${safeTitle}</title>
    <meta name="description" content="${safeDescription}" />
    <meta name="robots" content="index,follow" />
    <link rel="canonical" href="${canonical}" />
    <meta property="og:site_name" content="Luxlog" />
    <meta property="og:type" content="${escapeHtml(ogType)}" />
    <meta property="og:title" content="${safeTitle}" />
    <meta property="og:description" content="${safeDescription}" />
    <meta property="og:url" content="${canonical}" />
    <meta property="og:image" content="${safeOgImage}" />
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:title" content="${safeTitle}" />
    <meta name="twitter:description" content="${safeDescription}" />
    <meta name="twitter:image" content="${safeOgImage}" />
    ${jsonLdText ? `<script type="application/ld+json">${jsonLdText}</script>` : ''}
  </head>
  <body>
    <main>
      <h1>${safeHeading}</h1>
      <p>${safeBody}</p>
      <a href="${canonical}">Open page</a>
    </main>
  </body>
</html>`;
}

module.exports = {
  SITE_URL,
  escapeHtml,
  getSupabaseConfig,
  renderSeoHtml,
  supabaseSelect,
};
