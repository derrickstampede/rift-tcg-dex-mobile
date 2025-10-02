// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck-repository.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deckRepositoryHash() => r'577920874bf13ea3d07e2e2efabc9506c1a02fda';

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

/// See also [deckRepository].
@ProviderFor(deckRepository)
const deckRepositoryProvider = DeckRepositoryFamily();

/// See also [deckRepository].
class DeckRepositoryFamily extends Family<DeckRepository> {
  /// See also [deckRepository].
  const DeckRepositoryFamily();

  /// See also [deckRepository].
  DeckRepositoryProvider call(String slug) {
    return DeckRepositoryProvider(slug);
  }

  @override
  DeckRepositoryProvider getProviderOverride(
    covariant DeckRepositoryProvider provider,
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
  String? get name => r'deckRepositoryProvider';
}

/// See also [deckRepository].
class DeckRepositoryProvider extends AutoDisposeProvider<DeckRepository> {
  /// See also [deckRepository].
  DeckRepositoryProvider(String slug)
    : this._internal(
        (ref) => deckRepository(ref as DeckRepositoryRef, slug),
        from: deckRepositoryProvider,
        name: r'deckRepositoryProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$deckRepositoryHash,
        dependencies: DeckRepositoryFamily._dependencies,
        allTransitiveDependencies:
            DeckRepositoryFamily._allTransitiveDependencies,
        slug: slug,
      );

  DeckRepositoryProvider._internal(
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
    DeckRepository Function(DeckRepositoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeckRepositoryProvider._internal(
        (ref) => create(ref as DeckRepositoryRef),
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
  AutoDisposeProviderElement<DeckRepository> createElement() {
    return _DeckRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckRepositoryProvider && other.slug == slug;
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
mixin DeckRepositoryRef on AutoDisposeProviderRef<DeckRepository> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _DeckRepositoryProviderElement
    extends AutoDisposeProviderElement<DeckRepository>
    with DeckRepositoryRef {
  _DeckRepositoryProviderElement(super.provider);

  @override
  String get slug => (origin as DeckRepositoryProvider).slug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
