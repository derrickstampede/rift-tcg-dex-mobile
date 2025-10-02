import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/card-search.model.dart';
import 'package:rift/models/deck.model.dart';
import 'package:rift/models/vault.model.dart';

import 'package:rift/providers/card-search.provider.dart';
import 'package:rift/providers/deck.provider.dart';
import 'package:rift/providers/vault.provider.dart';

import 'package:rift/main.dart';

import 'package:rift/constants/main-card-search.constant.dart';

import 'package:rift/helpers/auth.helper.dart';
import 'package:rift/helpers/card-options.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';

class CardOptionCollection extends ConsumerStatefulWidget {
  const CardOptionCollection({
    super.key,
    required this.fabKey,
    required this.ref,
    required this.card,
    required this.searchScreen,
    this.cardSearch,
    required this.updateCardProfiles,
    this.deck,
    this.vault,
  });

  final GlobalKey<ExpandableFabState> fabKey;
  final WidgetRef ref;
  final CardItemView card;
  final String? searchScreen;
  final CardSearch? cardSearch;
  final Function(List<CardsProfiles> cardProfiles) updateCardProfiles;
  final Deck? deck;
  final Vault? vault;

  @override
  ConsumerState<CardOptionCollection> createState() => _CardOptionCollectionState();
}

class _CardOptionCollectionState extends ConsumerState<CardOptionCollection> {
  Session? _session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
      });
    });

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed) setState(() => _isPro = isSubscribed);
    // });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  void _showCollection() async {
    if (_session == null) {
      showSignInModal(context, title: 'Start Collecting Cards!');
      return;
    }

    final List<CardsProfiles>? cardsProfiles = await addToCollectionModal(context, widget.card, _isPro);
    if (cardsProfiles != null) {
      widget.card.cardsProfiles = cardsProfiles;
      if (widget.searchScreen != null) {
        widget.ref
            .watch(cardSearchNotifierProvider(screen: widget.searchScreen!, cardSearch: widget.cardSearch!).notifier)
            .updateCardProfile(widget.card.id, cardsProfiles);
      }
      if (widget.searchScreen != 'main-screen') {
        widget.ref
            .watch(cardSearchNotifierProvider(screen: MAIN_CARD_SCREEN, cardSearch: MAIN_CARD_SEARCH).notifier)
            .updateCardProfile(widget.card.id, cardsProfiles);
      }
      if (widget.deck != null) {
        widget.ref
            .watch(deckBuildNotifierProvider(widget.deck!.slug).notifier)
            .updateCardProfile(widget.card.id, cardsProfiles);
      }
      if (widget.vault != null) {
        widget.ref
            .watch(vaultBuildNotifierProvider(widget.vault!.slug).notifier)
            .updateCardProfile(widget.card.id, cardsProfiles);
      }

      widget.updateCardProfiles(cardsProfiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    int collectionCount = 0;
    for (var i = 0; i < widget.card.cardsProfiles.length; i++) {
      collectionCount += widget.card.cardsProfiles[i].count;
    }

    return FloatingActionButton(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: const CircleBorder(),
      heroTag: 'collection',
      child: RichText(
        maxLines: 1,
        text: TextSpan(style: TextStyle(color: Theme.of(context).colorScheme.onPrimary), children: [
          const WidgetSpan(
            alignment: PlaceholderAlignment.bottom,
            child: Icon(
              Symbols.star,
              size: 18,
            ),
          ),
          TextSpan(
            text: collectionCount.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ]),
      ),
      onPressed: () {
        _showCollection();
        logEvent(name: 'card_add_to_collection');

        final state = widget.fabKey.currentState;
        if (state != null) state.toggle();
      },
    );
  }
}
