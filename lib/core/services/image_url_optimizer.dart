/// Whether Supabase Image Transformations is available (Pro plan feature).
/// Set to true once the project is on a plan that supports /render/image/.
const _imageTransformsEnabled = false;

String optimizeImageUrl(
  String url, {
  int? width,
  int? height,
  int quality = 75,
}) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return trimmed;

  // Image Transforms disabled — return original URL to avoid 400 errors.
  if (!_imageTransformsEnabled) return trimmed;

  Uri uri;
  try {
    uri = Uri.parse(trimmed);
  } catch (_) {
    return trimmed;
  }

  final marker = '/storage/v1/object/public/';
  final path = uri.path;
  final markerIndex = path.indexOf(marker);
  if (markerIndex == -1) {
    return trimmed;
  }

  final publicObjectPath = path.substring(markerIndex + marker.length);
  final renderPath = '/storage/v1/render/image/public/$publicObjectPath';

  final params = <String, String>{...uri.queryParameters};
  if (width != null && width > 0) {
    params['width'] = width.toString();
  }
  if (height != null && height > 0) {
    params['height'] = height.toString();
  }
  if (quality > 0 && quality <= 100) {
    params['quality'] = quality.toString();
  }

  return uri.replace(path: renderPath, queryParameters: params).toString();
}
