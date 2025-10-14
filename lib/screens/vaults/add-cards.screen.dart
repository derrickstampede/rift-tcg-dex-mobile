import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/models/card-search.model.dart';

import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/providers/card-search.provider.dart';
import 'package:rift/providers/vault.provider.dart';

import 'package:rift/widgets/cards/card-filter-drawer.widget.dart';
import 'package:rift/widgets/cards/card-grid.widget.dart';
import 'package:rift/widgets/cards/card-sort-header.widget.dart';
import 'package:rift/widgets/ads/ad-banner.widget.dart';

class AddCardsScreen extends ConsumerStatefulWidget {
  const AddCardsScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<AddCardsScreen> createState() => _AddCardsScreenState();
}

class _AddCardsScreenState extends ConsumerState<AddCardsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  Session? _session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  final _searchScreen = 'add-cards';
  final CardSearch _cardSearch = CardSearch(
    cards: [],
    cardBatches: [],
    status: CardSearchStatus(
      isInitializing: true,
      isLoading: false,
      hasReachedLimit: false,
      showOwned: true,
      view: 'name',
      orderBy: 'set',
      isAscending: false,
      showCollectionDisabled: false,
      showTypeRequired: false,
      showColorRequired: false,
      selectLeader: false,
      addToDeck: false,
      addToDeckSelect: false,
      addToVault: true,
    ),
    filters: CardSearchFilters(
      collection: true,
      name: null,
      setId: null,
      rarity: [],
      language: [],
      type: [],
      color: [],
      domain: [],
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

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() => _loadMore(ref));

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
      });
    });

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final isSubscribed = checkIfSubscribed(customerInfo);
      if (isSubscribed) setState(() => _isPro = isSubscribed);
    });
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
    final search$ = ref.watch(cardSearchNotifierProvider(screen: _searchScreen, cardSearch: _cardSearch));
    final vault$ = ref.watch(vaultBuildNotifierProvider(widget.slug));

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Add Cards"),
        elevation: 1,
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
      ),
      endDrawer: CardFilterDrawer(searchScreen: _searchScreen, cardSearch: _cardSearch),
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
                      vault: vault$,
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
                              child: const Text(
                                'No cards found in collection',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
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
      persistentFooterButtons:
          _session == null ? null : [CardSortHeader(searchScreen: _searchScreen, cardSearch: _cardSearch)],
    );
  }
}
