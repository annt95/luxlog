const { renderSeoHtml, supabaseSelect } = require('../_utils');

module.exports = async (req, res) => {
  const { username } = req.query;
  const normalizedUsername = String(username || '').trim();

  let title = `${normalizedUsername}'s Profile | Luxlog`;
  let description = `Portfolio va anh cong khai cua @${normalizedUsername} tren Luxlog.`;
  let ogImage = 'https://luxlog.vercel.app/images/og-default.svg';

  const rows = await supabaseSelect(
    `profiles?select=username,bio,avatar_url,website&username=eq.${encodeURIComponent(normalizedUsername)}&limit=1`,
  );
  const profile = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;

  if (profile) {
    title = `${profile.username}'s Profile | Luxlog`;
    description = profile.bio || description;
    ogImage = profile.avatar_url || ogImage;
  }

  const canonicalPath = `/u/${encodeURIComponent(normalizedUsername)}`;
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'ProfilePage',
    mainEntity: {
      '@type': 'Person',
      name: profile?.username || normalizedUsername,
      url: `https://luxlog.vercel.app${canonicalPath}`,
      image: ogImage,
      description,
      sameAs: profile?.website ? [profile.website] : [],
    },
  };

  const html = renderSeoHtml({
    title,
    description,
    canonicalPath,
    ogImage,
    jsonLd,
    ogType: 'profile',
    heading: title.replace(' | Luxlog', ''),
    bodyText: description,
  });

  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.status(200).send(html);
};
