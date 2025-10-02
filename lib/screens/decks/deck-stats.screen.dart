import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/models/deck.model.dart';
import 'package:rift/models/note.model.dart';

import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/deck.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/widgets/misc/subheader.widget.dart';
import 'package:rift/widgets/notes/note-box.widget.dart';
import 'package:rift/widgets/subscription/subscription-lock-vertical.widget.dart';

class DeckStatsScreen extends StatefulWidget {
  const DeckStatsScreen({super.key, required this.deck, required this.foregroundColor, required this.backgroundColor});

  final Deck deck;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  State<DeckStatsScreen> createState() => _DeckStatsScreenState();
}

class _DeckStatsScreenState extends State<DeckStatsScreen> {
  bool _isLoading = true;
  DeckStats? _stats;
  Note? _note;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    super.initState();

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed) setState(() => _isPro = isSubscribed);

    //   _findStats();
    // });
    _findStats();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _findStats() async {
    if (!_isPro) return;

    setState(() => _isLoading = true);
    final response = await findDeckStats(widget.deck.slug);
    response.fold(
      (l) {
        setState(() {
          _stats = l['stats'];
          _stats!.rarity.sort((a, b) => b.count.compareTo(a.count));
          _stats!.effect.sort((a, b) => b.count.compareTo(a.count));
          _stats!.type.sort((a, b) => b.count.compareTo(a.count));

          _note = l['note'];

          _isLoading = false;

          if (_isPro) logEvent(name: 'deck_stats', parameters: {'id': widget.deck.id});
        });
      },
      (r) {
        // TODO error handling
        print(r);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _findStats(),
        child: SafeArea(
          child:
              _isPro
                  ? !_isLoading
                      ? ListView(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        children: [
                          NoteBox(note: _note, type: 'deck', typeId: widget.deck.id.toString()),
                          widget.deck.cards.length > 1
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  const Subheader(text: "Cost Curve"),
                                  const SizedBox(height: 28),
                                  AspectRatio(
                                    aspectRatio: 2.5,
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 16),
                                      child: BarChart(
                                        BarChartData(
                                          barGroups: [
                                            ..._stats!.cost
                                                .map(
                                                  (c) => BarChartGroupData(
                                                    x: int.parse(c.label),
                                                    barRods: [
                                                      BarChartRodData(
                                                        toY: c.count.toDouble(),
                                                        width: 16,
                                                        color: getColor(widget.deck.leader.color!),
                                                      ),
                                                    ],
                                                    showingTooltipIndicators: [0],
                                                  ),
                                                )
                                                .toList(),
                                          ],
                                          gridData: const FlGridData(show: false),
                                          borderData: FlBorderData(
                                            border: const Border(
                                              left: BorderSide(width: 1),
                                              bottom: BorderSide(width: 1),
                                            ),
                                          ),
                                          alignment: BarChartAlignment.spaceEvenly,
                                          barTouchData: BarTouchData(
                                            enabled: false,
                                            touchTooltipData: BarTouchTooltipData(
                                              getTooltipColor: (group) => Colors.transparent,
                                              tooltipPadding: EdgeInsets.zero,
                                              tooltipMargin: 4,
                                              getTooltipItem: (
                                                BarChartGroupData group,
                                                int groupIndex,
                                                BarChartRodData rod,
                                                int rodIndex,
                                              ) {
                                                return BarTooltipItem(
                                                  rod.toY > 0 ? rod.toY.round().toString() : '',
                                                  TextStyle(
                                                    color: DefaultTextStyle.of(context).style.color,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          titlesData: const FlTitlesData(
                                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(reservedSize: 80, showTitles: true, interval: 5),
                                            ),
                                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Subheader(text: "Cards with Effects", textAlign: TextAlign.center),
                                            FittedBox(
                                              child: RichText(
                                                text: TextSpan(
                                                  text: _stats!.withEffect.toString(),
                                                  style: TextStyle(
                                                    color: Theme.of(context).textTheme.bodyMedium!.color,
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: " / ${_stats!.count}",
                                                      style: TextStyle(
                                                        color: Theme.of(context).textTheme.bodyMedium!.color,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Subheader(text: "Types"),
                                  RichText(
                                    text: TextSpan(
                                      text: '',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium!.color,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      children: [..._stats!.type.map((e) => statPill(e))],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Subheader(text: "Rarities"),
                                  RichText(
                                    text: TextSpan(
                                      text: '',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium!.color,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      children: [..._stats!.rarity.map((e) => statPill(e))],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Subheader(text: "Power"),
                                  RichText(
                                    text: TextSpan(
                                      text: '',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium!.color,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      children: [..._stats!.power.map((e) => statPill(e))],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Subheader(text: "Specified Cost"),
                                  RichText(
                                    text: TextSpan(
                                      text: '',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium!.color,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      children: [..._stats!.specifiedCost.map((e) => statPill(e))],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Subheader(text: "Effects"),
                                  RichText(
                                    text: TextSpan(
                                      text: '',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium!.color,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      children: [..._stats!.effect.map((e) => statPill(e)).toList()],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              )
                              : const SizedBox(
                                height: 200,
                                child: Center(child: Text('No stats to show since there\'s no cards yet')),
                              ),
                        ],
                      )
                      : const Center(child: CircularProgressIndicator())
                  : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: SubscriptionLockVertical(source: 'deck-stats')),
                  ),
        ),
      ),
    );
  }

  WidgetSpan statPill(DeckStatCount e) {
    return WidgetSpan(
      child: Container(
        padding: const EdgeInsets.only(right: 8),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.backgroundColor, style: BorderStyle.solid, width: 1),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: widget.backgroundColor, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    '${e.count}',
                    style: TextStyle(fontWeight: FontWeight.w700, color: widget.foregroundColor),
                  ),
                ),
              ),
              TextSpan(
                text: e.label,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
