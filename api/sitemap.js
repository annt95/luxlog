const { SITE_URL, supabaseSelect } = require('./seo/_utils');

function buildUrl(path, changefreq, priority) {
  return `<url><loc>${SITE_URL}${path}</loc><changefreq>${changefreq}</changefreq><priority>${priority}</priority></url>`;
}

module.exports = async (req, res) => {
  const staticUrls = [
    buildUrl('/', 'daily', '1.0'),
    buildUrl('/explore', 'daily', '0.9'),
    buildUrl('/feed', 'hourly', '0.8'),
    buildUrl('/portfolio', 'daily', '0.7'),
  ];

  const [profiles, portfolios, tags, photos] = await Promise.all([
    supabaseSelect('profiles?select=username&order=created_at.desc&limit=200'),
    supabaseSelect('portfolios?select=slug,is_public&is_public=eq.true&order=created_at.desc&limit=200'),
    supabaseSelect('tags?select=name&order=usage_count.desc&limit=100'),
    supabaseSelect('photos?select=id,is_public&is_public=eq.true&order=created_at.desc&limit=200'),
  ]);

  const profileUrls = (Array.isArray(profiles) ? profiles : [])
    .filter((row) => row?.username)
    .map((row) => buildUrl(`/u/${encodeURIComponent(row.username)}`, 'daily', '0.7'));

  const portfolioUrls = (Array.isArray(portfolios) ? portfolios : [])
    .filter((row) => row?.slug)
    .map((row) => buildUrl(`/p/${encodeURIComponent(row.slug)}`, 'weekly', '0.7'));

  const tagUrls = (Array.isArray(tags) ? tags : [])
    .filter((row) => row?.name)
    .map((row) => buildUrl(`/tag/${encodeURIComponent(row.name)}`, 'daily', '0.6'));

  const photoUrls = (Array.isArray(photos) ? photos : [])
    .filter((row) => row?.id)
    .map((row) => buildUrl(`/photo/${encodeURIComponent(row.id)}`, 'weekly', '0.6'));

  const body = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${[
    ...staticUrls,
    ...profileUrls,
    ...portfolioUrls,
    ...tagUrls,
    ...photoUrls,
  ].join('\n')}\n</urlset>`;

  res.setHeader('Content-Type', 'application/xml; charset=utf-8');
  res.status(200).send(body);
};
