import 'dart:convert';

import 'package:rift/models/card-search.model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String MAIN_CARD_SCREEN = 'main-screen';
final CardSearch MAIN_CARD_SEARCH = CardSearch(
  cards: [],
  cardBatches: [],
  status: CardSearchStatus(
    isInitializing: true,
    isLoading: false,
    hasReachedLimit: false,
    showOwned: false,
    view: 'name',
    orderBy: 'set',
    isAscending: false,
    showCollectionDisabled: false,
    showTypeRequired: false,
    showColorRequired: false,
    selectLeader: false,
    addToDeck: false,
    addToDeckSelect: false,
    addToVault: false,
  ),
  filters: CardSearchFilters(
    collection: false,
    name: null,
    setId: null,
    rarity: [],
    language: [],
    color: [],
    type: [],
    art: [],
    cost: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_COST_RESET']!)),
    specifiedCost: null,
    power: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_POWER_RESET']!)),
    awakenPower: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_AWAKEN_POWER_RESET']!)),
    combo: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_COMBO_RESET']!)),
    feature: null,
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
    initialResetType: [],
    initialResetRarity: const [],
    requireOneType: false,
    requireOneColor: false,
  ),
  symbol: null,
);
