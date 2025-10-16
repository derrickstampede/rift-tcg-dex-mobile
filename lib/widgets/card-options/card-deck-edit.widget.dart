import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:rift/providers/deck.provider.dart';
import 'package:rift/providers/decks.provider.dart';
import 'package:rift/providers/card-search.provider.dart';

import 'package:rift/widgets/cards/card-image.widget.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/card-search.model.dart';

class CardDeckEdit extends ConsumerStatefulWidget {
  const CardDeckEdit({super.key, required this.card, required this.slug});

  final CardItemView card;
  final String slug;

  @override
  ConsumerState<CardDeckEdit> createState() => _CardDeckEditState();
}

class _CardDeckEditState extends ConsumerState<CardDeckEdit> {
  final int _deckCardLimit = int.parse(dotenv.env['CARD_PER_DECK_LIMIT']!);
  late final CardListItem _selectedCard;

  final _searchScreen = 'deck-edit';
  final CardSearch _cardSearch = CardSearch(
    cards: [],
    cardBatches: [],
    status: CardSearchStatus(
      isInitializing: false,
      isLoading: false,
      hasReachedLimit: true,
      showOwned: false,
      view: 'name',
      orderBy: 'set',
      isAscending: false,
      showCollectionDisabled: false,
      showTypeRequired: false,
      showColorRequired: false,
      selectLeader: false,
      addToDeck: true,
      addToDeckSelect: false,
      addToVault: false,
    ),
    filters: CardSearchFilters(
      collection: false,
      name: null,
      setId: null,
      rarity: [],
      language: [],
      type: [],
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
      disableType: const [],
      disableColor: const [],
      initialResetColor: const [],
      initialResetType: const [],
      initialResetRarity: const [],
      requireOneType: false,
      requireOneColor: false,
    ),
    symbol: null,
  );

  @override
  void initState() {
    super.initState();

    _selectedCard = CardListItem(
      id: widget.card.id,
      cardId: widget.card.cardId,
      name: widget.card.name,
      slug: widget.card.slug,
      set: null,
      thumbnail: widget.card.thumbnail,
      backThumbnail: widget.card.backThumbnail,
      type: widget.card.type,
      color: widget.card.color,
      rarity: widget.card.rarity,
      domain: widget.card.domain,
      energy: widget.card.energy,
      might: widget.card.might,
      print: widget.card.print,
      orientation: widget.card.orientation,
      power: widget.card.power,
      variant: null,
      variants: [],
      cardsProfiles: widget.card.cardsProfiles,
      conversions: [],
      maxDeckCards: widget.card.maxDeckCards,
      note: null,
      count: 0,
      yytJp: widget.card.yytJp,
      tcgpEn: widget.card.tcgpEn,
      cmEn: widget.card.cmEn,
      cmJp: widget.card.cmJp,
    );
  }

  final Widget loadingWidget = const Padding(
    padding: EdgeInsets.symmetric(vertical: 32),
    child: CircularProgressIndicator(),
  );

  void _add(CardListItem card) {
    final cardCount = ref.read(deckBuildNotifierProvider(widget.slug).notifier).addCard(card);
    if (cardCount != null) {
      ref.read(deckListNotifierProvider.notifier).updateCount(widget.slug, cardCount);
    }
    ref.read(deckListNotifierProvider.notifier).updateUpdatedAt(widget.slug);
  }

  void _remove(CardListItem card) {
    final cardCount = ref.read(deckBuildNotifierProvider(widget.slug).notifier).removeCard(card);
    if (cardCount != null) {
      ref.read(deckListNotifierProvider.notifier).updateCount(widget.slug, cardCount);
    }
    ref.read(deckListNotifierProvider.notifier).updateUpdatedAt(widget.slug);
  }

