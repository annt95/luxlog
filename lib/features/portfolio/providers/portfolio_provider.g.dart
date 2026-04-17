// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$portfolioRepositoryHash() =>
    r'a0ea5de5879316e3ac580c14229652a86c86bccb';

/// See also [portfolioRepository].
@ProviderFor(portfolioRepository)
final portfolioRepositoryProvider =
    AutoDisposeProvider<PortfolioRepository>.internal(
      portfolioRepository,
      name: r'portfolioRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$portfolioRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PortfolioRepositoryRef = AutoDisposeProviderRef<PortfolioRepository>;
String _$portfolioBlocksHash() => r'939a8c0f0f227e3e7541774b7d2e8898a1f47e92';

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

/// See also [portfolioBlocks].
@ProviderFor(portfolioBlocks)
const portfolioBlocksProvider = PortfolioBlocksFamily();

/// See also [portfolioBlocks].
class PortfolioBlocksFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [portfolioBlocks].
  const PortfolioBlocksFamily();

  /// See also [portfolioBlocks].
  PortfolioBlocksProvider call(String userId) {
    return PortfolioBlocksProvider(userId);
  }

  @override
  PortfolioBlocksProvider getProviderOverride(
    covariant PortfolioBlocksProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'portfolioBlocksProvider';
}

/// See also [portfolioBlocks].
class PortfolioBlocksProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [portfolioBlocks].
  PortfolioBlocksProvider(String userId)
    : this._internal(
        (ref) => portfolioBlocks(ref as PortfolioBlocksRef, userId),
        from: portfolioBlocksProvider,
        name: r'portfolioBlocksProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$portfolioBlocksHash,
        dependencies: PortfolioBlocksFamily._dependencies,
        allTransitiveDependencies:
            PortfolioBlocksFamily._allTransitiveDependencies,
        userId: userId,
      );

  PortfolioBlocksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(PortfolioBlocksRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PortfolioBlocksProvider._internal(
        (ref) => create(ref as PortfolioBlocksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _PortfolioBlocksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PortfolioBlocksProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PortfolioBlocksRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _PortfolioBlocksProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with PortfolioBlocksRef {
  _PortfolioBlocksProviderElement(super.provider);

  @override
  String get userId => (origin as PortfolioBlocksProvider).userId;
}

String _$publicPortfolioHash() => r'db4857bdd6b2bc391305ee52465824a4bfa944d2';

/// See also [publicPortfolio].
@ProviderFor(publicPortfolio)
const publicPortfolioProvider = PublicPortfolioFamily();

/// See also [publicPortfolio].
class PublicPortfolioFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [publicPortfolio].
  const PublicPortfolioFamily();

  /// See also [publicPortfolio].
  PublicPortfolioProvider call(String slug) {
    return PublicPortfolioProvider(slug);
  }

  @override
  PublicPortfolioProvider getProviderOverride(
    covariant PublicPortfolioProvider provider,
  ) {
    return call(provider.slug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publicPortfolioProvider';
}

/// See also [publicPortfolio].
class PublicPortfolioProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [publicPortfolio].
  PublicPortfolioProvider(String slug)
    : this._internal(
        (ref) => publicPortfolio(ref as PublicPortfolioRef, slug),
        from: publicPortfolioProvider,
        name: r'publicPortfolioProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$publicPortfolioHash,
        dependencies: PublicPortfolioFamily._dependencies,
        allTransitiveDependencies:
            PublicPortfolioFamily._allTransitiveDependencies,
        slug: slug,
      );

  PublicPortfolioProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(PublicPortfolioRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublicPortfolioProvider._internal(
        (ref) => create(ref as PublicPortfolioRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _PublicPortfolioProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicPortfolioProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublicPortfolioRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _PublicPortfolioProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with PublicPortfolioRef {
  _PublicPortfolioProviderElement(super.provider);

  @override
  String get slug => (origin as PublicPortfolioProvider).slug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
