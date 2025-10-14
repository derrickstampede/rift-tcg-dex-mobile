import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:collection/collection.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

import 'package:rift/themes/theme-extension.dart';

import 'package:rift/providers/vault.provider.dart';
import 'package:rift/providers/conversions.provider.dart';

import 'package:rift/widgets/cards/card-price.widget.dart';
import 'package:rift/widgets/cards/card-variant-stamp.widget.dart';
import 'package:rift/widgets/preferences/currency-dropdown.widget.dart';
import 'package:rift/widgets/subscription/subscription-lock-vertical.widget.dart';
import 'package:rift/widgets/misc/pro-badge.widget.dart';
import 'package:rift/widgets/cards/card-image.widget.dart';

import 'package:rift/models/vault.model.dart';
import 'package:rift/models/card.model.dart';

import 'package:rift/helpers/revenuecat.helper.dart';

class VaultDrawer extends ConsumerStatefulWidget {
  const VaultDrawer({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<VaultDrawer> createState() => _VaultDrawerState();
}

class _VaultDrawerState extends ConsumerState<VaultDrawer> {
  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final isSubscribed = checkIfSubscribed(customerInfo);
      if (isSubscribed) setState(() => _isPro = isSubscribed);
    });

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _showCurrencyConverterDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(height: 32, width: double.infinity),
                CurrencyDropdown(
                  refreshOnChange: false,
                  onChange: (int? selectedCountry) {
                    ref.read(conversionsNotifierProvider.notifier).updateIsLoading(true);
                    ref.read(conversionsNotifierProvider.notifier).search();
                    ref.watch(vaultBuildNotifierProvider(widget.slug).notifier).updateCountryId(selectedCountry);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPriceBreakdown({required Vault vault, required String slug}) async {
    final market = vault.markets.firstWhere((m) => m.slug == slug);
    final symbol = market.currency;
    num total = market.value;

    final conversions$ = ref.watch(conversionsNotifierProvider);
    List<CardListItem> cards = vault.cards.where((c) => c.variant == market.language.toLowerCase()).toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          children: [
                            WidgetSpan(
                              child: Container(
                                padding: const EdgeInsets.only(right: 8),
                                width: 36,
                                height: 36,
                                child: FancyShimmerImage(imageUrl: market.squareLogo, boxFit: BoxFit.contain),
                              ),
                              alignment: PlaceholderAlignment.middle,
                            ),
                            TextSpan(text: market.name.toUpperCase()),
                            WidgetSpan(
                              child: Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(left: 8),
                                child: CardVariantStamp(language: market.language.toLowerCase()),
                              ),
                              alignment: PlaceholderAlignment.middle,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: RawMaterialButton(
                          onPressed: () => Navigator.of(context).pop(),
                          elevation: 2.0,
                          shape: const CircleBorder(),
                          child: const Icon(Icons.close, size: 24.0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child:
                      cards.isNotEmpty
                          ? ListView.builder(
                            itemCount: cards.length,
                            itemBuilder: (context, i) {
                              final card = cards[i].toJson();
                              num? price = card[market.column];

                              final int? countryId = ref.watch(vaultBuildNotifierProvider(widget.slug))!.countryId;
                              if (price != null && _isPro && countryId != null) {
                                price = price * ref.read(conversionsNotifierProvider.notifier).findRate(symbol!).rate;
                              }
                              if (price != null) price *= cards[i].count;

                              return ListTile(
                                leading: SizedBox(width: 36, child: CardImage(imageUrl: cards[i].thumbnail)),
                                title: Text(
                                  cards[i].name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${cards[i].cardId} (x${cards[i].count})',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: SizedBox(
                                  width: 100,
                                  child:
                                      _isPro && ref.watch(vaultBuildNotifierProvider(widget.slug))!.countryId != null
                                          ? CardPrice(
                                            price:
                                                total *
                                                ref
                                                    .read(conversionsNotifierProvider.notifier)
                                                    .findRate(market.currency)
                                                    .rate,
                                            currency: symbol,
                                            format: market.format,
                                            fontSize: 15,
                                            replaceSymbol: conversions$.symbol,
                                            color: context.proColor.color,
                                          )
                                          : CardPrice(
                                            price: total,
                                            currency: symbol,
                                            replaceSymbol: _isPro ? conversions$.symbol : null,
                                            fontSize: 15,
                                          ),
                                ),
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              );
                            },
                          )
                          : Center(child: Text('No ${market.language.toUpperCase()} cards in vault')),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text(
                          'Total',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: CardPrice(
                            price: total,
                            currency: symbol,
                            replaceSymbol: _isPro ? conversions$.symbol : null,
                            fontSize: 15,
                          ),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vault$ = ref.watch(vaultBuildNotifierProvider(widget.slug));
    final conversions$ = ref.watch(conversionsNotifierProvider);

    if (conversions$.isLoading) {
      return const Drawer(width: 320, child: SafeArea(child: Center(child: CircularProgressIndicator())));
    }

    final List<num> totals = [];
    final totalTCGP = vault$!.totalTCGP * ref.read(conversionsNotifierProvider.notifier).findRate('USD').rate;
    final totalCM = vault$.totalCM * ref.read(conversionsNotifierProvider.notifier).findRate('EUR').rate;
    final totalYYT = vault$.totalYYT * ref.read(conversionsNotifierProvider.notifier).findRate('JPY').rate;
    totals.add(totalTCGP + totalYYT);
    totals.add(totalCM + totalYYT);

    return Drawer(
      width: 320,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Total Vault Value'.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      if (_isPro)
                        ElevatedButton.icon(
                          icon: const Icon(Symbols.currency_exchange, size: 20),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.proColor.colorContainer,
                            foregroundColor: context.proColor.onColorContainer,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          ),
                          onPressed: () {
                            if (!_isPro) {
                              showSubscribeDialog(context: context, source: 'card-view');
                              return;
                            }
                            _showCurrencyConverterDialog();
                          },
                          label: const Text('Change Currency'),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var market in vault$.markets)
                        ListTile(
                          leading: SizedBox(
                            width: 54,
                            height: 42,
                            child: FancyShimmerImage(imageUrl: market.squareLogo, boxFit: BoxFit.contain),
                          ),
                          title:
                              _isPro && vault$.countryId != null
                                  ? CardPrice(
                                    price:
                                        market.value *
                                        ref.read(conversionsNotifierProvider.notifier).findRate(market.currency).rate,
                                    currency: market.currency,
                                    format: market.format,
                                    fontSize: 18,
                                    replaceSymbol: conversions$.symbol,
                                    isCentered: false,
                                    color: context.proColor.color,
                                  )
                                  : market.isPro && !_isPro
                                  ? const ProBadge(showUnlock: true)
                                  : CardPrice(
                                    price: market.value,
                                    currency: market.currency,
                                    format: market.format,
                                    fontSize: 18,
                                    isCentered: false,
                                  ),
                          subtitle:
                              _isPro && vault$.countryId != null
                                  ? CardPrice(
                                    price: market.value,
                                    currency: market.currency,
                                    format: market.format,
                                    fontSize: 12,
                                    isCentered: false,
                                  )
                                  : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 26,
                                height: 26,
                                child: CardVariantStamp(language: market.language.toLowerCase()),
                              ),
                              if (!market.isPro || _isPro) Icon(Symbols.chevron_forward),
                            ],
                          ),
                          onTap:
                              market.isPro && !_isPro
                                  ? null
                                  : () {
                                    _showPriceBreakdown(vault: vault$, slug: market.slug);
                                  },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
