import 'package:flutter/material.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/deck.model.dart';
import 'package:rift/models/vault.model.dart';
import 'package:rift/models/card-search.model.dart';

import 'package:rift/widgets/cards/card-grid-item.widget.dart';

class CardGrid extends StatelessWidget {
  const CardGrid({
    super.key,
    required this.cards,
    required this.searchScreen,
    required this.cardSearch,
    required this.columns,
    this.deck,
    this.vault,
    this.showAddRemove = false,
    this.showVaultInfo = false,
    this.select,
  });

  final List<CardListItem> cards;
  final String searchScreen;
  final CardSearch cardSearch;
  final int columns;
  final Deck? deck;
  final Vault? vault;
  final bool showAddRemove;
  final bool showVaultInfo;
  final Function({required CardListItem card})? select;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
        padding: const EdgeInsets.all(5),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return RepaintBoundary(
                child: CardGridItem(
                    card: cards[index],
                    searchScreen: searchScreen,
                    cardSearch: cardSearch,
                    showLabel: true,
                    showAddRemove: showAddRemove,
                    showVaultInfo: showVaultInfo,
                    deck: deck,
                    vault: vault,
                    select: select),
              );
            }, 
            childCount: cards.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns, mainAxisSpacing: 5, crossAxisSpacing: 5, childAspectRatio: 300 / 420),
        ));
  }
}
