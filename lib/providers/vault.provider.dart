import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/models/vault.model.dart';
import 'package:rift/models/card.model.dart';
import 'package:rift/models/market.model.dart';

import 'package:rift/helpers/vault.helper.dart';

import 'package:rift/repositories/vault.repository.dart';

import 'package:rift/repositories/vault-repository.provider.dart';

part 'vault.provider.g.dart';

@riverpod
class VaultBuildNotifier extends _$VaultBuildNotifier {
  late final VaultRepository vaultRepository;
  final _cardSearchLimit = int.parse(dotenv.env['CARD_SEARCH_LIMIT']!);

  @override
  Vault? build(String? slug) {
    if (slug != null) {
      vaultRepository = ref.watch(vaultRepositoryProvider(slug));
      find(slug);
    }
    return null;
  }

  Future<void> find(String slug) async {
    try {
      final vault = await vaultRepository.findVault(slug);
      vault.isInitializing = false;

      if (vault.cards.isEmpty) {
        vault.hasReachedLimit = true;
      }
      if (vault.cards.isNotEmpty && vault.cards.length < _cardSearchLimit) {
        vault.hasReachedLimit = true;
      }

      update(vault);
    } catch (e) {
      update(null);
    }
  }

  void update(Vault? value) => state = value;

  Future<void> updateName(String name) async {
    if (state == null) return;
    final vault = state!.toJson();
    vault['name'] = name;

    update(Vault.fromMap({...vault}));

    final form = {
      "name": vault['name'],
      "slug": vault['slug'],
      "category": vault['category'],
      "type": vault['type'],
      "color": vault['color'],
      "other": vault['other'],
      "cards": vault['cards'].map((c) {
        return {
          "card_id": c['id'],
          "count": c['count'],
        };
      }).toList()
    };
    final response = await updateVault(form, vault['slug']);
    response.fold((l) {
      // print(l);
    }, (r) {
      print(r);
    });
  }

  Future<void> updateColor(String color) async {
    if (state == null) return;
    final vault = state!.toJson();
    vault['color'] = color;

    update(Vault.fromMap({...vault}));
  }

  Future<void> updateType(String type) async {
    if (state == null) return;
    final vault = state!.toJson();
    vault['type'] = type;

    update(Vault.fromMap({...vault}));
  }

  Future<void> updatePhoto(String photo) async {
    if (state == null) return;
    final vault = state!.toJson();
    vault['photo'] = photo;

    update(Vault.fromMap({...vault}));
  }

  Future<void> updateCountryId(int? countryId) async {
    if (state == null) return;
    final vault = state!.toJson();

    if (countryId == 0) countryId = null;
    vault['country_id'] = countryId;

    update(Vault.fromMap({...vault}));
  }

  Future<void> updateSortBy(String? sortBy) async {
    if (state == null || sortBy == null) return;
    final vault = state!.toJson();
    vault['sort_by'] = sortBy;

    update(Vault.fromMap({...vault}));
  }

  Future<void> updateIsAscending(bool isAscending) async {
    if (state == null) return;
    final vault = state!.toJson();
    vault['is_sort_ascending'] = !isAscending;

    update(Vault.fromMap({...vault}));
  }

  bool isCardInVault(CardListItem card) {
    if (state == null) return false;

    if (card.variant != null) {
      int index = state!.cards.indexWhere((c) => c.id == card.id && c.variant == card.variant);
      if (index > -1) {
        return true;
      }
    } else {
      for (var i = 0; i < card.cardsProfiles!.length; i++) {
        if (state!.id == card.cardsProfiles![i].vaultId) {
          return true;
        }
      }
    }

    return false;
  }

  void addCard(CardListItem card) {
    try {
      if (state == null) return;

      Map<String, dynamic> vault = state!.toJson();
      vault['cards'] = [...vault['cards'], card.toJson()];

      final newVault = Vault.fromMap(vault);
      newVault.cards.sort((a, b) => a.cardId.compareTo(b.cardId));

      update(newVault);

      updateTotals(card, true);
    } catch (e) {
      print(e);
    }
  }

  void removeCard(int id, String variant) {
    if (state == null) return;

    Map<String, dynamic> vault = state!.toJson();
    final removedCardIndex = vault['cards'].indexWhere((c) => c['id'] == id && c['variant'] == variant);
    final removedCard = CardListItem.fromMap(vault['cards'][removedCardIndex]);
    vault['cards'].removeWhere((c) => c['id'] == id && c['variant'] == variant);

    update(Vault.fromMap(vault));

    updateTotals(removedCard, false);
  }

