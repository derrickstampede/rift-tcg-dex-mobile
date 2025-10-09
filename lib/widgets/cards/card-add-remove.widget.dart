import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/deck.model.dart';

import 'package:rift/providers/deck.provider.dart';
import 'package:rift/providers/decks.provider.dart';

import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/card.helper.dart';

import 'package:rift/widgets/cards/card-deck-count.widget.dart';

import 'package:rift/helpers/card-options.helper.dart';

class CardAddRemove extends ConsumerStatefulWidget {
  const CardAddRemove({super.key, required this.card, required this.deck});

  final CardListItem card;
  final Deck deck;

  @override
  ConsumerState<CardAddRemove> createState() => _CardAddRemoveState();
}

class _CardAddRemoveState extends ConsumerState<CardAddRemove> {
  Future<void> _getLeaders(
    String deckSlug,
    int currentLeaderId,
    String cardId,
    Color backgroundColor,
    Color foregroundColor,
  ) async {
    final cardResponse = await findCardByCardId(cardId);
    return cardResponse.fold(
      (l) async {
        final List<CardItemView> cards = l['cards'];

        final response = await switchLegendModal(
          context,
          deckSlug,
          currentLeaderId,
          cards,
          backgroundColor,
          foregroundColor,
        );
        if (response != null) {
          ref.watch(deckBuildNotifierProvider(deckSlug).notifier).find(deckSlug);
          ref.read(deckListNotifierProvider.notifier).updateLeader(deckSlug, response);
        }
      },
      (r) {
        print(r);
      },
    );
  }

  Future<void> _getChampions(
    String deckSlug,
    int currenChampionId,
    String cardId,
    Color backgroundColor,
    Color foregroundColor,
  ) async {
    final cardResponse = await findCardByCardId(cardId);
    return cardResponse.fold(
      (l) async {
        final List<CardItemView> cards = l['cards'];

        final response = await switchChampionModal(
          context,
          deckSlug,
          currenChampionId,
          cards,
          backgroundColor,
          foregroundColor,
        );
        if (response != null) {
          ref.watch(deckBuildNotifierProvider(deckSlug).notifier).find(deckSlug);
          ref.read(deckListNotifierProvider.notifier).updateLeader(deckSlug, response);
        }
      },
      (r) {
        print(r);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deck$ = ref.watch(deckBuildNotifierProvider(widget.deck.slug));
    if (deck$ == null) {
      return const SizedBox();
    }

    Color backgroundColor = Theme.of(context).colorScheme.secondary;
    Color foregroundColor = Theme.of(context).colorScheme.onSecondary;
    final colorSplits = deck$.legend.color!.split('/');
    backgroundColor = getColor(colorSplits[0]);
    foregroundColor = backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.card.type != "Legend" && widget.card.type != "Champion Unit")
            SizedBox(
              width: 42,
              child: RawMaterialButton(
                onPressed: () {
                  final cardCount = ref
                      .read(deckBuildNotifierProvider(widget.deck.slug).notifier)
                      .removeCard(widget.card);
                  if (cardCount != null) {
                    ref.read(deckListNotifierProvider.notifier).updateCount(widget.deck.slug, cardCount);
                  }
                  ref.read(deckListNotifierProvider.notifier).updateUpdatedAt(widget.deck.slug);
                },
                elevation: 2.0,
                fillColor: foregroundColor.withOpacity(0.9),
                padding: const EdgeInsets.all(8.0),
                shape: const CircleBorder(),
                child: Icon(Symbols.remove, size: 24.0, color: backgroundColor),
              ),
            ),
          if (widget.card.type == "Legend")
            SizedBox(
              width: 42,
              child: RawMaterialButton(
                onPressed: () async {
                  _getLeaders(widget.deck.slug, widget.card.id, widget.card.cardId, backgroundColor, foregroundColor);
                },
                elevation: 2.0,
                fillColor: foregroundColor.withOpacity(0.9),
                padding: const EdgeInsets.all(8.0),
                shape: const CircleBorder(),
                child: Icon(Symbols.loop, size: 24.0, color: backgroundColor),
              ),
            ),
          if (widget.card.type == "Champion Unit")
            SizedBox(
              width: 42,
              child: RawMaterialButton(
                onPressed: () async {
                  _getChampions(widget.deck.slug, widget.card.id, widget.card.cardId, backgroundColor, foregroundColor);
                },
                elevation: 2.0,
                fillColor: foregroundColor.withOpacity(0.9),
                padding: const EdgeInsets.all(8.0),
                shape: const CircleBorder(),
                child: Icon(Symbols.loop, size: 24.0, color: backgroundColor),
              ),
            ),
          SizedBox(
            width: 32,
            child: RawMaterialButton(
              onPressed: null,
              elevation: 2.0,
              fillColor: backgroundColor,
              padding: const EdgeInsets.all(2),
              shape: const CircleBorder(),
              child: CardDeckCount(card: widget.card, deck: widget.deck, foregroundColor: foregroundColor),
            ),
          ),
          if (widget.card.type != "Legend" && widget.card.type != "Champion Unit")
            SizedBox(
              width: 42,
              child: RawMaterialButton(
                onPressed: () {
                  final cardCount = ref.read(deckBuildNotifierProvider(widget.deck.slug).notifier).addCard(widget.card);
                  if (cardCount != null) {
                    ref.read(deckListNotifierProvider.notifier).updateCount(widget.deck.slug, cardCount);
                  }
                  ref.read(deckListNotifierProvider.notifier).updateUpdatedAt(widget.deck.slug);
                },
                elevation: 2.0,
                fillColor: foregroundColor.withOpacity(0.9),
                padding: const EdgeInsets.all(8.0),
                shape: const CircleBorder(),
                child: Icon(Symbols.add, size: 24.0, color: backgroundColor),
              ),
            ),
        ],
      ),
    );
  }
}
