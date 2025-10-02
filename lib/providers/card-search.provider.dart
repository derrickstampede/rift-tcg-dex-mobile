import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rift/models/card-search.model.dart';
import 'package:rift/models/card.model.dart';
import 'package:rift/models/filter.model.dart';
import 'package:rift/models/note.model.dart';

import 'package:rift/repositories/card-search.repository.dart';
import 'package:rift/repositories/card-search-repository.provider.dart';

import 'package:rift/helpers/card.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';

part 'card-search.provider.g.dart';

String? _screen;

@riverpod
class CardSearchNotifier extends _$CardSearchNotifier {
  late final CardSearchRepository cardSearchRepository;
  final _cardSearchLimit = int.parse(dotenv.env['CARD_SEARCH_LIMIT']!);

  @override
  CardSearch build({required String screen, required CardSearch cardSearch}) {
    print('build $screen');
    cardSearchRepository = ref.watch(cardSearchRepositoryProvider);

    cardSearch.cardBatches = createCardBatches(cardSearch.cards);
    update(cardSearch);
    _screen = screen;

    if (cardSearch.cards.isNotEmpty || screen == 'deck-edit' || screen == 'vault-view') {
      return cardSearch;
    }

    search(refresh: true);
    return cardSearch;
  }

  void update(dynamic value) => state = value;

  Future<void> saveToStorage(Map<String, dynamic> newState) async {
    if (_screen != 'main-screen') return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('main-search', json.encode(newState));
  }

  CardSearchStatus status() => state.status;
  List<CardListItem> cards() => state.cards;
  List<List<CardListItem>> batches() => state.cardBatches;
  String? symbol() => state.symbol;

  Future<void> search({bool refresh = false}) async {
    if (state.status.isLoading) return;
    if (!refresh && state.status.hasReachedLimit) return;

    try {
      updateIsLoading(true);
      if (refresh) updateIsInitializing(true);

      final search = state.toJson();
      SearchResponse response = await cardSearchRepository.searchCards(
        collection: search['filters']['collection'],
        name: search['filters']['name'],
        setId: search['filters']['setId'],
        rarity: search['filters']['rarity'],
        language: search['filters']['language'],
        color: search['filters']['color'],
        type: search['filters']['type'],
        art: search['filters']['art'],
        cost: search['filters']['cost'],
        specifiedCost: search['filters']['specifiedCost'],
        power: search['filters']['power'],
        awakenPower: search['filters']['awakenPower'],
        feature: search['filters']['feature'],
        effect: search['filters']['effect'],
        asc: search['filters']['asc'],
        desc: search['filters']['desc'],
        offset: refresh ? 0 : search['cards'].length,
      );
      final cards = response.cards;

      final newState = CardSearch.fromMap(search);
      bool hasReachedLimit = false;

      if (cards.isNotEmpty) {
        if (refresh) {
          newState.cards = cards;
        } else {
          newState.cards = List.from(newState.cards)..addAll(cards);
        }
      }
      if (state.cards.isNotEmpty && cards.length < _cardSearchLimit ||
          cards.isNotEmpty && cards.length < _cardSearchLimit) {
        hasReachedLimit = true;
      }
      if (refresh && cards.isEmpty) {
        newState.cards = [];
      }
      newState.cardBatches = createCardBatches(newState.cards);
      newState.status = CardSearchStatus(
        isInitializing: false,
        isLoading: false,
        hasReachedLimit: hasReachedLimit,
        showOwned: state.status.showOwned,
        view: state.status.view,
        orderBy: state.status.orderBy,
        isAscending: state.status.isAscending,
        showCollectionDisabled: state.status.showCollectionDisabled,
        showTypeRequired: state.status.showTypeRequired,
        showColorRequired: state.status.showColorRequired,
        selectLeader: state.status.selectLeader,
        addToDeck: state.status.addToDeck,
        addToDeckSelect: state.status.addToDeckSelect,
        addToVault: state.status.addToVault,
      );
      newState.symbol = response.symbol;

      update(newState);
      saveToStorage(newState.toJson());
    } catch (e) {
      print(e);
      // TODO: error handling
    }
  }

