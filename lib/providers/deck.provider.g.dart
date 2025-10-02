// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deckBuildNotifierHash() => r'958e3671a9b20800c3e486fd89d2861cbef0e33b';

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

abstract class _$DeckBuildNotifier extends BuildlessAutoDisposeNotifier<Deck?> {
  late final String slug;

  Deck? build(String slug);
}

/// See also [DeckBuildNotifier].
@ProviderFor(DeckBuildNotifier)
const deckBuildNotifierProvider = DeckBuildNotifierFamily();

/// See also [DeckBuildNotifier].
class DeckBuildNotifierFamily extends Family<Deck?> {
  /// See also [DeckBuildNotifier].
  const DeckBuildNotifierFamily();

  /// See also [DeckBuildNotifier].
  DeckBuildNotifierProvider call(String slug) {
    return DeckBuildNotifierProvider(slug);
  }

  @override
  DeckBuildNotifierProvider getProviderOverride(
    covariant DeckBuildNotifierProvider provider,
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
  String? get name => r'deckBuildNotifierProvider';
}

/// See also [DeckBuildNotifier].
class DeckBuildNotifierProvider
    extends AutoDisposeNotifierProviderImpl<DeckBuildNotifier, Deck?> {
  /// See also [DeckBuildNotifier].
  DeckBuildNotifierProvider(String slug)
    : this._internal(
        () => DeckBuildNotifier()..slug = slug,
        from: deckBuildNotifierProvider,
        name: r'deckBuildNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$deckBuildNotifierHash,
        dependencies: DeckBuildNotifierFamily._dependencies,
        allTransitiveDependencies:
            DeckBuildNotifierFamily._allTransitiveDependencies,
        slug: slug,
      );

  DeckBuildNotifierProvider._internal(
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
  Deck? runNotifierBuild(covariant DeckBuildNotifier notifier) {
    return notifier.build(slug);
  }

  @override
  Override overrideWith(DeckBuildNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeckBuildNotifierProvider._internal(
        () => create()..slug = slug,
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
  AutoDisposeNotifierProviderElement<DeckBuildNotifier, Deck?> createElement() {
    return _DeckBuildNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckBuildNotifierProvider && other.slug == slug;
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
mixin DeckBuildNotifierRef on AutoDisposeNotifierProviderRef<Deck?> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _DeckBuildNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<DeckBuildNotifier, Deck?>
    with DeckBuildNotifierRef {
  _DeckBuildNotifierProviderElement(super.provider);

  @override
  String get slug => (origin as DeckBuildNotifierProvider).slug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
