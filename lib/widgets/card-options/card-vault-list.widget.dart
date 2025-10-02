import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/widgets/misc/color-circle.widget.dart';
import 'package:rift/widgets/misc/titlecase.widget.dart';

import 'package:rift/main.dart';

import 'package:rift/providers/vaults.provider.dart';

import 'package:rift/models/card.model.dart';

class CardVaultList extends ConsumerStatefulWidget {
  const CardVaultList({super.key, required this.card, required this.selectVault});

  final CardItemView card;
  final Function(String slug) selectVault;

  @override
  ConsumerState<CardVaultList> createState() => _CardVaultListState();
}

class _CardVaultListState extends ConsumerState<CardVaultList> {
  Session? _session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
        if (_session != null) {
          _fetchVaults(force: true);
        }
      });
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchVaults({required bool force}) async {
    await ref.watch(vaultListNotifierProvider.notifier).search(force: force);
  }

  void _selectVault(String slug) {
    widget.selectVault(slug);
  }

  @override
  Widget build(BuildContext context) {
    final vaultList$ = ref.watch(vaultListNotifierProvider);

    return !vaultList$.isLoading
        ? vaultList$.vaults.isNotEmpty
            ? Column(
                children: [
                  for (int i = 0; i < vaultList$.vaults.length; i++)
                    ListTile(
                      leading: vaultList$.vaults[i].photo != null
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
                                        imageUrl: vaultList$.vaults[i].photo!,
                                        boxFit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                            )
                          : null,
                      title: Text(
                        vaultList$.vaults[i].name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: TitleCase(text: vaultList$.vaults[i].type),
                      trailing: ColorCircle(
                        size: 24,
                        colors: '',
                        color: Color(int.parse(vaultList$.vaults[i].color!)),
                      ),
                      onTap: () {
                        _selectVault(vaultList$.vaults[i].slug);
                      },
                    ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'No vaults yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              )
        : const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(),
          );
  }
}
