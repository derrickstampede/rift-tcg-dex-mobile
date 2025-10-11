import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/models/card-search.model.dart';

import 'package:rift/providers/card-search.provider.dart';
import 'package:rift/providers/deck.provider.dart';

import 'package:rift/helpers/util.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/widgets/cards/card-filter-drawer.widget.dart';
import 'package:rift/widgets/cards/card-grid.widget.dart';
import 'package:rift/widgets/cards/card-sort-header.widget.dart';
import 'package:rift/widgets/ads/ad-banner.widget.dart';

class SelectCardsScreen extends ConsumerStatefulWidget {
  const SelectCardsScreen({super.key, this.slug, this.color});

  final String? slug;
  final String? color;

  @override
  ConsumerState<SelectCardsScreen> createState() => _SelectCardsScreenState();
}

class _SelectCardsScreenState extends ConsumerState<SelectCardsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  Session? _session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  final _searchScreen = 'select-cards';
  CardSearch _cardSearch = CardSearch(
    cards: [],
    cardBatches: [],
    status: CardSearchStatus(
      isInitializing: true,
      isLoading: false,
      hasReachedLimit: false,
      showOwned: false,
      view: 'name',
      orderBy: 'set',
      isAscending: false,
      showCollectionDisabled: false,
      showTypeRequired: false,
      showColorRequired: false,
      selectLeader: false,
      addToDeck: true,
      addToDeckSelect: true,
      addToVault: false,
    ),
    filters: CardSearchFilters(
      collection: false,
      name: null,
      setId: null,
      rarity: [],
      language: [],
      domain: [],
      type: ["Signature Spell", "Spell", "Token Unit", "Unit", "Rune", "Gear"],
      color: [],
      art: [],
      energy: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_ENERGY_RESET']!)),
      might: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_MIGHT_RESET']!)),
      power: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_POWER_RESET']!)),
      tag: null,
      effect: [],
      asc: null,
      desc: null,
    ),
    config: CardSearchConfig(
      disableCollection: false,
      disableRarity: const [],
      disableType: const ["Legend", "Champion Unit", "Battlefield"],
      disableColor: const [],
      initialResetColor: const [],
      initialResetType: const [],
      initialResetRarity: const [],
      requireOneType: true,
      requireOneColor: true,
    ),
    symbol: null,
  );

  final int _deckCardLimit = int.parse(dotenv.env['CARD_PER_DECK_LIMIT']!);
  final List<String> _allColors = ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange', 'No Color'];

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    super.initState();

    final searchCardsJson = _cardSearch.toJson();
    List<String> colors = widget.color!.split("/");
    colors.add('No Color');
    searchCardsJson['filters']['color'] = colors;
    searchCardsJson['config']['initialResetColor'] = colors;
    searchCardsJson['config']['disableColor'] = [
      ...(_allColors.toSet().difference(colors.toSet()).where((c) => c != 'No Color').toList()),
    ];
    _cardSearch = CardSearch.fromMap(searchCardsJson);

    _scrollController.addListener(() => _loadMore(ref));

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
    _scrollController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref
        .watch(cardSearchNotifierProvider(screen: _searchScreen, cardSearch: _cardSearch).notifier)
        .search(refresh: true);
  }

  void _loadMore(WidgetRef ref) {
    final offset = _scrollController.position.maxScrollExtent - _scrollController.position.pixels;
    if (offset < 100) {
      ref.watch(cardSearchNotifierProvider(screen: _searchScreen, cardSearch: _cardSearch).notifier).search();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deck$ = ref.watch(deckBuildNotifierProvider(widget.slug!));
    final search$ = ref.watch(cardSearchNotifierProvider(screen: _searchScreen, cardSearch: _cardSearch));

    Color? backgroundColor;
    Color? foregroundColor;
    if (deck$ != null) {
      final colorSplits = widget.color!.split('/');
      backgroundColor = getColor(colorSplits[0]);
      foregroundColor = backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Select Cards (${ref.read(deckBuildNotifierProvider(widget.slug!).notifier).totalCards()}/$_deckCardLimit)',
        ),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Symbols.filter_list),
                onPressed: () {
                  _scaffoldKey.currentState!.openEndDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ],
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 1,
      ),
      endDrawer: CardFilterDrawer(searchScreen: _searchScreen, cardSearch: _cardSearch),
      persistentFooterButtons:
          _session == null ? null : [CardSortHeader(searchScreen: _searchScreen, cardSearch: _cardSearch)],
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            MultiSliver(
              children: [
                if (!search$.status.isInitializing) ...[
                  for (int i = 0; i < search$.cardBatches.length; i++) ...[
                    CardGrid(
                      cards: search$.cardBatches[i],
                      searchScreen: _searchScreen,
                      cardSearch: _cardSearch,
                      columns: 3,
                      deck: deck$,
                    ),
                    if (!_isPro &&
                        (i == 0 || search$.cardBatches[i].length >= int.parse(dotenv.env['AD_BANNER_CARDS_PER_AD']!)))
                      const Padding(padding: EdgeInsets.symmetric(vertical: 2), child: Center(child: AdBanner())),
                  ],
                  if (!search$.status.hasReachedLimit && search$.cards.isNotEmpty)
                    const SliverPadding(
                      padding: EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                    ),
                  if (search$.cards.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: const Text('No cards found', style: TextStyle(fontWeight: FontWeight.w500)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
                              onPressed: () {
                                _scaffoldKey.currentState!.openEndDrawer();
                              },
                              child: Text(
                                'Update filters',
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                if (search$.status.isInitializing)
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
