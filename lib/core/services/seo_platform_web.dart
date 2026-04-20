import 'dart:convert';
import 'dart:html' as html;

import 'package:luxlog/core/services/seo_meta.dart';

void applySeo(SeoMeta meta) {
  final document = html.document;

  document.title = meta.title;
  document.documentElement?.lang = meta.lang;

  _setNamedMeta('description', meta.description);
  _setNamedMeta('robots', meta.noindex ? 'noindex, nofollow' : 'index, follow');

  _setPropertyMeta('og:site_name', 'Luxlog');
  _setPropertyMeta('og:type', meta.ogType);
  _setPropertyMeta('og:title', meta.title);
  _setPropertyMeta('og:description', meta.description);
  _setPropertyMeta('og:url', meta.canonicalUrl);
  _setPropertyMeta('og:image', meta.ogImage);

  _setNamedMeta('twitter:card', meta.twitterCard);
  _setNamedMeta('twitter:title', meta.title);
  _setNamedMeta('twitter:description', meta.description);
  _setNamedMeta('twitter:image', meta.ogImage);

  _setCanonical(meta.canonicalUrl);
  _setStructuredData(meta.structuredData);
}

void _setNamedMeta(String name, String content) {
  final selector = 'meta[name="$name"]';
  var el = html.document.querySelector(selector) as html.MetaElement?;
  el ??= html.MetaElement()..name = name;
  el.content = content;
  if (el.parent == null) {
    html.document.head?.append(el);
  }
}

void _setPropertyMeta(String property, String content) {
  final selector = 'meta[property="$property"]';
  var el = html.document.querySelector(selector) as html.MetaElement?;
  el ??= html.MetaElement()..setAttribute('property', property);
  el.content = content;
  if (el.parent == null) {
    html.document.head?.append(el);
  }
}

void _setCanonical(String canonicalUrl) {
  const id = 'luxlog-canonical';
  var link = html.document.getElementById(id) as html.LinkElement?;
  link ??= html.LinkElement()
    ..id = id
    ..rel = 'canonical';
  link.href = canonicalUrl;
  if (link.parent == null) {
    html.document.head?.append(link);
  }
}

void _setStructuredData(Map<String, Object?>? data) {
  const id = 'luxlog-jsonld';
  final existing = html.document.getElementById(id);
  if (existing != null) {
    existing.remove();
  }

  if (data == null || data.isEmpty) {
    return;
  }

  final script = html.ScriptElement()
    ..id = id
    ..type = 'application/ld+json'
    ..text = jsonEncode(data);
  html.document.head?.append(script);
}
