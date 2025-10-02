import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/card-search.model.dart';

import 'package:rift/main.dart';

import 'package:rift/helpers/auth.helper.dart';
import 'package:rift/helpers/card-options.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';

class CardOptionVault extends ConsumerStatefulWidget {
  const CardOptionVault(
      {super.key,
      required this.fabKey,
      required this.ref,
      required this.card,
      required this.searchScreen,
      this.cardSearch});

  final GlobalKey<ExpandableFabState> fabKey;
  final WidgetRef ref;
  final CardItemView card;
  final String? searchScreen;
  final CardSearch? cardSearch;

  @override
  ConsumerState<CardOptionVault> createState() => _CardOptionVaultState();
}

class _CardOptionVaultState extends ConsumerState<CardOptionVault> {
  Session? _session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
      });
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  void _loadVaultList() {
    if (_session == null) {
      showSignInModal(context, title: 'Start Storing Cards!');
      return;
    }
    showVaultsModal(context, widget.card);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: const CircleBorder(),
      heroTag: 'vault',
      child: const Icon(Symbols.lock),
      onPressed: () {
        _loadVaultList();
        logEvent(name: 'card_add_to_vault');

        final state = widget.fabKey.currentState;
        if (state != null) state.toggle();
      },
    );
  }
}
