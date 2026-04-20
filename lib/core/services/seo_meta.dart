class SeoMeta {
  final String title;
  final String description;
  final String canonicalUrl;
  final String ogType;
  final String ogImage;
  final String twitterCard;
  final bool noindex;
  final String lang;
  final Map<String, Object?>? structuredData;

  const SeoMeta({
    required this.title,
    required this.description,
    required this.canonicalUrl,
    this.ogType = 'website',
    this.ogImage = 'https://luxlog.vercel.app/images/og-default.svg',
    this.twitterCard = 'summary_large_image',
    this.noindex = false,
    this.lang = 'vi',
    this.structuredData,
  });
}
