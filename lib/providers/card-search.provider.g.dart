// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card-search.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cardSearchNotifierHash() =>
    r'c376679a4df4a14394631bcd992956caeaa787aa';

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

abstract class _$CardSearchNotifier
    extends BuildlessAutoDisposeNotifier<CardSearch> {
  late final String screen;
  late final CardSearch cardSearch;

  CardSearch build({required String screen, required CardSearch cardSearch});
}

/// See also [CardSearchNotifier].
@ProviderFor(CardSearchNotifier)
const cardSearchNotifierProvider = CardSearchNotifierFamily();

/// See also [CardSearchNotifier].
class CardSearchNotifierFamily extends Family<CardSearch> {
  /// See also [CardSearchNotifier].
  const CardSearchNotifierFamily();

  /// See also [CardSearchNotifier].
  CardSearchNotifierProvider call({
    required String screen,
    required CardSearch cardSearch,
  }) {
    return CardSearchNotifierProvider(screen: screen, cardSearch: cardSearch);
  }

  @override
  CardSearchNotifierProvider getProviderOverride(
    covariant CardSearchNotifierProvider provider,
  ) {
    return call(screen: provider.screen, cardSearch: provider.cardSearch);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cardSearchNotifierProvider';
}

/// See also [CardSearchNotifier].
class CardSearchNotifierProvider
    extends AutoDisposeNotifierProviderImpl<CardSearchNotifier, CardSearch> {
  /// See also [CardSearchNotifier].
  CardSearchNotifierProvider({
    required String screen,
    required CardSearch cardSearch,
  }) : this._internal(
         () =>
             CardSearchNotifier()
               ..screen = screen
               ..cardSearch = cardSearch,
         from: cardSearchNotifierProvider,
         name: r'cardSearchNotifierProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$cardSearchNotifierHash,
         dependencies: CardSearchNotifierFamily._dependencies,
         allTransitiveDependencies:
             CardSearchNotifierFamily._allTransitiveDependencies,
         screen: screen,
         cardSearch: cardSearch,
       );

  CardSearchNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.screen,
    required this.cardSearch,
  }) : super.internal();

  final String screen;
  final CardSearch cardSearch;

  @override
  CardSearch runNotifierBuild(covariant CardSearchNotifier notifier) {
    return notifier.build(screen: screen, cardSearch: cardSearch);
  }

  @override
  Override overrideWith(CardSearchNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CardSearchNotifierProvider._internal(
        () =>
            create()
              ..screen = screen
              ..cardSearch = cardSearch,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        screen: screen,
        cardSearch: cardSearch,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CardSearchNotifier, CardSearch>
  createElement() {
    return _CardSearchNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CardSearchNotifierProvider &&
        other.screen == screen &&
        other.cardSearch == cardSearch;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, screen.hashCode);
    hash = _SystemHash.combine(hash, cardSearch.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CardSearchNotifierRef on AutoDisposeNotifierProviderRef<CardSearch> {
  /// The parameter `screen` of this provider.
  String get screen;

  /// The parameter `cardSearch` of this provider.
  CardSearch get cardSearch;
}

class _CardSearchNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<CardSearchNotifier, CardSearch>
    with CardSearchNotifierRef {
  _CardSearchNotifierProviderElement(super.provider);

  @override
  String get screen => (origin as CardSearchNotifierProvider).screen;
  @override
  CardSearch get cardSearch =>
      (origin as CardSearchNotifierProvider).cardSearch;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
