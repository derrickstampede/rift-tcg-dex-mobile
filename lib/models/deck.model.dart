import 'package:flutter/material.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/market.model.dart';
import 'package:rift/models/note.model.dart';

class Deck with ChangeNotifier {
  final int id;
  String name;
  final String slug;
  final String? userUid;
  final int? order;
  final CardListItem leader;
  final List<CardListItem> cards;
  num? cardCount;
  Note? note;
  String? sortBy;
  bool? isSortAscending;
  final DateTime createdAt;
  DateTime updatedAt;
  int? countryId;
  String? symbol;
  bool isPublic;
  List<DeckMarket> markets;

  Deck({
    required this.id,
    required this.name,
    required this.slug,
    this.userUid,
    this.order,
    required this.leader,
    required this.cards,
    this.cardCount,
    required this.note,
    required this.sortBy,
    required this.isSortAscending,
    required this.createdAt,
    required this.updatedAt,
    this.countryId,
    this.symbol,
    this.isPublic = false,
    required this.markets,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'user_uid': userUid,
        'order': order,
        'leader': leader.toJson(),
        'cards': cards.map((c) => c.toJson()).toList(),
        'cardCount': cardCount,
        'note': note?.toJson(),
        'sort_by': sortBy,
        'is_sort_ascending': isSortAscending,
        'created_at': createdAt.toString(),
        'updated_at': updatedAt.toString(),
        'country_id': countryId,
        'symbol': symbol,
        'is_public': isPublic,
        'markets': markets.map((m) => m.toJson()).toList(),
      };

  factory Deck.fromMap(Map<String, dynamic> map) => Deck(
        id: map['id'],
        name: map['name'],
        slug: map['slug'],
        userUid: map['user_uid'],
        order: map['order'],
        leader: CardListItem.fromMap(map['leader']),
        cards: map['cards'] == null
            ? []
            : List<CardListItem>.from(map['cards'].map<CardListItem>((c) => CardListItem.fromMap(c))),
        note: map['note'] != null ? Note.fromMap(map['note']) : null,
        sortBy: map['sort_by'],
        isSortAscending: map['is_sort_ascending'],
        cardCount: map['cardCount'],
        createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
        updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
        countryId: map['country_id'], 
        symbol: map['symbol'],
        isPublic: map['is_public'] ?? false,
        markets: map['markets'] == null
            ? []
            : List<DeckMarket>.from(map['markets'].map<DeckMarket>((m) => DeckMarket.fromMap(m))),
      );
}

class DeckList with ChangeNotifier {
  final List<Deck> decks;
  final bool isLoading;
  final String sortBy;
  final bool isSortAscending;

  DeckList({
    required this.decks,
    required this.isLoading,
    required this.sortBy,
    required this.isSortAscending,
  });

  Map<String, dynamic> toJson() => {
        'decks': decks.map((c) => c.toJson()).toList(),
        'isLoading': isLoading,
        'sortBy': sortBy,
        'isSortAscending': isSortAscending,
      };

  factory DeckList.fromMap(Map<String, dynamic> map) => DeckList(
        decks: map['decks'] == null ? [] : List<Deck>.from(map['decks'].map<Deck>((d) => Deck.fromMap(d))),
        isLoading: map['isLoading'],
        sortBy: map['sortBy'],
        isSortAscending: map['isSortAscending'],
      );
}

class DeckForm with ChangeNotifier {
  final String name;
  final int leaderId;
  final List<DeckCardForm> cards;