  void updateCardProfile(int id, List<CardsProfiles> cardProfiles) {
    final newState = CardSearch.fromMap(state.toJson());
    final index = newState.cards.indexWhere((c) => c.id == id);

    if (index < 0) return;
    newState.cards[index].cardsProfiles = cardProfiles;
    newState.cardBatches = createCardBatches(newState.cards);

    update(newState);
  }

  void updateNote(int id, Note? note) {
    final newState = CardSearch.fromMap(state.toJson());
    final index = newState.cards.indexWhere((c) => c.id == id);
    newState.cards[index].note = note;
    newState.cardBatches = createCardBatches(newState.cards);

    update(newState);
  }

  void updateIsInitializing(bool isInitializing) {
    final newState = CardSearch.fromMap(state.toJson());
    newState.status = CardSearchStatus(
      isInitializing: isInitializing,
      isLoading: state.status.isLoading,
      hasReachedLimit: false,
      showOwned: state.status.showOwned,
      view: state.status.view,
      orderBy: state.status.orderBy,
      isAscending: state.status.isAscending,
      showCollectionDisabled: state.status.showCollectionDisabled,
      showTypeRequired: state.status.showTypeRequired,
      showColorRequired: state.status.showColorRequired,
      selectLeader: state.status.selectLeader,
      addToDeck: state.status.addToDeck,
      addToDeckSelect: state.status.addToDeckSelect,
      addToVault: state.status.addToVault,
    );

    update(newState);
  }

  void updateIsLoading(bool isLoading) {
    final newState = CardSearch.fromMap(state.toJson());
    newState.status = CardSearchStatus(
      isInitializing: newState.status.isInitializing,
      isLoading: isLoading,
      hasReachedLimit: false,
      showOwned: state.status.showOwned,
      view: state.status.view,
      orderBy: state.status.orderBy,
      isAscending: state.status.isAscending,
      showCollectionDisabled: state.status.showCollectionDisabled,
      showTypeRequired: state.status.showTypeRequired,
      showColorRequired: state.status.showColorRequired,
      selectLeader: state.status.selectLeader,
      addToDeck: state.status.addToDeck,
      addToDeckSelect: state.status.addToDeckSelect,
      addToVault: state.status.addToVault,
    );

    update(newState);
  }

  String orderBy() => state.status.orderBy;
  String view() => state.status.view;
  bool showOwned() => state.status.showOwned;
  bool isAscending() => state.status.isAscending;
  bool showCollectionDisabled() => state.status.showCollectionDisabled;
  bool showTypeRequired() => state.status.showTypeRequired;
  bool showColorRequired() => state.status.showColorRequired;

  void updateCards(List<CardListItem> cards) {
    final newState = CardSearch.fromMap(state.toJson());
    newState.cards = cards;
    newState.cardBatches = createCardBatches(newState.cards);

    update(newState);
  }

  void updateCardsProfiles(int cardId, List<CardsProfiles> cardsProfiles) {
    final newState = CardSearch.fromMap(state.toJson());
    newState.cards.firstWhere((card) => card.id == cardId).cardsProfiles = cardsProfiles;
    newState.cardBatches = createCardBatches(newState.cards);

    update(newState);
  }

