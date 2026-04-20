import 'package:flutter/foundation.dart';
import 'package:luxlog/core/services/seo_meta.dart';
import 'package:luxlog/core/services/seo_platform_stub.dart'
    if (dart.library.html) 'package:luxlog/core/services/seo_platform_web.dart' as platform;

class SeoService {
  static const String _siteName = 'Luxlog';
  static const String _baseUrl = 'https://luxlog.vercel.app';
  static const String _defaultDescription =
      'Nơi kể lại câu chuyện của ánh sáng. Share and discover analog photography.';

  static void applyForPath(
    String path, {
    Map<String, String> pathParameters = const {},
  }) {
    if (!kIsWeb) return;

    final normalizedPath = _normalizePath(path);
    final canonicalUrl = '$_baseUrl$normalizedPath';
    final metadata = _metadataForPath(normalizedPath, pathParameters, canonicalUrl);
    platform.applySeo(metadata);
  }

  static String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    return path.startsWith('/') ? path : '/$path';
  }

  static SeoMeta _metadataForPath(
    String path,
    Map<String, String> pathParameters,
    String canonicalUrl,
  ) {
    final isAuthOrPrivate = const {
      '/login',
      '/signup',
      '/upload',
      '/notifications',
      '/profile/edit',
    }.contains(path);

    if (path == '/') {
      return SeoMeta(
        title: '$_siteName - Film Photography Community',
        description: _defaultDescription,
        canonicalUrl: canonicalUrl,
        structuredData: const {
          '@context': 'https://schema.org',
          '@type': 'WebApplication',
          'name': 'Luxlog',
          'url': 'https://luxlog.vercel.app',
          'applicationCategory': 'Photography',
          'description':
              'Film photography community - share, discover, and curate analog photos',
        },
      );
    }

    if (path == '/explore') {
      return SeoMeta(
        title: 'Explore Film Photography | $_siteName',
        description: 'Khám phá ảnh film, photographer và xu hướng tag nổi bật trên Luxlog.',
        canonicalUrl: canonicalUrl,
      );
    }

    if (path == '/feed') {
      return SeoMeta(
        title: 'Photography Feed | $_siteName',
        description: 'Xem social feed ảnh chụp mới nhất từ cộng đồng Luxlog.',
        canonicalUrl: canonicalUrl,
      );
    }

    if (path.startsWith('/photo/')) {
      final photoId = pathParameters['photoId'] ?? path.split('/').last;
      return SeoMeta(
        title: 'Photo $photoId | $_siteName',
        description: 'Chi tiết ảnh chụp trên Luxlog: metadata, film stock, camera, comments.',
        canonicalUrl: canonicalUrl,
        ogType: 'article',
        structuredData: {
          '@context': 'https://schema.org',
          '@type': 'ImageObject',
          'name': 'Photo $photoId',
          'url': canonicalUrl,
          'description': 'Analog photo published on Luxlog.',
        },
      );
    }

    if (path.startsWith('/u/')) {
      final username = pathParameters['username'] ?? path.split('/').last;
      return SeoMeta(
        title: '$username\'s Profile | $_siteName',
        description: 'Portfolio và ảnh công khai của @$username trên Luxlog.',
        canonicalUrl: canonicalUrl,
        structuredData: {
          '@context': 'https://schema.org',
          '@type': 'ProfilePage',
          'mainEntity': {
            '@type': 'Person',
            'name': username,
            'url': canonicalUrl,
          },
        },
      );
    }

    if (path.startsWith('/p/')) {
      final slug = pathParameters['slug'] ?? path.split('/').last;
      return SeoMeta(
        title: 'Portfolio $slug | $_siteName',
        description: 'Public portfolio showcase trên Luxlog.',
        canonicalUrl: canonicalUrl,
      );
    }

    if (path.startsWith('/tag/')) {
      final tagName = pathParameters['tagName'] ?? path.split('/').last;
      return SeoMeta(
        title: '#$tagName Photos | $_siteName',
        description: 'Khám phá ảnh theo hashtag #$tagName trên Luxlog.',
        canonicalUrl: canonicalUrl,
      );
    }

    return SeoMeta(
      title: '$_siteName - Film Photography Community',
      description: _defaultDescription,
      canonicalUrl: canonicalUrl,
      noindex: isAuthOrPrivate,
    );
  }
}
