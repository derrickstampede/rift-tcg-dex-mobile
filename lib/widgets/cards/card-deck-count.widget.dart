import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/deck.model.dart';

import 'package:rift/providers/deck.provider.dart';

class CardDeckCount extends ConsumerWidget {
  const CardDeckCount({
    super.key,
    required this.deck,
    required this.card,
    required this.foregroundColor,
  });

  final Deck deck;
  final CardListItem card;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deck$ = ref.watch(deckBuildNotifierProvider(deck.slug));
    if (deck$ == null) {
      return const SizedBox();
    }

    return Text(
      card.rarity != "L" ? ref.read(deckBuildNotifierProvider(deck.slug).notifier).cardCount(card.id).toString() : "L",
      style: TextStyle(color: foregroundColor, fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