  void updateOrderBy(String? value) {
    if (state.status.isInitializing || value == null) return;

    final newState = CardSearch.fromMap(state.toJson());
    bool isAsending = state.status.isAscending;
    if (value == 'card' || value == 'name') {
      isAsending = true;
    } else {
      isAsending = false;
    }

    String? asc;
    String? desc;
    if (isAsending) {
      asc = value;
    } else {
      desc = value;
    }

    String view = state.status.view;
    if (value != 'card') {
      view = value;
    }

    newState.status = CardSearchStatus(
      isInitializing: newState.status.isInitializing,
      isLoading: newState.status.isLoading,
      hasReachedLimit: newState.status.hasReachedLimit,
      showOwned: state.status.showOwned,
      view: view,
      orderBy: value,
      isAscending: isAsending,
      showCollectionDisabled: state.status.showCollectionDisabled,
      showTypeRequired: state.status.showTypeRequired,
      showColorRequired: state.status.showColorRequired,
      selectLeader: state.status.selectLeader,
      addToDeck: state.status.addToDeck,
      addToDeckSelect: state.status.addToDeckSelect,
      addToVault: state.status.addToVault,
    );
    newState.filters = CardSearchFilters(
      collection: state.filters.collection,
      name: state.filters.name,
      setId: state.filters.setId,
      rarity: state.filters.rarity,
      language: state.filters.language,
      color: state.filters.color,
      type: state.filters.type,
      art: state.filters.art,
      cost: state.filters.cost,
      specifiedCost: state.filters.specifiedCost,
      power: state.filters.power,
      awakenPower: state.filters.awakenPower,
      combo: state.filters.combo,
      feature: state.filters.feature,
      effect: state.filters.effect,
      asc: asc,
      desc: desc,
    );

    logEvent(name: 'card_sort', parameters: {'show': value, 'by': isAsending ? 'asc' : 'desc'});
    update(newState);

    search(refresh: true);
  }

  void updateIsAscending() {
    final newState = CardSearch.fromMap(state.toJson());
    bool isAsending = !state.status.isAscending;

    String? asc;
    String? desc;
    if (isAsending) {
      asc = state.status.orderBy;
    } else {
      desc = state.status.orderBy;
    }

    newState.status = CardSearchStatus(
      isInitializing: newState.status.isInitializing,
      isLoading: newState.status.isLoading,
      hasReachedLimit: newState.status.hasReachedLimit,
      showOwned: state.status.showOwned,
      view: state.status.view,
      orderBy: state.status.orderBy,
      isAscending: isAsending,
      showCollectionDisabled: state.status.showCollectionDisabled,
      showTypeRequired: state.status.showTypeRequired,
      showColorRequired: state.status.showColorRequired,
      selectLeader: state.status.selectLeader,
      addToDeck: state.status.addToDeck,
      addToDeckSelect: state.status.addToDeckSelect,
      addToVault: state.status.addToVault,
    );
    newState.filters = CardSearchFilters(
      collection: state.filters.collection,
      name: state.filters.name,
      setId: state.filters.setId,
      rarity: state.filters.rarity,
      language: state.filters.language,
      color: state.filters.color,
      type: state.filters.type,
      art: state.filters.art,
      cost: state.filters.cost,
      specifiedCost: state.filters.specifiedCost,
      power: state.filters.power,
      awakenPower: state.filters.awakenPower,
      combo: state.filters.combo,
      feature: state.filters.feature,
      effect: state.filters.effect,
      asc: asc,
      desc: desc,
    );

    logEvent(name: 'card_sort', parameters: {'show': state.status.orderBy, 'by': isAsending ? 'asc' : 'desc'});
    update(newState);

    search(refresh: true);
  }

  void updateView(String? value) {
    if (state.status.isInitializing || value == null) return;

    final newState = CardSearch.fromMap(state.toJson());
    newState.status = CardSearchStatus(
      isInitializing: newState.status.isInitializing,
      isLoading: newState.status.isLoading,
      hasReachedLimit: newState.status.hasReachedLimit,
      showOwned: newState.status.showOwned,
      view: value,
      orderBy: newState.status.orderBy,
      isAscending: newState.status.isAscending,
      showCollectionDisabled: newState.status.showCollectionDisabled,
      showTypeRequired: newState.status.showTypeRequired,
      showColorRequired: newState.status.showColorRequired,
      selectLeader: newState.status.selectLeader,
      addToDeck: newState.status.addToDeck,
      addToDeckSelect: newState.status.addToDeckSelect,
      addToVault: newState.status.addToVault,
    );

    logEvent(name: 'card_change_label', parameters: {'show': value});
    update(newState);
  }

