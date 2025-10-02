import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/repositories/vaults.repository.dart';

part 'vaults-repository.provider.g.dart';

@riverpod
VaultsRepository vaultsRepository(VaultsRepositoryRef ref) {
  return VaultsRepository();
}