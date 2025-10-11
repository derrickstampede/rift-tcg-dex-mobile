import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:material_symbols_icons/symbols.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:badges/badges.dart' as badges;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rift/main.dart';

import 'package:rift/providers/card-search.provider.dart';
import 'package:rift/providers/alerts.provider.dart';

import 'package:rift/models/card-search.model.dart';

// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/widgets/cards/card-filter-drawer.widget.dart';
import 'package:rift/widgets/cards/card-grid.widget.dart';
import 'package:rift/widgets/cards/card-sort-header.widget.dart';
import 'package:rift/widgets/ads/ad-banner.widget.dart';

class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key, required this.cardSearch, required this.searchScreen});

  final CardSearch cardSearch;
  final String searchScreen;

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  Session? session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      _loadMore(ref);
    });

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        session = data.session;
      });
    });

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed && mounted) setState(() => _isPro = isSubscribed);
    // });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref
        .watch(cardSearchNotifierProvider(screen: widget.searchScreen, cardSearch: widget.cardSearch).notifier)
        .search(refresh: true);
  }

  void _loadMore(WidgetRef ref) {
    final offset = _scrollController.position.maxScrollExtent - _scrollController.position.pixels;
    if (offset < 100) {
      ref
          .watch(cardSearchNotifierProvider(screen: widget.searchScreen, cardSearch: widget.cardSearch).notifier)
          .search();
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final search$ = ref.watch(cardSearchNotifierProvider(screen: widget.searchScreen, cardSearch: widget.cardSearch));
    final alerts$ = ref.watch(alertsNotifierProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading:
            session != null
                ? PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      for (int i = 0; i < alerts$.alerts.length; i++)
                        PopupMenuItem<int>(
                          value: i,
                          padding: const EdgeInsets.all(0),
                          child: ListTile(
                            title: Text(
                              alerts$.alerts[i].title,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            subtitle: Text(alerts$.alerts[i].subtitle, style: const TextStyle(fontSize: 12)),
                            trailing:
                                !alerts$.alerts[i].hasViewed
                                    ? Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.error,
                                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                                      ),
                                    )
                                    : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      if (alerts$.alerts.isEmpty)
                        const PopupMenuItem<int>(
                          value: -1,
                          child: ListTile(
                            title: Text('No notifications', style: TextStyle(fontSize: 14)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                    ];
                  },
                  onSelected: (value) {
                    if (value < 0) return;
                    ref.watch(alertsNotifierProvider.notifier).viewAlert(value);
                    _launchUrl(alerts$.alerts[value].link);
                  },
                  icon:
                      alerts$.unread > 0
                          ? badges.Badge(
                            badgeContent: Text(
                              alerts$.unread.toString(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onError,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            badgeStyle: badges.BadgeStyle(
                              badgeColor: Theme.of(context).colorScheme.error,
                              padding: const EdgeInsets.all(6),
                            ),
                            child: const Icon(Symbols.notifications),
                          )
                          : const Icon(Symbols.notifications),
                )
                : null,
        title: const Text("Search Cards"),
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
          // Builder(
          //   builder: (BuildContext context) {
          //     return IconButton(
          //       icon: const Icon(
          //         Symbols.ads_click,
          //       ),
          //       onPressed: _showAd,
          //       tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          //     );
          //   },
          // ),
        ],
      ),
      persistentFooterButtons: [CardSortHeader(searchScreen: widget.searchScreen, cardSearch: widget.cardSearch)],
      endDrawer: CardFilterDrawer(searchScreen: widget.searchScreen, cardSearch: widget.cardSearch),
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
                      searchScreen: widget.searchScreen,
                      cardSearch: widget.cardSearch,
                      columns: 3,
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