  void updateShowOwned(bool value) {
    final newState = CardSearch.fromMap(state.toJson());
    newState.status = CardSearchStatus(
      isInitializing: newState.status.isInitializing,
      isLoading: newState.status.isLoading,
      hasReachedLimit: newState.status.hasReachedLimit,
      showOwned: value,
      view: state.status.view,
      orderBy: state.status.orderBy,
      isAscending: state.status.isAscending,
      showCollectionDisabled: state.status.showCollectionDisabled,
      showTypeRequired: state.status.showTypeRequired,
      showColorRequired: state.status.showColorRequired,
      selectLeader: state.status.selectLeader,
      addToDeck: state.status.addToDeck,
      addToDeckSelect: state.status.addToDeckSelect,
      addToVault: state.status.addToVault,
    );

    update(newState);
  }

  List<Filter> sortingOptions() => _sortingOptions;
  List<Filter> sortingDeckOptions() => _sortingDeckOptions;
  List<Filter> sortingVaultOptions() => _sortingVaultOptions;
  List<Filter> viewingOptions() => _viewingOptions;

  bool collection() => state.filters.collection;
  String? name() => state.filters.name;
  String? setId() => state.filters.setId;
  List<String> rarity() => state.filters.rarity;
  List<String> language() => state.filters.language;
  List<String> color() => state.filters.color;
  List<String> type() => state.filters.type;
  List<String> art() => state.filters.art;
  List<int> cost() => state.filters.cost;
  String? specifiedCost() => state.filters.specifiedCost;
  List<int> power() => state.filters.power;
  List<int> awakenPower() => state.filters.awakenPower;
  List<int> combo() => state.filters.combo;
  String? feature() => state.filters.feature;
  List<String> effect() => state.filters.effect;

  void updateCollection(bool value) {
    if (state.config.disableCollection) return;

    final newState = CardSearch.fromMap(state.toJson());
    if (state.config.disableCollection) {
      newState.status = CardSearchStatus(
        isInitializing: false,
        isLoading: false,
        hasReachedLimit: state.status.hasReachedLimit,
        showOwned: state.status.showOwned,
        view: state.status.view,
        orderBy: state.status.orderBy,
        isAscending: state.status.isAscending,
        showCollectionDisabled: state.status.showCollectionDisabled,
        showTypeRequired: state.status.showTypeRequired,
        showColorRequired: state.status.showColorRequired,
        selectLeader: state.status.selectLeader,
        addToDeck: state.status.addToDeck,
        addToDeckSelect: state.status.addToDeckSelect,
        addToVault: state.status.addToVault,
      );

      update(newState);
      return;
    }

    newState.filters = CardSearchFilters(
      collection: value,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_collection', parameters: {'value': value.toString()});
    update(newState);
  }

  void updateName(String? value) {
    final newState = CardSearch.fromMap(state.toJson());
    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: value,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    update(newState);
  }

  void updateSetId(String? value) {
    final newState = CardSearch.fromMap(state.toJson());
    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: value,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_set', parameters: {'value': value});
    update(newState);
  }

  void updateRarity(String value) {
    final newState = CardSearch.fromMap(state.toJson());

    final currentRarity = newState.filters.rarity;
    if (!currentRarity.contains(value)) {
      currentRarity.add(value);
    } else {
      currentRarity.remove(value);
    }

    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: currentRarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_rarity', parameters: {'value': value});
    update(newState);
  }

  void updateLanguage(String value) {
    final newState = CardSearch.fromMap(state.toJson());

    final currentLanguage = newState.filters.language;
    if (!currentLanguage.contains(value)) {
      currentLanguage.add(value);
    } else {
      currentLanguage.remove(value);
    }

    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: currentLanguage,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_language', parameters: {'value': value});
    update(newState);
  }

  void updateColor(String value) {
    final newState = CardSearch.fromMap(state.toJson());
    bool showColorRequired = false;

    final currentColor = newState.filters.color;
    if (!currentColor.contains(value)) {
      currentColor.add(value);
    } else {
      if (state.config.requireOneColor && currentColor.length == 1) {
        showColorRequired = true;
      } else {
        currentColor.remove(value);
      }
    }

    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: currentColor,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );
    newState.status = CardSearchStatus(
      isInitializing: false,
      isLoading: false,
      hasReachedLimit: state.status.hasReachedLimit,
      showOwned: state.status.showOwned,
      view: state.status.view,
      orderBy: state.status.orderBy,
      isAscending: state.status.isAscending,
      showCollectionDisabled: state.status.showCollectionDisabled,
      showTypeRequired: state.status.showTypeRequired,
      showColorRequired: showColorRequired,
      selectLeader: state.status.selectLeader,
      addToDeck: state.status.addToDeck,
      addToDeckSelect: state.status.addToDeckSelect,
      addToVault: state.status.addToVault,
    );

    logEvent(name: 'filter_color', parameters: {'value': value});
    update(newState);
  }