  List<CardListItem> _sortCards(List<CardListItem> cards) {
    final signatures = ['Signature Unit', 'Signature Spell'];

    final legendCard = cards.where((c) => c.type?.toLowerCase() == 'legend').toList();
    final championCard = cards.where((c) => c.type?.toLowerCase() == 'champion unit').toList();
    final signatureCards = cards.where((c) => signatures.contains(c.type?.toLowerCase())).toList();
    final unitCards = cards.where((c) => c.type?.toLowerCase() == 'unit').toList();
    final spellCards = cards.where((c) => c.type?.toLowerCase() == 'spell').toList();
    final gearCards = cards.where((c) => c.type?.toLowerCase() == 'gear').toList();
    final battlefieldCards = cards.where((c) => c.type?.toLowerCase() == 'battlefield').toList();
    final tokenCards = cards.where((c) => c.type?.toLowerCase() == 'token unit').toList();
    final runeCards = cards.where((c) => c.type?.toLowerCase() == 'rune').toList();

    legendCard.sort((a, b) => a.cardId.compareTo(b.cardId));
    championCard.sort((a, b) => a.cardId.compareTo(b.cardId));
    signatureCards.sort((a, b) => a.cardId.compareTo(b.cardId));
    unitCards.sort((a, b) => a.cardId.compareTo(b.cardId));
    spellCards.sort((a, b) => a.cardId.compareTo(b.cardId));
    gearCards.sort((a, b) => a.cardId.compareTo(b.cardId));
    battlefieldCards.sort((a, b) => a.cardId.compareTo(b.cardId));
    tokenCards.sort((a, b) => a.cardId.compareTo(b.cardId));
    runeCards.sort((a, b) => a.cardId.compareTo(b.cardId));

    return [
      ...legendCard,
      ...battlefieldCards,
      ...championCard,
      ...signatureCards,
      ...unitCards,
      ...spellCards,
      ...gearCards,
      ...tokenCards,
      ...runeCards,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final deck$ = ref.watch(deckBuildNotifierProvider(widget.slug));
    if (deck$ == null) {
      return loadingWidget;
    }
    _cardSearch.cards = _sortCards(deck$.cards);
    final legends = deck$.cards.where((c) => c.type == "Legend");
    if (legends.isEmpty) {
      _cardSearch.cards.insert(0, deck$.legend);
    }
    final search$ = ref.watch(cardSearchNotifierProvider(screen: _searchScreen, cardSearch: _cardSearch));

    return Column(
      children: [
        if (search$.status.isInitializing) loadingWidget,
        if (!search$.status.isInitializing)
          Column(
            children: [
              ListTile(
                leading: SizedBox(width: 42, child: CardImage(imageUrl: widget.card.thumbnail)),
                title: Text(
                  widget.card.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(widget.card.cardId, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () {},
                trailing: SizedBox(
                  width: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => _remove(_selectedCard),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(4),
                            backgroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Icon(Symbols.remove, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 24,
                        child: Text(
                          ref
                              .read(deckBuildNotifierProvider(widget.slug).notifier)
                              .cardCount(widget.card.id)
                              .toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => _add(_selectedCard),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(4),
                            backgroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Icon(Symbols.add, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              for (int i = 0; i < search$.cards.length; i++)
                ListTile(
                  leading: SizedBox(width: 42, child: CardImage(imageUrl: search$.cards[i].thumbnail)),
                  title: Text(
                    search$.cards[i].name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle:
                      search$.cards[i].type == 'Legend'
                          ? Text(
                            '${search$.cards[i].cardId} \u2981 ${ref.read(deckBuildNotifierProvider(widget.slug).notifier).totalCards()}/$_deckCardLimit cards',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                          : Text(search$.cards[i].cardId, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: null,
                  trailing:
                      search$.cards[i].type != 'Legend' && search$.cards[i].type != 'Battlefield'
                          ? SizedBox(
                            width: 120,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () => _remove(search$.cards[i]),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(4),
                                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                    child: Icon(Symbols.remove, color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    ref
                                        .read(deckBuildNotifierProvider(widget.slug).notifier)
                                        .cardCount(search$.cards[i].id)
                                        .toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () => _add(search$.cards[i]),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(4),
                                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                    child: Icon(Symbols.add, color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : null,
                ),
              const SizedBox(height: 16),
            ],
          ),
      ],
    );
  }
}
