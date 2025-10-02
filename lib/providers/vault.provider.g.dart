// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vaultBuildNotifierHash() =>
    r'796cb4d611ef80ad163d6a0bcf386edbd4f438b6';

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

abstract class _$VaultBuildNotifier
    extends BuildlessAutoDisposeNotifier<Vault?> {
  late final String? slug;

  Vault? build(String? slug);
}

/// See also [VaultBuildNotifier].
@ProviderFor(VaultBuildNotifier)
const vaultBuildNotifierProvider = VaultBuildNotifierFamily();

/// See also [VaultBuildNotifier].
class VaultBuildNotifierFamily extends Family<Vault?> {
  /// See also [VaultBuildNotifier].
  const VaultBuildNotifierFamily();

  /// See also [VaultBuildNotifier].
  VaultBuildNotifierProvider call(String? slug) {
    return VaultBuildNotifierProvider(slug);
  }

  @override
  VaultBuildNotifierProvider getProviderOverride(
    covariant VaultBuildNotifierProvider provider,
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
  String? get name => r'vaultBuildNotifierProvider';
}

/// See also [VaultBuildNotifier].
class VaultBuildNotifierProvider
    extends AutoDisposeNotifierProviderImpl<VaultBuildNotifier, Vault?> {
  /// See also [VaultBuildNotifier].
  VaultBuildNotifierProvider(String? slug)
    : this._internal(
        () => VaultBuildNotifier()..slug = slug,
        from: vaultBuildNotifierProvider,
        name: r'vaultBuildNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$vaultBuildNotifierHash,
        dependencies: VaultBuildNotifierFamily._dependencies,
        allTransitiveDependencies:
            VaultBuildNotifierFamily._allTransitiveDependencies,
        slug: slug,
      );

  VaultBuildNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String? slug;

  @override
  Vault? runNotifierBuild(covariant VaultBuildNotifier notifier) {
    return notifier.build(slug);
  }

  @override
  Override overrideWith(VaultBuildNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: VaultBuildNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<VaultBuildNotifier, Vault?>
  createElement() {
    return _VaultBuildNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VaultBuildNotifierProvider && other.slug == slug;
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
mixin VaultBuildNotifierRef on AutoDisposeNotifierProviderRef<Vault?> {
  /// The parameter `slug` of this provider.
  String? get slug;
}

class _VaultBuildNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<VaultBuildNotifier, Vault?>
    with VaultBuildNotifierRef {
  _VaultBuildNotifierProviderElement(super.provider);

  @override
  String? get slug => (origin as VaultBuildNotifierProvider).slug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