  void updateType(String value) {
    final newState = CardSearch.fromMap(state.toJson());

    final currentType = newState.filters.type;
    if (!currentType.contains(value)) {
      currentType.add(value);
    } else {
      currentType.remove(value);
    }

    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: currentType,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_type', parameters: {'value': value});
    update(newState);
  }

  void updateArt(String value) {
    final newState = CardSearch.fromMap(state.toJson());

    final currentArt = newState.filters.art;
    if (!currentArt.contains(value)) {
      currentArt.add(value);
    } else {
      currentArt.remove(value);
    }

    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: currentArt,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_art', parameters: {'value': value});
    update(newState);
  }

  void updateCost(SfRangeValues value) {
    final newState = CardSearch.fromMap(state.toJson());

    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: [value.start.ceil(), value.end.ceil()],
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_cost', parameters: {'value': '${value.start},${value.end}'});
    update(newState);
  }

  void updateSpecifiedCost(String? value) {
    final newState = CardSearch.fromMap(state.toJson());
    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: value,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_specified_cost', parameters: {'value': value});
    update(newState);
  }

  void updatePower(SfRangeValues value) {
    final newState = CardSearch.fromMap(state.toJson());

    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: [value.start.ceil(), value.end.ceil()],
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_power', parameters: {'value': '${value.start},${value.end}'});
    update(newState);
  }

  void updateAwakenPower(SfRangeValues value) {
    final newState = CardSearch.fromMap(state.toJson());

    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: [value.start.ceil(), value.end.ceil()],
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_awaken_power', parameters: {'value': '${value.start},${value.end}'});
    update(newState);
  }

  void updateCombo(SfRangeValues value) {
    final newState = CardSearch.fromMap(state.toJson());

    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: [value.start.ceil(), value.end.ceil()],
      feature: newState.filters.feature,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_combo', parameters: {'value': '${value.start},${value.end}'});
    update(newState);
  }

  void updateFeature(String? value) {
    final newState = CardSearch.fromMap(state.toJson());
    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: value,
      effect: newState.filters.effect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_feature', parameters: {'value': value});
    update(newState);
  }

  void updateEffect(String value) {
    final newState = CardSearch.fromMap(state.toJson());

    final currentEffect = newState.filters.effect;
    if (!currentEffect.contains(value)) {
      currentEffect.add(value);
    } else {
      currentEffect.remove(value);
    }

    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: newState.filters.name,
      setId: newState.filters.setId,
      rarity: newState.filters.rarity,
      language: newState.filters.language,
      color: newState.filters.color,
      type: newState.filters.type,
      art: newState.filters.art,
      cost: newState.filters.cost,
      specifiedCost: newState.filters.specifiedCost,
      power: newState.filters.power,
      awakenPower: newState.filters.awakenPower,
      combo: newState.filters.combo,
      feature: newState.filters.feature,
      effect: currentEffect,
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    logEvent(name: 'filter_effect', parameters: {'value': value});
    update(newState);
  }

