import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

import 'package:rift/main.dart';

import 'package:rift/themes/theme-extension.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/stock.model.dart' as stock_model;
import 'package:rift/models/market.model.dart';

import 'package:rift/helpers/stock.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/widgets/cards/card-image.widget.dart';
import 'package:rift/widgets/cards/card-price.widget.dart';
import 'package:rift/widgets/stocks/stock-graph.widget.dart';
import 'package:rift/widgets/auth/signin-button.widget.dart';
// import 'package:rift/widgets/ads/ad-banner.widget.dart';
import 'package:rift/widgets/misc/pro-badge.widget.dart';
import 'package:rift/widgets/subscription/subscription-box-sm.widget.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key, required this.card, required this.conversions, required this.markets});

  final CardItemView card;
  final CardConversions conversions;
  final List<CardMarket> markets;

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  Session? session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  bool _isLoading = true;
  List<stock_model.StockGraph> _graphs = [];

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);
  final List<stock_model.StockAdjustedPrice> _adjustedPrices = [];

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        session = data.session;
      });
    });

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed && mounted) setState(() => _isPro = isSubscribed);
    // });
  }

  @override
  void didChangeDependencies() {
    setState(() => _isLoading = true);
    _fetchGraph();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  void _fetchGraph() async {
    final response = await fetchGraph(cardId: widget.card.id);
    response.fold(
      (l) {
        setState(() {
          _graphs = l['graphs'];
          for (var i = 0; i < widget.markets.length; i++) {
            _adjustedPrices.add(
              stock_model.StockAdjustedPrice(
                market: widget.markets[i].slug,
                price:
                    widget.conversions.adjustedPrices.where((a) => a.market == widget.markets[i].slug).isNotEmpty
                        ? widget.conversions.adjustedPrices.firstWhere((a) => a.market == widget.markets[i].slug).price
                        : null,
              ),
            );
          }

          if (_isPro) {
            _adjustPrices();
          }

          _isLoading = false;
        });

        logEvent(
          name: 'card_view_stock',
          parameters: {'id': widget.card.id, 'card_id': widget.card.cardId, 'name': widget.card.name},
        );
      },
      (r) {
        // TODO error handling
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  void _adjustPrices() {
    for (var i = 0; i < _graphs.length; i++) {
      final graph = _graphs[i];
      if (_adjustedPrices.where((a) => a.market == graph.slug).isEmpty ||
          _adjustedPrices.firstWhere((a) => a.market == graph.slug).price == null) {
        continue;
      }

      final converter = _graphs[i].stocks.last.price / _adjustedPrices.firstWhere((a) => a.market == graph.slug).price!;
      final List<stock_model.Spot> adjSpots = [];
      final List<stock_model.Tooltip> adjTooltips = [];
      for (var j = 0; j < graph.spots.length; j++) {
        adjSpots.add(stock_model.Spot(x: graph.spots[j].x, y: (graph.spots[j].y / converter)));
        adjTooltips.add(
          stock_model.Tooltip(price: (graph.spots[j].y / converter).toString(), date: graph.tooltips[j].date),
        );
      }

      setState(() {
        _graphs[i].yMax = (_graphs[i].yMax / converter).round();
        _graphs[i].yMin = (_graphs[i].yMin / converter).round();
        _graphs[i].spots = adjSpots;
        _graphs[i].tooltips = adjTooltips;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Trend'),
        elevation: 1,
        // bottom: !_isPro ? const PreferredSize(preferredSize: Size.fromHeight(50.0), child: AdBanner()) : null,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  ListView(
                    children: [
                      ListTile(
                        leading: SizedBox(width: 50, child: CardImage(imageUrl: widget.card.image)),
                        title: Text.rich(
                          TextSpan(
                            text: widget.card.name,
                            children: <InlineSpan>[if (widget.card.isParallel) const TextSpan(text: ' (Parallel)')],
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        subtitle: Text(widget.card.cardId),
                        onTap: null,
                      ),
                      for (var i = 0; i < _graphs.length; i++)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: SizedBox(
                                    width: 86,
                                    height: 42,
                                    child: FancyShimmerImage(imageUrl: _graphs[i].logo, boxFit: BoxFit.contain),
                                  ),
                                ),
                                !_isPro && _graphs[i].isPro
                                    ? const ProBadge()
                                    : Column(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Center(child: Text('Current Price:', style: TextStyle(fontSize: 16))),
                                        ),
                                        if (_isPro &&
                                            _adjustedPrices.firstWhere((a) => a.market == _graphs[i].slug).price !=
                                                null)
                                          CardPrice(
                                            price:
                                                _adjustedPrices.firstWhere((a) => a.market == _graphs[i].slug).price!,
                                            currency:
                                                widget.markets.firstWhere((a) => a.slug == _graphs[i].slug).currency,
                                            fontSize: 18,
                                            format: _graphs[i].format,
                                            replaceSymbol: widget.conversions.symbol,
                                            color: context.proColor.color,
                                          ),
                                        CardPrice(
                                          price: _graphs[i].stocks.last.price,
                                          currency: _graphs[i].currency,
                                          format: _graphs[i].format,
                                          fontSize:
                                              _isPro &&
                                                      _adjustedPrices
                                                              .firstWhere((a) => a.market == _graphs[i].slug)
                                                              .price !=
                                                          null
                                                  ? 14
                                                  : 18,
                                        ),
                                      ],
                                    ),
                              ],
                            ),
                            !_isPro && _graphs[i].isPro
                                ? const Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 24),
                                      child: SubscriptionBoxSm(source: 'cardmarket-graph'),
                                    ),
                                    SizedBox(height: 24),
                                  ],
                                )
                                : Stack(
                                  children: <Widget>[
                                    AspectRatio(
                                      aspectRatio: 1.70,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 36, left: 12, top: 24, bottom: 12),
                                        child: CardStockGraph(graph: _graphs[i]),
                                      ),
                                    ),
                                  ],
                                ),
                          ],
                        ),
                      if (_graphs.isEmpty)
                        const SizedBox(height: 300, child: Center(child: Text('Trend Graph not available'))),
                    ],
                  ),
                  if (session == null)
                    Positioned.fill(
                      top: 0,
                      left: 0,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                          child: Container(color: Colors.black.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  if (session == null) const Positioned.fill(top: 0, left: 0, child: SigninButton()),
                ],
              ),
    );
  }
}
