import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

import 'package:rift/main.dart';

import 'package:rift/routes/config.dart';

import 'package:rift/models/vault.model.dart';
import 'package:rift/models/filter.model.dart';

import 'package:rift/widgets/auth/signin-button.widget.dart';
import 'package:rift/widgets/misc/color-circle.widget.dart';
import 'package:rift/widgets/misc/titlecase.widget.dart';
// import 'package:rift/widgets/ads/ad-banner.widget.dart';

import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/profile.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/providers/vaults.provider.dart';
// import 'package:rift/providers/ad.provider.dart';

class VaultsScreen extends ConsumerStatefulWidget {
  const VaultsScreen({super.key});

  @override
  ConsumerState<VaultsScreen> createState() => _VaultsScreenState();
}

class _VaultsScreenState extends ConsumerState<VaultsScreen> {
  Session? session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  final _vaultLimit = int.parse(dotenv.env['ANONYMOUS_VAULT_LIMIT']!);
  final _subVaultLimit = int.parse(dotenv.env['SUBSCRIBED_VAULT_LIMIT']!);
  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  final List<Filter> _sortingOptions = [
    Filter(label: 'Name', value: 'name'),
    Filter(label: 'Type', value: 'type'),
    Filter(label: 'Color', value: 'color'),
    Filter(label: 'Created', value: 'date_created'),
    Filter(label: 'Updated', value: 'date_updated'),
  ];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        session = data.session;
        if (session != null) {
          _fetchVaults(force: true);
        }
      });
    });

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed && mounted) setState(() => _isPro = isSubscribed);
    // });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchVaults({required bool force}) async {
    await ref.watch(vaultListNotifierProvider.notifier).search(force: force);
  }

  void _validateVaultCount(List<Vault> vaults) async {
    int limit = _vaultLimit;
    if (_isPro) {
      limit = _subVaultLimit;
    }

    if (vaults.length >= limit) {
      // showSubscribeDialog(context: context, source: 'vault-limit');
      return;
    }
    _goToNewVault();
  }

  void _goToNewVault() async {
    Config.router.navigateTo(context, '/vaults/form');
  }

  void _goToVault(int index, VaultList vaultlist) async {
    final vault = vaultlist.vaults[index];
    await Config.router.navigateTo(context, '/vaults/view?slug=${vault.slug}&name=${vault.name}&color=${vault.color}');

    // if (!_isPro) ref.watch(adNotifierProvider.notifier).showInterstitialAd();
  }

  void _removeVault(Vault vault, WidgetRef ref) async {
    await ref.read(vaultListNotifierProvider.notifier).remove(vault.slug);

    logEvent(name: 'vault_delete', parameters: {'method': 'swipe'});
    showSnackbar('${vault.name} deleted');
  }

  Future<bool?> _showDeleteDialog(Vault vault) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text('You are about to delete vault ${vault.name}.')]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vaultList$ = ref.watch(vaultListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaults'),
        elevation: 1,
        // bottom:
        //     session != null && !vaultList$.isLoading && !_isPro
        //         ? const PreferredSize(preferredSize: Size.fromHeight(50.0), child: AdBanner())
        //         : null,
      ),
      body:
          session != null
              ? !vaultList$.isLoading
                  ? vaultList$.vaults.isNotEmpty
                      ? RefreshIndicator(
                        onRefresh: () => _fetchVaults(force: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: vaultList$.vaults.length,
                          itemBuilder: (context, index) {
                            if (!_isPro && _vaultLimit <= index) {
                              return ListTile(
                                leading: const SizedBox(width: 42, child: Icon(Symbols.lock)),
                                title: Text(
                                  "Locked Vault",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: DefaultTextStyle.of(context).style.color,
                                  ),
                                ),
                                subtitle: const Text('Subscribe to unlock'),
                                // onTap: () => showSubscribeDialog(context: context, source: 'vault-locked'),
                              );
                            }

                            return Dismissible(
                              key: UniqueKey(),
                              background: Container(color: Theme.of(context).colorScheme.error),
                              onDismissed: (direction) {
                                _removeVault(vaultList$.vaults[index], ref);
                              },
                              confirmDismiss: (direction) async {
                                return _showDeleteDialog(vaultList$.vaults[index]);
                              },
                              child: ListTile(
                                leading:
                                    vaultList$.vaults[index].photo != null
                                        ? SizedBox(
                                          width: 42,
                                          height: 42,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4.0),
                                            child: Container(
                                              color: Colors.grey,
                                              child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: FancyShimmerImage(
                                                  imageUrl: vaultList$.vaults[index].photo!,
                                                  boxFit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        : null,
                                title: Text(
                                  vaultList$.vaults[index].name,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                subtitle: TitleCase(
                                  text:
                                      vaultList$.vaults[index].type == 'other' && vaultList$.vaults[index].other != null
                                          ? vaultList$.vaults[index].other!
                                          : vaultList$.vaults[index].type,
                                ),
                                trailing: ColorCircle(
                                  size: 24,
                                  colors: '',
                                  color: Color(int.parse(vaultList$.vaults[index].color!)),
                                ),
                                onTap: () {
                                  _goToVault(index, vaultList$);
                                },
                              ),
                            );
                          },
                        ),
                      )
                      : const Center(child: Text('No vaults yet'))
                  : const Center(child: CircularProgressIndicator())
              : const SigninButton(),
      persistentFooterButtons:
          session != null
              ? [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 4,
                      child: Row(
                        children: [
                          const Icon(Symbols.sort, size: 22),
                          const SizedBox(width: 4),
                          Ink(
                            width: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: vaultList$.sortBy,
                              isExpanded: true,
                              iconSize: 0,
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                constraints: BoxConstraints(maxHeight: 40),
                                focusColor: Colors.transparent,
                              ),
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              onChanged: (String? value) {
                                ref.read(vaultListNotifierProvider.notifier).updateSort(sortBy: value);
                              },
                              items: [
                                for (var i = 0; i < _sortingOptions.length; i++)
                                  DropdownMenuItem<String>(
                                    value: _sortingOptions[i].value,
                                    child: Text(
                                      _sortingOptions[i].label,
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 2),
                          SizedBox(
                            height: 32,
                            child: IconButton(
                              onPressed: () {
                                ref
                                    .read(vaultListNotifierProvider.notifier)
                                    .updateSort(isSortAscending: !vaultList$.isSortAscending);
                              },
                              iconSize: 20.0,
                              padding: const EdgeInsets.only(bottom: 1, left: 6, right: 6),
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              icon:
                                  vaultList$.isSortAscending
                                      ? const Icon(Symbols.arrow_upward)
                                      : const Icon(Symbols.arrow_downward),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
              : null,
      floatingActionButton:
          session != null
              ? FloatingActionButton(
                onPressed: () => _validateVaultCount(vaultList$.vaults),
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Symbols.add, color: Theme.of(context).colorScheme.onPrimary),
              )
              : null,
    );
  }
}
