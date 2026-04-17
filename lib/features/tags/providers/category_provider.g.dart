// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryRepositoryHash() =>
    r'a67d8ee491217896000350403c0f376ce33a3eb5';

/// See also [categoryRepository].
@ProviderFor(categoryRepository)
final categoryRepositoryProvider =
    AutoDisposeProvider<CategoryRepository>.internal(
      categoryRepository,
      name: r'categoryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryRepositoryRef = AutoDisposeProviderRef<CategoryRepository>;
String _$categoriesHash() => r'7977731d23012a91e8abeb277e07e8fd27cf44f5';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      categories,
      name: r'categoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$categoryPhotosHash() => r'77f6db2d19780073e073c7bafcbda8f122be513a';

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

/// See also [categoryPhotos].
@ProviderFor(categoryPhotos)
const categoryPhotosProvider = CategoryPhotosFamily();

/// See also [categoryPhotos].
class CategoryPhotosFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [categoryPhotos].
  const CategoryPhotosFamily();

  /// See also [categoryPhotos].
  CategoryPhotosProvider call(String slug, {int page = 0}) {
    return CategoryPhotosProvider(slug, page: page);
  }

  @override
  CategoryPhotosProvider getProviderOverride(
    covariant CategoryPhotosProvider provider,
  ) {
    return call(provider.slug, page: provider.page);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoryPhotosProvider';
}

/// See also [categoryPhotos].
class CategoryPhotosProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [categoryPhotos].
  CategoryPhotosProvider(String slug, {int page = 0})
    : this._internal(
        (ref) => categoryPhotos(ref as CategoryPhotosRef, slug, page: page),
        from: categoryPhotosProvider,
        name: r'categoryPhotosProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$categoryPhotosHash,
        dependencies: CategoryPhotosFamily._dependencies,
        allTransitiveDependencies:
            CategoryPhotosFamily._allTransitiveDependencies,
        slug: slug,
        page: page,
      );

  CategoryPhotosProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
    required this.page,
  }) : super.internal();

  final String slug;
  final int page;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(CategoryPhotosRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryPhotosProvider._internal(
        (ref) => create(ref as CategoryPhotosRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _CategoryPhotosProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryPhotosProvider &&
        other.slug == slug &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryPhotosRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `slug` of this provider.
  String get slug;

  /// The parameter `page` of this provider.
  int get page;
}

class _CategoryPhotosProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with CategoryPhotosRef {
  _CategoryPhotosProviderElement(super.provider);

  @override
  String get slug => (origin as CategoryPhotosProvider).slug;
  @override
  int get page => (origin as CategoryPhotosProvider).page;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
