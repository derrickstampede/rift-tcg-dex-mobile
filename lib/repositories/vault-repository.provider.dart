import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/repositories/vault.repository.dart';

part 'vault-repository.provider.g.dart';

@riverpod
VaultRepository vaultRepository(VaultRepositoryRef ref, String slug) {
  return VaultRepository(slug);
}