// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tagRepositoryHash() => r'5fe931020d8ebeba1008ad6d27397b5d5f8d714f';

/// See also [tagRepository].
@ProviderFor(tagRepository)
final tagRepositoryProvider = AutoDisposeProvider<TagRepository>.internal(
  tagRepository,
  name: r'tagRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tagRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TagRepositoryRef = AutoDisposeProviderRef<TagRepository>;
String _$searchTagsHash() => r'cc9d09c4a15eb7126b6f25fadafd9c01c89e73a0';

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

/// See also [searchTags].
@ProviderFor(searchTags)
const searchTagsProvider = SearchTagsFamily();

/// See also [searchTags].
class SearchTagsFamily extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [searchTags].
  const SearchTagsFamily();

  /// See also [searchTags].
  SearchTagsProvider call(String query) {
    return SearchTagsProvider(query);
  }

  @override
  SearchTagsProvider getProviderOverride(
    covariant SearchTagsProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchTagsProvider';
}

/// See also [searchTags].
class SearchTagsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [searchTags].
  SearchTagsProvider(String query)
    : this._internal(
        (ref) => searchTags(ref as SearchTagsRef, query),
        from: searchTagsProvider,
        name: r'searchTagsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchTagsHash,
        dependencies: SearchTagsFamily._dependencies,
        allTransitiveDependencies: SearchTagsFamily._allTransitiveDependencies,
        query: query,
      );

  SearchTagsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(SearchTagsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchTagsProvider._internal(
        (ref) => create(ref as SearchTagsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _SearchTagsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchTagsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchTagsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchTagsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with SearchTagsRef {
  _SearchTagsProviderElement(super.provider);

  @override
  String get query => (origin as SearchTagsProvider).query;
}

String _$trendingTagsHash() => r'b25aab7e777db4ce77c31a33f6a7e834dac46bbf';

/// See also [trendingTags].
@ProviderFor(trendingTags)
final trendingTagsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      trendingTags,
      name: r'trendingTagsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trendingTagsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrendingTagsRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$photoTagsHash() => r'247d7e539c82d91c83e5cc9e0207756a8f2e1680';

/// See also [photoTags].
@ProviderFor(photoTags)
const photoTagsProvider = PhotoTagsFamily();

/// See also [photoTags].
class PhotoTagsFamily extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [photoTags].
  const PhotoTagsFamily();

  /// See also [photoTags].
  PhotoTagsProvider call(String photoId) {
    return PhotoTagsProvider(photoId);
  }

  @override
  PhotoTagsProvider getProviderOverride(covariant PhotoTagsProvider provider) {
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
  String? get name => r'photoTagsProvider';
}

/// See also [photoTags].
class PhotoTagsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [photoTags].
  PhotoTagsProvider(String photoId)
    : this._internal(
        (ref) => photoTags(ref as PhotoTagsRef, photoId),
        from: photoTagsProvider,
        name: r'photoTagsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$photoTagsHash,
        dependencies: PhotoTagsFamily._dependencies,
        allTransitiveDependencies: PhotoTagsFamily._allTransitiveDependencies,
        photoId: photoId,
      );

  PhotoTagsProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(PhotoTagsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PhotoTagsProvider._internal(
        (ref) => create(ref as PhotoTagsRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _PhotoTagsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PhotoTagsProvider && other.photoId == photoId;
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
mixin PhotoTagsRef on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `photoId` of this provider.
  String get photoId;
}

class _PhotoTagsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with PhotoTagsRef {
  _PhotoTagsProviderElement(super.provider);

  @override
  String get photoId => (origin as PhotoTagsProvider).photoId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
