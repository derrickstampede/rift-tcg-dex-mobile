import 'package:flutter/material.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rift/models/card.model.dart';

import 'package:rift/widgets/misc/pro-badge.widget.dart';
import 'package:rift/widgets/cards/card-price.widget.dart';

import 'package:rift/providers/market.provider.dart';

// import 'package:rift/helpers/revenuecat.helper.dart';

class CardLabel extends ConsumerStatefulWidget {
  const CardLabel({super.key, required this.card, required this.label, this.fontSize = 14, this.symbol});

  final CardListItem card;
  final String label;
  final double? fontSize;
  final String? symbol;

  @override
  ConsumerState<CardLabel> createState() => _CardLabelState();
}

class _CardLabelState extends ConsumerState<CardLabel> {
  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed) setState(() => _isPro = isSubscribed);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final markets$ = ref.read(marketProvider);

    TextStyle style = TextStyle(fontWeight: FontWeight.w500, fontSize: widget.fontSize, color: Colors.yellow[300]);
    Widget labelWidget = Text('-', maxLines: 1, overflow: TextOverflow.ellipsis, style: style);

    if (widget.label == 'name') {
      labelWidget = Text(widget.card.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }
    if (widget.label == 'set') {
      labelWidget = Text(widget.card.set!.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }
    if (widget.label == 'energy') {
      if (widget.card.energy != null) {
        labelWidget = Text(
          'ENGY: ${widget.card.energy.toString()}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        );
      }
    }
    if (widget.label == 'might') {
      if (widget.card.might != null) {
        labelWidget = Text(
          'MGHT: ${widget.card.might.toString()}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        );
      }
    }
    
    if (widget.label == 'domain') {
      if (widget.card.domain != null) {
        labelWidget = Text(widget.card.domain!, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
      }
    }
    if (widget.label == 'rarity') {
      if (widget.card.rarity != null) {
        labelWidget = Text(widget.card.rarity!, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
      }
    }

    markets$.whenData((markets) {
      for (var market in markets) {
        if (widget.label == market.column) {
          num? showPrice;
          String? showSymbol;

          final card = widget.card.toJson();
          showPrice = card[convertMarketSlug(market.column)];

          if (showPrice != null) {
            if (_isPro) {
              final marketConversion = widget.card.conversions?.where((c) => c.market == market.slug).toList();
              if (marketConversion != null && marketConversion.isNotEmpty) {
                showPrice = marketConversion[0].price;
              }
              showSymbol = widget.symbol;
            }

            labelWidget = CardPrice(
              price: showPrice,
              currency: market.currency,
              fontSize: widget.fontSize,
              color: Colors.yellow[300],
              replaceSymbol: showSymbol,
              format: market.format,
            );

            if (market.isPro && !_isPro) {
              labelWidget = const Padding(padding: EdgeInsets.symmetric(vertical: 2), child: ProBadge());
            }
          }
        }
      }
    });


    return Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Center(child: labelWidget));
  }

  String convertMarketSlug(String slug) {
    final parts = slug.split('-');
    if (parts.length != 2) return slug;

    final first = parts[0];
    final second = parts[1].substring(0, 1).toUpperCase() + parts[1].substring(1);
    return first + second;
  }
}
