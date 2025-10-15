import 'package:flutter/material.dart';

import 'package:rift/models/card.model.dart';

class CardSearch with ChangeNotifier {
  List<CardListItem> cards;
  List<List<CardListItem>> cardBatches;
  CardSearchStatus status;
  CardSearchFilters filters;
  CardSearchConfig config;
  String? symbol;

  CardSearch({
    required this.cards,
    required this.cardBatches,
    required this.status,
    required this.filters,
    required this.config,
    required this.symbol,
  });

  Map<String, dynamic> toJson() => {
    'cards': cards.map((c) => c.toJson()).toList(),
    'cardBatches': cardBatches.map((b) => b.map((c) => c.toJson()).toList()).toList(),
    'status': status.toJson(),
    'filters': filters.toJson(),
    'config': config.toJson(),
    'symbol': symbol,
  };

  factory CardSearch.fromMap(Map<String, dynamic> map) => CardSearch(
    cards: map['cards'] != null ? map['cards'].map<CardListItem>((c) => CardListItem.fromMap(c)).toList() : [],
    cardBatches:
        map['cardBatches'] != null
            ? List<List<CardListItem>>.from(
              map['cardBatches'].map<List<CardListItem>>(
                (b) => List<CardListItem>.from(b.map((c) => CardListItem.fromMap(c))),
              ),
            )
            : [],
    status: CardSearchStatus.fromMap(map['status']),
    filters: CardSearchFilters.fromMap(map['filters']),
    config: CardSearchConfig.fromMap(map['config']),
    symbol: map['symbol'],
  );
}

class CardSearchFilters {
  final bool collection;
  final String? name;
  final String? setId;
  final List<String> rarity;
  final List<String> language;
  final List<String> color;
  final List<String> domain;
  final List<String> type;
  final List<String> art;
  final List<int> energy;
  final List<int> might;
  final List<int> power;
  final String? tag;
  final List<String> effect;
  final String? asc;
  final String? desc;
  final String? legend;

  CardSearchFilters({
    required this.collection,
    required this.name,
    required this.setId,
    required this.rarity,
    required this.language,
    required this.color,
    required this.domain,
    required this.type,
    required this.art,
    required this.energy,
    required this.might,
    required this.power,
    required this.tag,
    required this.effect,
    required this.asc,
    required this.desc,
    this.legend,
  });

  Map<String, dynamic> toJson() => {
    'collection': collection,
    'name': name,
    'setId': setId,
    'rarity': rarity,
    'language': language,
    'color': color,
    'domain': domain,
    'type': type,
    'art': art,
    'energy': energy,
    'might': might,
    'power': power,
    'tag': tag,
    'effect': effect,
    'asc': asc,
    'desc': desc,
    'legend': legend,
  };

  factory CardSearchFilters.fromMap(Map<String, dynamic> map) => CardSearchFilters(
    collection: map['collection'],
    name: map['name'],
    setId: map['setId'],
    rarity: map['rarity'],
    language: map['language'],
    color: map['color'],
    domain: map['domain'],
    type: map['type'],
    art: map['art'],
    energy: map['energy'],
    might: map['might'],
    power: map['power'],
    tag: map['tag'],
    effect: map['effect'],
    asc: map['asc'],
    desc: map['desc'],
    legend: map['legend'],
  );
}

class CardSearchStatus {
  final bool isInitializing;
  final bool isLoading;
  final bool hasReachedLimit;
  final bool showOwned;
  final String view;
  final String orderBy;
  final bool isAscending;
  final bool showCollectionDisabled;
  final bool showTypeRequired;
  final bool showColorRequired;
  final bool selectLeader;
  final bool addToDeck;
  final bool addToDeckSelect;
  final bool addToVault;
  final num? switchChampion;
  final num? switchBattlefield;

  CardSearchStatus({
    required this.isInitializing,
    required this.isLoading,
    required this.hasReachedLimit,
    required this.showOwned,
    required this.view,
    required this.orderBy,
    required this.isAscending,
    required this.showCollectionDisabled,
    required this.showTypeRequired,
    required this.showColorRequired,
    required this.selectLeader,
    required this.addToDeck,
    required this.addToDeckSelect,
    required this.addToVault,
    this.switchChampion,
    this.switchBattlefield,
  });

  Map<String, dynamic> toJson() => {
    'isInitializing': isInitializing,
    'isLoading': isLoading,
    'hasReachedLimit': hasReachedLimit,
    'showOwned': showOwned,
    'view': view,
    'orderBy': orderBy,
    'isAscending': isAscending,
    'showCollectionDisabled': showCollectionDisabled,
    'showTypeRequired': showTypeRequired,
    'showColorRequired': showColorRequired,
    'selectLeader': selectLeader,
    'addToDeck': addToDeck,
    'addToDeckSelect': addToDeckSelect,
    'addToVault': addToVault,
    'switchChampion': switchChampion,
    'switchBattlefield': switchBattlefield,
  };

  factory CardSearchStatus.fromMap(Map<String, dynamic> map) => CardSearchStatus(
    isInitializing: map['isInitializing'],
    isLoading: map['isLoading'],
    hasReachedLimit: map['hasReachedLimit'],
    showOwned: map['showOwned'],
    view: map['view'],
    orderBy: map['orderBy'],
    isAscending: map['isAscending'],
    showCollectionDisabled: map['showCollectionDisabled'],
    showTypeRequired: map['showTypeRequired'],
    showColorRequired: map['showColorRequired'],
    selectLeader: map['selectLeader'],
    addToDeck: map['addToDeck'],
    addToDeckSelect: map['addToDeckSelect'],
    addToVault: map['addToVault'],
    switchChampion: map['switchChampion'],
    switchBattlefield: map['switchBattlefield'],
  );
}

class CardSearchConfig {
  final bool disableCollection;
  final List<String> disableRarity;
  final List<String> disableType;
  final List<String> disableColor;
  final List<String> initialResetColor;
  final List<String> initialResetType;
  final List<String> initialResetRarity;
  final bool requireOneType;
  final bool requireOneColor;

  CardSearchConfig({
    required this.disableCollection,
    required this.disableRarity,
    required this.disableType,
    required this.disableColor,
    required this.initialResetColor,
    required this.initialResetType,
    required this.initialResetRarity,
    required this.requireOneType,
    required this.requireOneColor,
  });

  Map<String, dynamic> toJson() => {
    'disableCollection': disableCollection,
    'disableRarity': disableRarity,
    'disableType': disableType,
    'disableColor': disableColor,
    'initialResetColor': initialResetColor,
    'initialResetType': initialResetType,
    'initialResetRarity': initialResetRarity,
    'requireOneType': requireOneType,
    'requireOneColor': requireOneColor,
  };

  factory CardSearchConfig.fromMap(Map<String, dynamic> map) => CardSearchConfig(
    disableCollection: map['disableCollection'],
    disableRarity: map['disableRarity'],
    disableType: map['disableType'],
    disableColor: map['disableColor'],
    initialResetColor: map['initialResetColor'],
    initialResetType: map['initialResetType'],
    initialResetRarity: map['initialResetRarity'],
    requireOneType: map['requireOneType'],
    requireOneColor: map['requireOneColor'],
  );
}
