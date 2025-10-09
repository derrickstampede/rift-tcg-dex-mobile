import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/models/deck.model.dart';
import 'package:rift/models/card.model.dart';

import 'package:rift/helpers/deck.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/review.helper.dart';

import 'package:rift/repositories/deck.repository.dart';

import 'package:rift/repositories/deck-repository.provider.dart';

part 'deck.provider.g.dart';

final int _cardPerDeckLimit = int.parse(dotenv.env['CARD_PER_DECK_LIMIT']!);
final int _cardIdPerDeckLimit = int.parse(dotenv.env['CARD_ID_PER_DECK_LIMIT']!);

@riverpod
class DeckBuildNotifier extends _$DeckBuildNotifier {
  late final DeckRepository deckRepository;

  Timer? _debounceTimer;

  @override
  Deck? build(String slug) {
    deckRepository = ref.watch(deckRepositoryProvider(slug));
    find(slug);

    return null;
  }

  Future<void> find(String slug) async {
    try {
      final deck = await deckRepository.findDeck(slug);
      deck.cards.insert(0, deck.legend);
      deck.cards.insert(0, deck.champion);
      update(deck);
      computeTotals();
    } catch (e) {
      update(null);
    }
  }

  void update(Deck? value) => state = value;

  Future<void> updateName(String name) async {
    if (state == null) return;
    final deck = state!.toJson();
    deck['name'] = name;

    update(Deck.fromMap({...deck}));

    final deckForm = {
      "name": deck['name'],
      "leader_id": deck['leader']['id'],
      "cards": deck['cards'].where((c) => c['type'] != 'LEADER').map((c) {
        return {
          "card_id": c['id'],
          "count": c['count'],
        };
      }).toList()
    };
    final response = await updateDeck(deckForm, deck['slug']);
    response.fold((l) {
      // print(l);
    }, (r) {
      print(r);
    });
  }

  Future<void> updateCountryId(int? countryId) async {
    if (state == null) return;
    final deck = state!.toJson();

    if (countryId == 0) countryId = null;
    deck['country_id'] = countryId;

    update(Deck.fromMap({...deck}));
  }

  num? addCard(CardListItem card) {
    int cardInstances = cardInstancesCount(card.cardId);
    int cardLimit = _cardIdPerDeckLimit;
    if (card.maxDeckCards != null) {
      cardLimit = card.maxDeckCards!;
    }
    if (card.type == "ENERGY MARKER" && energyCount() >= 1) {
      showSnackbar('Energy marker limit reached');
      return null;
    }
    if (cardInstances >= cardLimit) {
      showSnackbar('Card duplication limit reached');
      return null;
    }

    int totalCards = 0;
    final sideCards = ["ENERGY MARKER"];
    for (var c in state!.cards.where((c) => c.type != 'LEADER').toList()) {
      if (!sideCards.contains(c.type)) {
        totalCards = c.count + totalCards;
      }
    }
    if (!sideCards.contains(card.type) && totalCards >= _cardPerDeckLimit) {
      showSnackbar('Card deck limit reached');
      return null;
    }

    final deck = state!.toJson();
    if (cardInstances > 0) {
      int index = state!.cards.indexWhere((c) => c.id == card.id);
      if (index < 0) {
        // if parallel with no instance
        card.count = 1;
        deck['cards'].add(card.toJson());
      } else {
        // if same card
        deck['cards'][index]['count'] = deck['cards'][index]['count'] + 1;
      }
    } else {
      card.count = 1;
      deck['cards'].add(card.toJson());
    }

    totalCards++;
    if (totalCards >= _cardPerDeckLimit) {
      logEvent(name: 'deck_complete', parameters: {
        'id': deck['leader']['id'],
        'card_id': deck['leader']['card_id'],
        'leader': deck['leader']['name']
      });
      incrementReviewPreq('deck_complete');
    }

    update(Deck.fromMap({...deck}));
    computeTotals();
    debounceUpdate();

    num cardCount = 0;
    final cards = deck['cards'].where((c) => c['type'] != 'LEADER').toList();
    for (var i = 0; i < cards.length; i++) {
      cardCount += cards[i]['count'];
    }
    return cardCount;
  }