  List<T> resetValues<T>(List<T> list1, List<T> list2) {
    Set<T> set1 = list1.toSet();
    Set<T> set2 = list2.toSet();
    Set<T> intersection = set1.intersection(set2);

    intersection.addAll(list2);
    return intersection.toList();
  }

  bool hasFilter(String type, String value) {
    List<String>? selectedFilter = [];
    switch (type) {
      case 'rarity':
        selectedFilter = state.filters.rarity;
        break;
      case 'language':
        selectedFilter = state.filters.language;
        break;
      case 'color':
        selectedFilter = state.filters.color;
        break;
      case 'type':
        selectedFilter = state.filters.type;
        break;
      case 'art':
        selectedFilter = state.filters.art;
        break;
      case 'effect':
        selectedFilter = state.filters.effect;
        break;
    }

    if (selectedFilter.contains(value)) {
      return true;
    }
    return false;
  }

  bool isDisabled(String type, String value) {
    List<String> selectedFilter = [];
    switch (type) {
      case 'rarity':
        selectedFilter = state.config.disableRarity;
        break;
      case 'color':
        selectedFilter = state.config.disableColor;
        break;
      case 'type':
        selectedFilter = state.config.disableType;
        break;
    }

    if (selectedFilter.contains(value)) {
      return true;
    }
    return false;
  }

  int? prevCard(int id) {
    int index = state.cards.indexWhere((c) => c.id == id);
    if (index > 0) {
      CardListItem prevCard = state.cards[--index];
      return prevCard.id;
    }
    return null;
  }

  int? nextCard(int id) {
    int index = state.cards.indexWhere((c) => c.id == id);
    if (index < state.cards.length - 1) {
      CardListItem nextCard = state.cards[++index];
      return nextCard.id;
    }
    return null;
  }

  void clearFilters() {
    final newState = CardSearch.fromMap(state.toJson());

    const costRange = [0, 7];
    const powerRange = [0, 50000];
    const awakenPowerRange = [0, 20000];
    const comboRange = [0, 10000];

    newState.filters = CardSearchFilters(
      collection: newState.filters.collection,
      name: null,
      setId: null,
      rarity: List.from(resetValues(newState.config.disableRarity, newState.config.initialResetRarity)),
      language: [],
      color: List.from(resetValues(newState.config.disableColor, newState.config.initialResetColor)),
      type: List.from(resetValues(newState.config.disableType, newState.config.initialResetType)),
      art: [],
      cost: costRange,
      specifiedCost: null,
      power: powerRange,
      awakenPower: awakenPowerRange,
      combo: comboRange,
      feature: null,
      effect: [],
      asc: newState.filters.asc,
      desc: newState.filters.desc,
    );

    update(newState);
  }

  void addCard(CardListItem card) {
    final newState = CardSearch.fromMap(state.toJson());
    newState.cards = [...newState.cards, card];

    update(newState);
  }

  void removeCard(int id, String variant) {
    Map<String, dynamic> cardSearcb = state.toJson();
    cardSearcb['cards'].removeWhere((c) => c['id'] == id && c['variant'] == variant);

    update(CardSearch.fromMap(cardSearcb));
  }