  DeckForm({
    required this.name,
    required this.leaderId,
    required this.cards,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'leader_id': leaderId,
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  factory DeckForm.fromMap(Map<String, dynamic> map) => DeckForm(
        name: map['name'],
        leaderId: map['leader_id'],
        cards: map['cards'] == null
            ? []
            : List<DeckCardForm>.from(map['cards'].map<DeckCardForm>((c) => DeckCardForm.fromMap(c))),
      );
}

class DeckCardForm with ChangeNotifier {
  final int cardId;
  final int count;

  DeckCardForm({
    required this.cardId,
    required this.count,
  });

  Map<String, dynamic> toJson() => {
        'card_id': cardId,
        'count': count,
      };

  factory DeckCardForm.fromMap(Map<String, dynamic> map) => DeckCardForm(
        cardId: map['card_id'],
        count: map['count'],
      );
}

class DeckShare with ChangeNotifier {
  final int? id;
  final String name;
  final String? slug;
  final String? userUid;
  final int? order;
  final int leaderId;
  final List<DeckCardShare> cards;

  DeckShare({
    required this.id,
    required this.name,
    required this.slug,
    this.userUid,
    this.order,
    required this.leaderId,
    required this.cards,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'user_uid': userUid,
        'order': order,
        'leader_id': leaderId,
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  factory DeckShare.fromMap(Map<String, dynamic> map) => DeckShare(
        id: map['id'],
        name: map['name'],
        slug: map['slug'],
        userUid: map['user_uid'],
        order: map['order'],
        leaderId: map['leader_id'],
        cards: List<DeckCardShare>.from(map['cards'].map<DeckCardShare>((c) => DeckCardShare.fromMap(c))),
      );
}

class DeckCardShare with ChangeNotifier {
  final int id;
  final int count;

  DeckCardShare({
    required this.id,
    required this.count,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'count': count,
      };

  factory DeckCardShare.fromMap(Map<String, dynamic> map) => DeckCardShare(
        id: map['id'],
        count: map['count'],
      );
}

class DeckStats with ChangeNotifier {
  final int count;
  final List<DeckStatCost> cost;
  final List<DeckStatCount> specifiedCost;
  final List<DeckStatCount> power;
  final int withEffect;
  final List<DeckStatCount> effect;
  final List<DeckStatCount> type;
  final List<DeckStatCount> rarity;

  DeckStats({
    required this.count,
    required this.cost,
    required this.specifiedCost,
    required this.withEffect,
    required this.power,
    required this.effect,
    required this.type,
    required this.rarity,
  });

  factory DeckStats.fromMap(Map<String, dynamic> map) => DeckStats(
        count: map['count'],
        cost: List<DeckStatCost>.from(map['cost'].map<DeckStatCost>((c) => DeckStatCost.fromMap(c))),
        specifiedCost: List<DeckStatCount>.from(map['specified_cost'].map<DeckStatCount>((c) => DeckStatCount.fromMap(c))),
        withEffect: map['with_effect'],
        power: List<DeckStatCount>.from(map['power'].map<DeckStatCount>((c) => DeckStatCount.fromMap(c))),
        effect: List<DeckStatCount>.from(map['effect'].map<DeckStatCount>((c) => DeckStatCount.fromMap(c))),
        type: List<DeckStatCount>.from(map['type'].map<DeckStatCount>((c) => DeckStatCount.fromMap(c))),
        rarity: List<DeckStatCount>.from(map['rarity'].map<DeckStatCount>((c) => DeckStatCount.fromMap(c))),
      );
}

class DeckStatCost with ChangeNotifier {
  final String label;
  final int count;

  DeckStatCost({
    required this.label,
    required this.count,
  });

  factory DeckStatCost.fromMap(Map<String, dynamic> map) => DeckStatCost(
        label: map['label'],
        count: map['count'],
      );
}

class DeckStatCount with ChangeNotifier {
  final String label;
  final int count;

  DeckStatCount({
    required this.label,
    required this.count,
  });

  factory DeckStatCount.fromMap(Map<String, dynamic> map) => DeckStatCount(
        label: map['label'],
        count: map['count'],
      );
}

class DeckStatColorCount with ChangeNotifier {
  final String label;
  final int count;
  final int start;

  DeckStatColorCount({
    required this.label,
    required this.count,
    required this.start,
  });

  factory DeckStatColorCount.fromMap(Map<String, dynamic> map) => DeckStatColorCount(
        label: map['label'],
        count: map['count'],
        start: map['start'],
      );
}