  void updateTotals(CardListItem card, bool increment) {
    if (state == null) return;

    Map<String, dynamic> vault = state!.toJson();
    final markets = vault['markets'].map((m) => VaultMarket.fromMap(m)).toList();
    if (increment) {
      if (card.variant == 'jp') {
        for (var market in markets) {
          if (market.slug == 'yuyutei-jp') {
            market.value += card.yytJp != null ? (card.yytJp! / 100) * card.count : 0;
            break;
          }
          if (market.slug == 'cardmarket-jp') {
            market.value += card.cmJp != null ? (card.cmJp! / 100) * card.count : 0;
            break;
          }
        }
        vault['total_jp'] += card.count;
      } else if (card.variant == 'en') {
        for (var market in markets) {
          if (market.slug == 'tcgplayer-en') {
            market.value += card.tcgpEn != null ? (card.tcgpEn! / 100) * card.count : 0;
            break;
          }
          if (market.slug == 'cardmarket-en') {
            market.value += card.cmEn != null ? (card.cmEn! / 100) * card.count : 0;
            break;
          }
        }
        vault['total_en'] += card.count;
      }
    } else {
      if (card.variant == 'jp') {
        for (var market in markets) {
          if (market.slug == 'yuyutei-jp') {
            market.value -= card.yytJp != null ? (card.yytJp! / 100) * card.count : 0;
            break;
          }
          if (market.slug == 'cardmarket-jp') {
            market.value -= card.cmJp != null ? (card.cmJp! / 100) * card.count : 0;
            break;
          }
        }
        vault['total_jp'] -= card.count;
      } else if (card.variant == 'en') {
        for (var market in markets) {
          if (market.slug == 'tcgplayer-en') {
            market.value -= card.tcgpEn != null ? (card.tcgpEn! / 100) * card.count : 0;
            break;
          }
          if (market.slug == 'cardmarket-en') {
            market.value -= card.cmEn != null ? (card.cmEn! / 100) * card.count : 0;
            break;
          }
        }
        vault['total_en'] -= card.count;
      }
    }
    vault['markets'] = markets.map((m) => m.toJson()).toList();

    update(Vault.fromMap(vault));
  }

  void updateCardProfile(int id, List<CardsProfiles> cardProfiles) {
    final newState = Vault.fromMap(state!.toJson());

    for (var i = 0; i < cardProfiles.length; i++) {
      final index = newState.cards
          .indexWhere((c) => c.id == cardProfiles[i].cardId && c.variant == cardProfiles[i].variant!.language);

      if (index >= 0) {
        newState.cards[index].cardsProfiles = cardProfiles;
        newState.cards[index].count = cardProfiles[i].count;
      }
    }

    update(newState);
  }

  int totalCards() {
    int total = 0;
    if (state == null) return total;

    for (int i = 0; i < state!.cards.length; i++) {
      total += state!.cards[i].count;
    }
    return total;
  }

  Future<void> searchCards({bool refresh = false, int offset = 0, int limit = 24}) async {
    if (state!.isLoading) return;
    if (!refresh && state!.hasReachedLimit) return;

    try {
      updateIsLoading(true);
      if (refresh) updateIsInitializing(true);

      final newState = Vault.fromMap(state!.toJson());
      final cards = await vaultRepository.searchtVaultCards(state!.slug, offset, limit);

      bool hasReachedLimit = false;

      if (cards.isNotEmpty) {
        if (refresh) {
          newState.cards = cards;
        } else {
          newState.cards = List.from(newState.cards)..addAll(cards);
        }
      }
      if (state!.cards.isNotEmpty && cards.length < limit ||
          cards.isNotEmpty && cards.length < limit) {
        hasReachedLimit = true;
      }
      if (refresh && cards.isEmpty) {
        newState.cards = [];
      }
      newState.isInitializing = false;
      newState.isLoading = false;
      newState.hasReachedLimit = hasReachedLimit;

      update(newState);
    } catch (e) {
      print(e);
      // TODO: error handling
    }
  }

  void updateIsLoading(bool isLoading) {
    final newState = Vault.fromMap(state!.toJson());
    newState.isLoading = isLoading;

    update(newState);
  }

  void updateIsInitializing(bool isInitializing) {
    final newState = Vault.fromMap(state!.toJson());
    newState.isInitializing = isInitializing;
    update(newState);
  }
}
