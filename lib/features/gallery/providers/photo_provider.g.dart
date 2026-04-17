// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$photoRepositoryHash() => r'c4c3179a51edf54d5489c4b5378c37f35f090feb';

/// See also [photoRepository].
@ProviderFor(photoRepository)
final photoRepositoryProvider = AutoDisposeProvider<PhotoRepository>.internal(
  photoRepository,
  name: r'photoRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$photoRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PhotoRepositoryRef = AutoDisposeProviderRef<PhotoRepository>;
String _$photoFeedHash() => r'cce10f374ab1dc5fb4223377874da12296e939ca';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [photoFeed].
@ProviderFor(photoFeed)
const photoFeedProvider = PhotoFeedFamily();

/// See also [photoFeed].
class PhotoFeedFamily extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [photoFeed].
  const PhotoFeedFamily();

  /// See also [photoFeed].
  PhotoFeedProvider call({int page = 0, int limit = 20, String? tab}) {
    return PhotoFeedProvider(page: page, limit: limit, tab: tab);
  }

  @override
  PhotoFeedProvider getProviderOverride(covariant PhotoFeedProvider provider) {
    return call(page: provider.page, limit: provider.limit, tab: provider.tab);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'photoFeedProvider';
}

/// See also [photoFeed].
class PhotoFeedProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [photoFeed].
  PhotoFeedProvider({int page = 0, int limit = 20, String? tab})
    : this._internal(
        (ref) =>
            photoFeed(ref as PhotoFeedRef, page: page, limit: limit, tab: tab),
        from: photoFeedProvider,
        name: r'photoFeedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$photoFeedHash,
        dependencies: PhotoFeedFamily._dependencies,
        allTransitiveDependencies: PhotoFeedFamily._allTransitiveDependencies,
        page: page,
        limit: limit,
        tab: tab,
      );

  PhotoFeedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
    required this.limit,
    required this.tab,
  }) : super.internal();

  final int page;
  final int limit;
  final String? tab;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(PhotoFeedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PhotoFeedProvider._internal(
        (ref) => create(ref as PhotoFeedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
        limit: limit,
        tab: tab,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _PhotoFeedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PhotoFeedProvider &&
        other.page == page &&
        other.limit == limit &&
        other.tab == tab;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, tab.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PhotoFeedRef on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `page` of this provider.
  int get page;

  /// The parameter `limit` of this provider.
  int get limit;

  /// The parameter `tab` of this provider.
  String? get tab;
}

class _PhotoFeedProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with PhotoFeedRef {
  _PhotoFeedProviderElement(super.provider);

  @override
  int get page => (origin as PhotoFeedProvider).page;
  @override
  int get limit => (origin as PhotoFeedProvider).limit;
  @override
  String? get tab => (origin as PhotoFeedProvider).tab;
}

String _$photoDetailHash() => r'7faf1b01efcc795228b196ae0491fb452e21d15b';

/// See also [photoDetail].
@ProviderFor(photoDetail)
const photoDetailProvider = PhotoDetailFamily();

/// See also [photoDetail].
class PhotoDetailFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [photoDetail].
  const PhotoDetailFamily();

  /// See also [photoDetail].
  PhotoDetailProvider call(String photoId) {
    return PhotoDetailProvider(photoId);
  }

  @override
  PhotoDetailProvider getProviderOverride(
    covariant PhotoDetailProvider provider,
  ) {
    return call(provider.photoId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'photoDetailProvider';
}

/// See also [photoDetail].
class PhotoDetailProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [photoDetail].
  PhotoDetailProvider(String photoId)
    : this._internal(
        (ref) => photoDetail(ref as PhotoDetailRef, photoId),
        from: photoDetailProvider,
        name: r'photoDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$photoDetailHash,
        dependencies: PhotoDetailFamily._dependencies,
        allTransitiveDependencies: PhotoDetailFamily._allTransitiveDependencies,
        photoId: photoId,
      );

  PhotoDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.photoId,
  }) : super.internal();

  final String photoId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(PhotoDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PhotoDetailProvider._internal(
        (ref) => create(ref as PhotoDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        photoId: photoId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _PhotoDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PhotoDetailProvider && other.photoId == photoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, photoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PhotoDetailRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `photoId` of this provider.
  String get photoId;
}

class _PhotoDetailProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with PhotoDetailRef {
  _PhotoDetailProviderElement(super.provider);

  @override
  String get photoId => (origin as PhotoDetailProvider).photoId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