  num? removeCard(CardListItem card) {
    int cardInstances = cardInstancesCount(card.cardId);
    if (cardInstances == 0) {
      return null;
    }

    final deck = state!.toJson();
    if (cardInstances == 1) {
      deck['cards'].removeWhere((c) => c['id'] == card.id);
    } else {
      int index = state!.cards.indexWhere((c) => c.id == card.id);
      if (state!.cards[index].count <= 1) {
        deck['cards'].removeWhere((c) => c['id'] == card.id);
      } else {
        deck['cards'][index]['count'] = deck['cards'][index]['count'] - 1;
      }
    }

    update(Deck.fromMap({...deck}));
    computeTotals();
    debounceUpdate();

    num cardCount = 0;
    final cards = deck['cards'].where((c) => c['type'] != 'LEADER').toList();
    for (var i = 0; i < cards.length; i++) {
      cardCount += cards[i]['count'];
    }
    return cardCount;
  }

  void debounceUpdate() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      final deck = state!.toJson();
      final deckForm = {
        "name": deck['name'],
        "leader_id": deck['leader']['id'],
        "cards": deck['cards']
            .where((c) => c['type'] != 'LEADER')
            .map((c) => {
                  "card_id": c['id'],
                  "count": c['count'],
                })
            .toList()
      };
      updateDeck(deckForm, deck['slug']);
    });
  }

  int cardCount(int id) {
    if (state == null) return 0;

    int index = state!.cards.indexWhere((c) => c.id == id);
    if (index < 0) {
      return 0;
    }

    return state!.cards[index].count;
  }

  int cardInstancesCount(String cardId) {
    int instances = 0;

    if (state != null) {
      for (var c in state!.cards.where((c) => c.cardId == cardId)) {
        instances += c.count;
      }
    }
    return instances;
  }

  int energyCount() {
    int count = 0;
    for (var c in state!.cards.where((c) => c.type == "ENERGY MARKER")) {
      count += c.count;
    }
    return count;
  }

  int totalCards() {
    final Deck? deck = state;

    int total = 0;
    if (deck == null) return total;

    for (var i = 0; i < deck.cards.length; i++) {
      if (deck.cards[i].type == "ENERGY MARKER") {
        continue;
      }
      total += deck.cards[i].count;
    }

    //* REMOVE LEADER
    total -= 1;

    return total;
  }

  int totalOtherCards() {
    final Deck? deck = state;

    int total = 0;
    if (deck == null) return total;

    for (var i = 0; i < deck.cards.length; i++) {
      if (deck.cards[i].type != "ENERGY MARKER") {
        total += deck.cards[i].count;
      }
    }

    return total;
  }

  bool isPublic() {
    final Deck? deck = state;
    if (deck == null) return false;

    return deck.isPublic;
  }

  void updatePublic(bool isPublic) {
    final deck = state!.toJson();
    deck['is_public'] = isPublic;
    update(Deck.fromMap({...deck}));

    updatePublicDeck(isPublic, deck['slug']);
  }

  void computeTotals() {
    final deck = state;
    if (deck == null) return;

    for (var market in deck.markets) {
      market.value = 0;
      for (int i = 0; i < deck.cards.length; i++) {
        final card = deck.cards[i].toJson();
        if (card[market.column] != null) {
          market.value += card[market.column]! * card['count'];
        }
      }
    }

    update(deck);
  }

  void updateCardProfile(int id, List<CardsProfiles> cardProfiles) {
    final newState = Deck.fromMap(state!.toJson());
    final index = newState.cards.indexWhere((c) => c.id == id);

    if (index < 0) return;
    newState.cards[index].cardsProfiles = cardProfiles;

    update(newState);
  }

  void updateCardsProfiles(int cardId, List<CardsProfiles> cardsProfiles) {
    final newState = Deck.fromMap(state!.toJson());
    newState.cards.firstWhere((card) => card.id == cardId).cardsProfiles = cardsProfiles;

    update(newState);
  }
}
