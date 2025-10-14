import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/providers/card-search.provider.dart';

import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/models/card-search.model.dart';
import 'package:rift/models/card.model.dart';

import 'package:rift/widgets/cards/card-filter-drawer.widget.dart';
import 'package:rift/widgets/cards/card-grid.widget.dart';
import 'package:rift/widgets/cards/card-sort-header.widget.dart';
import 'package:rift/widgets/ads/ad-banner.widget.dart';

class SwitchBattlefieldScreen extends ConsumerStatefulWidget {
  const SwitchBattlefieldScreen({super.key, required this.battlefieldId});

  final num battlefieldId;

  @override
  ConsumerState<SwitchBattlefieldScreen> createState() => _SwitchBattlefieldScreenState();
}

class _SwitchBattlefieldScreenState extends ConsumerState<SwitchBattlefieldScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  Session? _session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  final _searchScreen = 'switch-battlefield';
  late final CardSearch _cardSearch;
  final _allColors = ['Red', 'Green', 'Blue', 'Orange', 'Purple', 'Yellow', 'No Color'];

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  late num _currentBattlefieldId;

  @override
  void initState() {
    super.initState();

    _currentBattlefieldId = widget.battlefieldId;
    _cardSearch = CardSearch(
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
        selectLeader: true,
        addToDeck: false,
        addToDeckSelect: false,
        addToVault: false,
        switchBattlefield: _currentBattlefieldId,
      ),
      filters: CardSearchFilters(
        collection: false,
        name: null,
        setId: null,
        rarity: [],
        language: [],
        type: ["Battlefield"],
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
        disableType: const [
          "Champion Unit",
          "Legend",
          "Signature Spell",
          "Signature Unit",
          "Unit",
          "Spell",
          "Gear",
          "Rune",
          "Token Unit",
        ],
        disableColor: _allColors.toList(),
        initialResetColor: [],
        initialResetType: const [],
        initialResetRarity: const [],
        requireOneType: false,
        requireOneColor: false,
      ),
      symbol: null,
    );

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

  void _selectChampion({required CardListItem card}) {
    Navigator.pop(context, card);
  }

  @override
  Widget build(BuildContext context) {
    final search$ = ref.watch(cardSearchNotifierProvider(screen: _searchScreen, cardSearch: _cardSearch));

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Switch Battlefield Card'),
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
      persistentFooterButtons:
          _session == null ? null : [CardSortHeader(searchScreen: _searchScreen, cardSearch: _cardSearch)],
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
                      select: _selectChampion,
                    ),
                    if (!_isPro &&
                        (i == 0 || search$.cardBatches[i].length >= int.parse(dotenv.env['AD_BANNER_CARDS_PER_AD']!)))
                      Padding(
                        key: ValueKey('ad_banner_switch_battlefield_${i}_${DateTime.now().millisecondsSinceEpoch}'),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Center(child: AdBanner(key: ValueKey('ad_banner_switch_battlefield_inner_${i}_${DateTime.now().millisecondsSinceEpoch}'))),
                      ),
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
