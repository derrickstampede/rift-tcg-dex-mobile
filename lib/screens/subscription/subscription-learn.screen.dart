import 'package:flutter/material.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/themes/theme-extension.dart';

import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/preference.helper.dart';

import 'package:rift/models/preference.model.dart';

class SubscriptionLearn extends StatefulWidget {
  const SubscriptionLearn({super.key});

  @override
  State<SubscriptionLearn> createState() => _SubscriptionLearnState();
}

class _SubscriptionLearnState extends State<SubscriptionLearn> {
  bool _isLoading = true;
  List<PreferenceCountryOption> _countries = [];

  @override
  void initState() {
    super.initState();

    _fetchOptions();
    logEvent(name: 'subscription_learn_more');
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchOptions() async {
    final response = await getPreferenceOptions();
    response.fold(
      (l) {
        setState(() {
          _countries = l['countries'];
          setState(() {
            _isLoading = false;
          });
        });
      },
      (r) {
        setState(() {
          _isLoading = false;
        });
        // TODO error handling
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final subVaultLimit = int.parse(dotenv.env['SUBSCRIBED_VAULT_LIMIT']!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PRO Features'),
        backgroundColor: context.successColor.color,
        foregroundColor: Colors.black,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SubscriptionHeader('1. Increase Decks and Vaults to $subVaultLimit'),
                const SubscriptionDescription('Store more decks and vaults!'),
                const SizedBox(height: 12),
                const SubscriptionHeader('2. Access Currency Converter'),
                const SubscriptionDescription(
                  'Automatically convert TCGPlayer, Yuyutei, (CardMarket soon) card prices to your local currency making it a lot easier to monitor, buy, sell, and trade cards! (Conversions are updated daily)',
                ),
                const SizedBox(height: 2),
                SubscriptionDescription(
                  '**Available currencies listed at the bottom',
                  style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        style: BorderStyle.solid,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: FancyShimmerImage(
                      imageUrl:
                          'https://optcg.sfo2.cdn.digitaloceanspaces.com/assets/pro/pro-ios-currency-converter.gif',
                      boxFit: BoxFit.contain,
                      height: 650,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const SubscriptionHeader('3. Add Notes to Cards and Decks'),
                const SubscriptionDescription(
                  'Attach a note to a card or deck! For cards, it could be how much you bought the card or how to play it. For decks, it could be which deck is this strong against or what is the best hand at the start of a match.',
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        style: BorderStyle.solid,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: FancyShimmerImage(
                      imageUrl: 'https://optcg.sfo2.cdn.digitaloceanspaces.com/assets/pro/pro-ios-notes.gif',
                      boxFit: BoxFit.contain,
                      height: 650,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const SubscriptionHeader('4. View Deck Statistics'),
                const SubscriptionDescription(
                  'Acquire in-depth information about your deck - analyze cost curves, number of counters and triggers, what are the effects and more!',
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        style: BorderStyle.solid,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: FancyShimmerImage(
                      imageUrl: 'https://optcg.sfo2.cdn.digitaloceanspaces.com/assets/pro/pro-ios-deck-stats.gif',
                      boxFit: BoxFit.contain,
                      height: 650,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const SubscriptionHeader('5. No Ads'),
                const SubscriptionDescription('Remove the annoying ads!'),
                const SizedBox(height: 12),
                SubscriptionDescription(
                  '**List of currencies',
                  style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 4),
                !_isLoading
                    ? Table(
                      border: TableBorder.all(color: Theme.of(context).colorScheme.surfaceVariant),
                      children: [
                        const TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Country', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Currency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                        ..._countries
                            .map(
                              (c) => TableRow(
                                children: [
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(c.name, style: const TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(c.currency, style: const TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ],
                    )
                    : const Center(child: CircularProgressIndicator()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionHeader extends StatelessWidget {
  const SubscriptionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}

class SubscriptionDescription extends StatelessWidget {
  const SubscriptionDescription(this.text, {super.key, this.style = const TextStyle(fontSize: 16)});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style);
  }
}
