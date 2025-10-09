import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/providers/deck.provider.dart';
import 'package:rift/providers/decks.provider.dart';
import 'package:rift/providers/card-search.provider.dart';

import 'package:rift/models/deck.model.dart';
import 'package:rift/models/card.model.dart';

import 'package:rift/screens/decks/deck-full.screen.dart';

import 'package:rift/widgets/cards/card-sort-header.widget.dart';
import 'package:rift/widgets/cards/card-grid.widget.dart';
// import 'package:rift/widgets/ads/ad-banner.widget.dart';

import 'package:rift/helpers/deck.helper.dart';
import 'package:rift/helpers/card.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/models/card-search.model.dart';

import 'package:rift/routes/config.dart';

class DeckCardsScreen extends ConsumerStatefulWidget {
  const DeckCardsScreen({
    super.key,
    required this.slug,
    required this.deck,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String slug;
  final Deck deck;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  ConsumerState<DeckCardsScreen> createState() => _DeckCardsScreenState();
}

class _DeckCardsScreenState extends ConsumerState<DeckCardsScreen> {
  Session? _session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  final _scrollController = ScrollController();

  final int _deckCardLimit = int.parse(dotenv.env['CARD_PER_DECK_LIMIT']!);

  final _searchScreen = 'deck-edit';
  final CardSearch _cardSearch = CardSearch(
    cards: [],
    cardBatches: [],
    status: CardSearchStatus(
      isInitializing: false,
      isLoading: false,
      hasReachedLimit: true,
      showOwned: false,
      view: 'name',
      orderBy: 'card',
      isAscending: false,
      showCollectionDisabled: false,
      showTypeRequired: false,
      showColorRequired: false,
      selectLeader: false,
      addToDeck: true,
      addToDeckSelect: false,
      addToVault: false,
    ),
    filters: CardSearchFilters(
      collection: false,
      name: null,
      setId: null,
      rarity: [],
      language: [],
      type: [],
      color: [],
      domain: [],
      art: [],
      energy: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_COST_RESET']!)),
      might: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_COST_RESET']!)),
      power: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_POWER_RESET']!)),
      tag: null,
      effect: [],
      asc: null,
      desc: null,
    ),
    config: CardSearchConfig(
      disableCollection: false,
      disableRarity: const [],
      disableType: const [],
      disableColor: const [],
      initialResetColor: const [],
      initialResetType: const [],
      initialResetRarity: const [],
      requireOneType: false,
      requireOneColor: false,
    ),
    symbol: null,
  );

  String _sortedBy = 'card';
  bool _isAscending = true;

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
      });
    });

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed) setState(() => _isPro = isSubscribed);
    // });

    _initDeck();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  void _initDeck() {
    setState(() {
      _sortedBy = widget.deck.sortBy!;
      _isAscending = widget.deck.isSortAscending!;
    });
  }

  List<CardListItem> _sortCards(List<CardListItem> cards, String by, bool isAscending) {
    final leaderCards = cards.where((c) => c.type?.toLowerCase() == 'leader').toList();
    final battleCards = cards.where((c) => c.type?.toLowerCase() == 'battle').toList();
    final extraCards = cards.where((c) => c.type?.toLowerCase() == 'extra').toList();
    final energyCards = cards.where((c) => c.type?.toLowerCase() == 'energy marker').toList();

    if (by == 'card') {
      battleCards.sort((a, b) => isAscending ? a.cardId.compareTo(b.cardId) : b.cardId.compareTo(a.cardId));
      extraCards.sort((a, b) => isAscending ? a.cardId.compareTo(b.cardId) : b.cardId.compareTo(a.cardId));
      energyCards.sort((a, b) => isAscending ? a.cardId.compareTo(b.cardId) : b.cardId.compareTo(a.cardId));
    }
    if (by == 'name') {
      battleCards.sort((a, b) => isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
      extraCards.sort((a, b) => isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
      energyCards.sort((a, b) => isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    }
    if (by == 'power') {
      battleCards.sort((a, b) => isAscending ? a.power!.compareTo(b.power!) : b.power!.compareTo(a.power!));
      extraCards.sort((a, b) => isAscending ? a.power!.compareTo(b.power!) : b.power!.compareTo(a.power!));
      energyCards.sort((a, b) => isAscending ? a.power!.compareTo(b.power!) : b.power!.compareTo(a.power!));
    }
    if (by == 'energy') {
      battleCards.sort((a, b) => isAscending ? a.energy!.compareTo(b.energy!) : b.energy!.compareTo(a.energy!));
      extraCards.sort((a, b) => isAscending ? a.energy!.compareTo(b.energy!) : b.energy!.compareTo(a.energy!));
      energyCards.sort((a, b) => isAscending ? a.energy!.compareTo(b.energy!) : b.energy!.compareTo(a.energy!));
    }
    if (by == 'might') {
      battleCards.sort((a, b) => isAscending ? a.might!.compareTo(b.might!) : b.might!.compareTo(a.might!));
      extraCards.sort((a, b) => isAscending ? a.might!.compareTo(b.might!) : b.might!.compareTo(a.might!));
      energyCards.sort((a, b) => isAscending ? a.might!.compareTo(b.might!) : b.might!.compareTo(a.might!));
    }

    return [...leaderCards, ...battleCards, ...extraCards, ...energyCards];
  }

  void _viewFull(String name, List<CardListItem> cards, Color foregroundColor, Color backgroundColor) {
    logEvent(name: 'deck_fullscreen');

    Navigator.of(context).push(
      TransparentRoute(
        builder:
            (BuildContext context) => DeckFullScreen(
              name: name,
              cards: cards,
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
            ),
      ),
    );
  }

  void _goToSelectCards(Deck deck) async {
    await Config.router.navigateTo(
      context,
      '/decks/pick?slug=${deck.slug}&color=${Uri.encodeComponent(deck.legend.color!)}',
    );
  }

  void _sortBy({required String? by}) {
    if (by == null) return;
    setState(() {
      _sortedBy = by;
    });

    _updateSorting();
  }

  void _sortOrder({required bool isAscending}) {
    setState(() {
      _isAscending = !isAscending;
    });

    _updateSorting();
  }

  Future<void> _updateSorting() async {
    final response = await updateSortingDeck(_sortedBy, _isAscending, widget.deck.slug);
    response.fold((l) {
      logEvent(name: 'deck_cards_sort', parameters: {'sort': _sortedBy, 'by': _isAscending ? 'asc' : 'desc'});
    }, (r) {});
  }

  @override
  Widget build(BuildContext context) {
    _cardSearch.symbol = widget.deck.symbol;
    ref.watch(cardSearchNotifierProvider(screen: _searchScreen, cardSearch: _cardSearch));

    final cards = _sortCards(widget.deck.cards, _sortedBy, _isAscending);
    final cardBatches = createCardBatches(cards);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          MultiSliver(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(
                  '${widget.deck.legend.name} (${widget.deck.legend.cardId})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text:
                            "${ref.read(deckBuildNotifierProvider(widget.slug).notifier).totalCards()}/$_deckCardLimit cards \u2981 ",
                      ),
                      if (ref.read(deckBuildNotifierProvider(widget.slug).notifier).totalOtherCards() > 0)
                        TextSpan(text: "1 Energy \u2981 "),
                      TextSpan(
                        text:
                            ref.read(deckBuildNotifierProvider(widget.slug).notifier).isPublic()
                                ? 'Public '
                                : 'Private ',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: SizedBox(
                          height: 28,
                          width: 32,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Switch(
                              value: ref.read(deckBuildNotifierProvider(widget.slug).notifier).isPublic(),
                              onChanged: (bool value) {
                                ref.read(deckBuildNotifierProvider(widget.slug).notifier).updatePublic(value);
                                ref.read(deckListNotifierProvider.notifier).updatePublic(widget.deck.id, value);
                              },
                            ),
                          ),
                        ),
                      ),
                      if (ref.read(deckBuildNotifierProvider(widget.slug).notifier).isPublic())
                        const TextSpan(text: " Copy URL "),
                      if (ref.read(deckBuildNotifierProvider(widget.slug).notifier).isPublic())
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: SizedBox(
                            width: 22,
                            height: 24,
                            child: RawMaterialButton(
                              onPressed: () {
                                final url = 'https://${dotenv.env['API']}/d/${widget.deck.slug}';

                                Clipboard.setData(ClipboardData(text: url));
                                showSnackbar('Copied URL to clipboard');
                              },
                              elevation: 2.0,
                              fillColor: widget.backgroundColor,
                              shape: const CircleBorder(),
                              child: Icon(Symbols.share, size: 14.0, color: widget.foregroundColor),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                trailing: SizedBox(
                  width: 42,
                  child: RawMaterialButton(
                    onPressed: () => _viewFull(widget.deck.name, cards, widget.foregroundColor, widget.backgroundColor),
                    elevation: 2.0,
                    fillColor: widget.backgroundColor,
                    padding: const EdgeInsets.all(8.0),
                    shape: const CircleBorder(),
                    child: Icon(Symbols.open_in_full, size: 18.0, color: widget.foregroundColor),
                  ),
                ),
                onTap: null,
              ),
              for (int i = 0; i < cardBatches.length; i++) ...[
                CardGrid(
                  cards: cardBatches[i],
                  searchScreen: _searchScreen,
                  cardSearch: _cardSearch,
                  columns: 3,
                  deck: widget.deck,
                ),
                // if (!_isPro && (i == 0 || cardBatches[i].length >= int.parse(dotenv.env['AD_BANNER_CARDS_PER_AD']!)))
                //   const Padding(padding: EdgeInsets.symmetric(vertical: 2), child: Center(child: AdBanner())),
              ],
              if (cards.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: const Text('No cards yet', style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      persistentFooterButtons:
          _session == null
              ? null
              : [
                CardSortHeader(
                  searchScreen: _searchScreen,
                  cardSearch: _cardSearch,
                  showSortDropdown: true,
                  sortedBy: _sortedBy,
                  sortBy: _sortBy,
                  isAscending: _isAscending,
                  sortOrder: _sortOrder,
                ),
              ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _goToSelectCards(widget.deck);
        },
        backgroundColor: widget.backgroundColor,
        child: Icon(Symbols.add, color: widget.foregroundColor),
      ),
    );
  }
}