  void sortCards(String by, bool isAscending) {
    final newState = CardSearch.fromMap(state.toJson());
    final cards = newState.cards;
    if (by == 'card') {
      cards.sort((a, b) => isAscending ? a.cardId.compareTo(b.cardId) : b.cardId.compareTo(a.cardId));
    }
    if (by == 'name') {
      cards.sort((a, b) => isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    }
    if (by == 'power') {
      cards.sort((a, b) => isAscending ? a.power!.compareTo(b.power!) : b.power!.compareTo(a.power!));
    }
    if (by == 'awaken_power') {
      cards.sort(
        (a, b) => isAscending ? a.awakenPower!.compareTo(b.awakenPower!) : b.awakenPower!.compareTo(a.awakenPower!),
      );
    }
    if (by == 'cost') {
      cards.sort((a, b) => isAscending ? a.cost!.compareTo(b.cost!) : b.cost!.compareTo(a.cost!));
    }
    if (by == 'combo') {
      cards.sort((a, b) => isAscending ? a.combo!.compareTo(b.combo!) : b.combo!.compareTo(a.combo!));
    }
    if (by == 'tcgp_en') {
      cards.sort((a, b) => isAscending ? a.tcgpEn!.compareTo(b.tcgpEn!) : b.tcgpEn!.compareTo(a.tcgpEn!));
    }
    if (by == 'yyt_jp') {
      cards.sort((a, b) => isAscending ? a.yytJp!.compareTo(b.yytJp!) : b.yytJp!.compareTo(a.yytJp!));
    }
    if (by == 'cm_en') {
      cards.sort((a, b) => isAscending ? a.cmEn!.compareTo(b.cmEn!) : b.cmEn!.compareTo(a.cmEn!));
    }
    if (by == 'cm_jp') {
      cards.sort((a, b) => isAscending ? a.cmJp!.compareTo(b.cmJp!) : b.cmJp!.compareTo(a.cmJp!));
    }

    newState.cardBatches = createCardBatches(cards);
    update(newState);
  }
}

final List<Filter> _sortingOptions = [
  Filter(label: 'Set', value: 'set'),
  Filter(label: 'Card ID', value: 'card'),
  Filter(label: 'Name', value: 'name'),
  Filter(label: 'Power', value: 'power'),
  Filter(label: 'Awaken Power', value: 'awaken_power'),
  Filter(label: 'Combo', value: 'combo'),
  Filter(label: 'Cost', value: 'cost'),
  Filter(label: 'TCGPlayer', value: 'tcgp_en'),
  // Filter(label: 'Yuyu-tei', value: 'yyt_jp'),
  Filter(label: 'CardMarket', value: 'cm_en'),
  // Filter(label: 'CardMarket JP', value: 'cm_jp'),
];

final List<Filter> _sortingDeckOptions = [
  Filter(label: 'Card ID', value: 'card'),
  Filter(label: 'Name', value: 'name'),
  Filter(label: 'Power', value: 'power'),
  // Filter(label: 'Awaken Power', value: 'awaken_power'),
  Filter(label: 'Combo', value: 'combo'),
  Filter(label: 'Cost', value: 'cost'),
];

final List<Filter> _sortingVaultOptions = [
  Filter(label: 'Card ID', value: 'card'),
  Filter(label: 'Name', value: 'name'),
  Filter(label: 'Power', value: 'power'),
  Filter(label: 'Awaken Power', value: 'awaken_power'),
  Filter(label: 'Combo', value: 'combo'),
  Filter(label: 'Cost', value: 'cost'),
  Filter(label: 'TCGPlayer', value: 'tcgp_en'),
  // Filter(label: 'Yuyu-tei', value: 'yyt_jp'),
  Filter(label: 'CardMarket', value: 'cm_en'),
  // Filter(label: 'CardMarket JP', value: 'cm_jp'),
];

final List<Filter> _viewingOptions = [
  Filter(label: 'Name', value: 'name'),
  Filter(label: 'Set', value: 'set'),
  Filter(label: 'Power', value: 'power'),
  Filter(label: 'Awaken Power', value: 'awaken_power'),
  Filter(label: 'Cost', value: 'cost'),
  Filter(label: 'Combo', value: 'combo'),
  Filter(label: 'Rarity', value: 'rarity'),
  Filter(label: 'Color', value: 'color'),
  Filter(label: 'TCGPlayer', value: 'tcgp_en'),
  // Filter(label: 'Yuyu-tei', value: 'yyt_jp'),
  Filter(label: 'CardMarket', value: 'cm_en'),
  // Filter(label: 'CardMarket JP', value: 'cm_jp'),
];
