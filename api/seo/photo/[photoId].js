const { renderSeoHtml, supabaseSelect } = require('../_utils');

module.exports = async (req, res) => {
  const { photoId } = req.query;
  const normalizedPhotoId = String(photoId || '').trim();

  let title = `Photo ${normalizedPhotoId} | Luxlog`;
  let description = 'Chi tiet anh chup tren Luxlog: metadata, film stock, camera, comments.';
  let ogImage = 'https://luxlog.vercel.app/icons/Icon-512.png';

  const rows = await supabaseSelect(
    `photos?select=id,title,caption,image_url,created_at,is_public,user_id&id=eq.${encodeURIComponent(
      normalizedPhotoId,
    )}&is_public=eq.true&limit=1`,
  );

  const photo = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;

  if (photo) {
    const photoTitle = photo.title || `Photo ${photo.id}`;
    title = `${photoTitle} | Luxlog`;
    description = photo.caption || 'Analog photo published on Luxlog.';
    ogImage = photo.image_url || ogImage;
  }

  const canonicalPath = `/photo/${encodeURIComponent(normalizedPhotoId)}`;
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'ImageObject',
    name: title.replace(' | Luxlog', ''),
    description,
    contentUrl: ogImage,
    url: `https://luxlog.vercel.app${canonicalPath}`,
  };

  const html = renderSeoHtml({
    title,
    description,
    canonicalPath,
    ogImage,
    jsonLd,
    heading: title.replace(' | Luxlog', ''),
    bodyText: description,
  });

  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.status(200).send(html);
};
