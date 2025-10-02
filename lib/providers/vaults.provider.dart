import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/models/vault.model.dart';

import 'package:rift/repositories/vaults.repository.dart';

import 'package:rift/repositories/vaults-repository.provider.dart';

part 'vaults.provider.g.dart';

@riverpod
class VaultListNotifier extends _$VaultListNotifier {
  late final VaultsRepository vaultsRepository;

  bool _isFetchedInitially = false;

  @override
  VaultList build() {
    print('build vault list');
    vaultsRepository = ref.watch(vaultsRepositoryProvider);
    return VaultList(vaults: [], sortBy: 'date_created', isSortAscending: true, isLoading: true);
  }

  Future<void> search({required bool force}) async {
    try {
      if (_isFetchedInitially && !force) return;

      final response = await vaultsRepository.search();
      _isFetchedInitially = true;
      final VaultList vaultList = VaultList(
        vaults: response['vaults'],
        sortBy: response['sortBy'],
        isSortAscending: response['isSortAscending'],
        isLoading: false,
      );
      update(vaultList);

      sort();
    } catch (e) {
      // TODO error handling
      print(e);
    }
  }

  void update(VaultList value) => state = value;

  void sort() {
    List<Vault> vaults = state.vaults;

    if (state.sortBy == 'name') {
      vaults.sort((a, b) => state.isSortAscending
          ? a.name.toUpperCase().compareTo(b.name.toUpperCase())
          : b.name.toUpperCase().compareTo(a.name.toUpperCase()));
    }
    if (state.sortBy == 'type') {
      vaults.sort((a, b) => state.isSortAscending ? a.type.compareTo(b.type) : b.type.compareTo(a.type));
    }
    if (state.sortBy == 'color') {
      vaults.sort((a, b) => state.isSortAscending ? a.color!.compareTo(b.color!) : b.color!.compareTo(a.color!));
    }
    if (state.sortBy == 'date_created') {
      vaults.sort(
          (a, b) => state.isSortAscending ? a.createdAt.compareTo(b.createdAt) : b.createdAt.compareTo(a.createdAt));
    }
    if (state.sortBy == 'date_updated') {
      vaults.sort(
          (a, b) => state.isSortAscending ? a.updatedAt.compareTo(b.updatedAt) : b.updatedAt.compareTo(a.updatedAt));
    }

    final VaultList vaultList = VaultList(
      vaults: vaults,
      sortBy: state.sortBy,
      isSortAscending: state.isSortAscending,
      isLoading: state.isLoading,
    );
    update(vaultList);
  }

  void updateSort({String? sortBy, bool? isSortAscending}) {
    String newSortBy = state.sortBy;
    bool newIsSortAscending = state.isSortAscending;

    if (sortBy != null) {
      newSortBy = sortBy;
    }
    if (isSortAscending != null) {
      newIsSortAscending = isSortAscending;
    }

    vaultsRepository.updateDeckSorting(newSortBy, newIsSortAscending);

    final VaultList vaultList = VaultList(
      vaults: state.vaults,
      sortBy: newSortBy,
      isSortAscending: newIsSortAscending,
      isLoading: state.isLoading,
    );
    update(vaultList);

    sort();
  }

  void add(Vault vault) {
    try {
      final vaults = state.vaults;
      vaults.insert(0, vault);

      final VaultList vaultList = VaultList(
        vaults: vaults,
        sortBy: state.sortBy,
        isSortAscending: state.isSortAscending,
        isLoading: state.isLoading,
      );
      update(vaultList);
    } catch (e) {
      // TODO error handling
      print(e);
    }
  }

  Future<void> patch(Vault vault) async {
    try {
      final vaults = state.vaults;
      final index = vaults.indexWhere((d) => d.slug == vault.slug);
      vaults[index] = vault;

      final VaultList vaultList = VaultList(
        vaults: vaults,
        sortBy: state.sortBy,
        isSortAscending: state.isSortAscending,
        isLoading: state.isLoading,
      );
      update(vaultList);
    } catch (e) {
      // TODO error handling
      print(e);
    }
  }

  Future<void> patchName(String slug, String name) async {
    try {
      final vaults = state.vaults;
      final index = vaults.indexWhere((v) => v.slug == slug);
      vaults[index].name = name;

      final VaultList vaultList = VaultList(
        vaults: vaults,
        sortBy: state.sortBy,
        isSortAscending: state.isSortAscending,
        isLoading: state.isLoading,
      );
      update(vaultList);
    } catch (e) {
      // TODO error handling
      print(e);
    }
  }

  Future<void> updatePhoto(String slug, String photo) async {
    try {
      final vaults = state.vaults;
      final index = vaults.indexWhere((d) => d.slug == slug);
      vaults[index].photo = photo;

      final VaultList vaultList = VaultList(
        vaults: vaults,
        sortBy: state.sortBy,
        isSortAscending: state.isSortAscending,
        isLoading: state.isLoading,
      );
      update(vaultList);
    } catch (e) {
      // TODO error handling
      print(e);
    }
  }

  void updateUpdatedAt(String slug) {
    final vaults = state.vaults;
    final index = vaults.indexWhere((v) => v.slug == slug);
    if (index < 0) return;
    
    vaults[index].updatedAt = DateTime.now();

    sort();
  }

  Future<void> remove(String slug) async {
    try {
      final vaults = state.vaults;
      final index = vaults.indexWhere((d) => d.slug == slug);
      vaults.removeAt(index);

      final VaultList vaultList = VaultList(
          vaults: vaults, sortBy: state.sortBy, isSortAscending: state.isSortAscending, isLoading: state.isLoading);
      update(vaultList);

      await vaultsRepository.delete(slug);
    } catch (e) {
      // TODO error handling
      print(e);
    }
  }

  void reset() {
    final VaultList vaultList = VaultList(
      vaults: [],
      sortBy: state.sortBy,
      isSortAscending: state.isSortAscending,
      isLoading: true,
    );
    update(vaultList);
  }
}
