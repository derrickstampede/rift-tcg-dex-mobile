// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault-repository.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vaultRepositoryHash() => r'34c0e8a024c3a4b664b128f7f810e6cdbf56988f';

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

/// See also [vaultRepository].
@ProviderFor(vaultRepository)
const vaultRepositoryProvider = VaultRepositoryFamily();

/// See also [vaultRepository].
class VaultRepositoryFamily extends Family<VaultRepository> {
  /// See also [vaultRepository].
  const VaultRepositoryFamily();

  /// See also [vaultRepository].
  VaultRepositoryProvider call(String slug) {
    return VaultRepositoryProvider(slug);
  }

  @override
  VaultRepositoryProvider getProviderOverride(
    covariant VaultRepositoryProvider provider,
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
  String? get name => r'vaultRepositoryProvider';
}

/// See also [vaultRepository].
class VaultRepositoryProvider extends AutoDisposeProvider<VaultRepository> {
  /// See also [vaultRepository].
  VaultRepositoryProvider(String slug)
    : this._internal(
        (ref) => vaultRepository(ref as VaultRepositoryRef, slug),
        from: vaultRepositoryProvider,
        name: r'vaultRepositoryProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$vaultRepositoryHash,
        dependencies: VaultRepositoryFamily._dependencies,
        allTransitiveDependencies:
            VaultRepositoryFamily._allTransitiveDependencies,
        slug: slug,
      );

  VaultRepositoryProvider._internal(
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
    VaultRepository Function(VaultRepositoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VaultRepositoryProvider._internal(
        (ref) => create(ref as VaultRepositoryRef),
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
  AutoDisposeProviderElement<VaultRepository> createElement() {
    return _VaultRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VaultRepositoryProvider && other.slug == slug;
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
mixin VaultRepositoryRef on AutoDisposeProviderRef<VaultRepository> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _VaultRepositoryProviderElement
    extends AutoDisposeProviderElement<VaultRepository>
    with VaultRepositoryRef {
  _VaultRepositoryProviderElement(super.provider);

  @override
  String get slug => (origin as VaultRepositoryProvider).slug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
