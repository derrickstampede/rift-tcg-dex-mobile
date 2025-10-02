import 'package:flutter/material.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/filter.model.dart';
import 'package:rift/models/market.model.dart';

class Vault with ChangeNotifier {
  final int id;
  final String? userUid;
  String name;
  final String slug;
  String? photo;
  final String category;
  final String type;
  String? color;
  final String? other;
  final int? order;
  final DateTime amountUpdatedAt;
  List<CardListItem> cards;
  final String? variant;
  final int? count;
  String? sortBy;
  bool? isSortAscending;
  final DateTime createdAt;
  DateTime updatedAt;
  num totalYYT;
  num totalTCGP;
  num totalCM;
  num totalEn;
  num totalJp;
  int? countryId;
  String? symbol;
  bool hasReachedLimit;
  bool isLoading;
  bool isInitializing;
  List<VaultMarket> markets;

  Vault({
    required this.id,
    this.userUid,
    required this.name,
    required this.slug,
    this.photo,
    required this.category,
    required this.type,
    this.color,
    this.other,
    this.order,
    required this.amountUpdatedAt,
    required this.cards,
    required this.variant,
    required this.count,
    required this.sortBy,
    required this.isSortAscending,
    required this.createdAt,
    required this.updatedAt,
    this.totalYYT = 0,
    this.totalTCGP = 0,
    this.totalCM = 0,
    this.totalEn = 0,
    this.totalJp = 0,
    this.countryId,
    this.symbol,
    this.hasReachedLimit = false,
    this.isLoading = false,
    this.isInitializing = true,
    required this.markets,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_uid': userUid,
        'name': name,
        'slug': slug,
        'photo': photo,
        'category': category,
        'type': type,
        'color': color,
        'other': other,
        'order': order,
        'amount_updated_at': amountUpdatedAt.toString(),
        'cards': cards.map((c) => c.toJson()).toList(),
        'sort_by': sortBy,
        'is_sort_ascending': isSortAscending,
        'created_at': createdAt.toString(),
        'updated_at': updatedAt.toString(),
        'total_yyt': totalYYT,
        'total_tcgp': totalTCGP,
        'total_cm': totalCM,
        'total_en': totalEn,
        'total_jp': totalJp,
        'country_id': countryId,
        'symbol': symbol,
        'has_reached_limit': hasReachedLimit,
        'is_loading': isLoading,
        'is_initializing': isInitializing,
        'markets': markets.map((m) => m.toJson()).toList(),
      };

  factory Vault.fromMap(Map<String, dynamic> map) => Vault(
        id: map['id'],
        userUid: map['user_uid'],
        name: map['name'],
        slug: map['slug'],
        photo: map['photo'],
        category: map['category'],
        type: map['type'],
        color: map['color'],
        other: map['other'],
        order: map['order'],
        amountUpdatedAt:
            map['amount_updated_at'] is String ? DateTime.parse(map['amount_updated_at']) : map['amount_updated_at'],
        cards: map['cards'] == null
            ? []
            : List<CardListItem>.from(map['cards'].map<CardListItem>((c) => CardListItem.fromMap(c))),
        variant: map['variant'],
        count: map['count'],
        sortBy: map['sort_by'],
        isSortAscending: map['is_sort_ascending'],
        createdAt: DateTime.parse(map['created_at']),
        updatedAt: DateTime.parse(map['updated_at']),
        totalYYT: map['total_yyt'] ?? 0,
        totalTCGP: map['total_tcgp'] ?? 0,
        totalCM: map['total_cm'] ?? 0,
        totalJp: map['total_jp'] ?? 0,
        totalEn: map['total_en'] ?? 0,
        countryId: map['country_id'],
        symbol: map['symbol'],
        hasReachedLimit: map['has_reached_limit'] ?? false,
        isLoading: map['is_loading'] ?? false,
        isInitializing: map['is_initializing'] ?? true,
        markets: map['markets'] == null
            ? []
            : List<VaultMarket>.from(map['markets'].map<VaultMarket>((m) => VaultMarket.fromMap(m))),
      );
}

class VaultList with ChangeNotifier {
  final List<Vault> vaults;
  final bool isLoading;
  final String sortBy;
  final bool isSortAscending;

  VaultList({
    required this.vaults,
    required this.isLoading,
    required this.sortBy,
    required this.isSortAscending,
  });

  Map<String, dynamic> toJson() => {
        'vaults': vaults.map((c) => c.toJson()).toList(),
        'isLoading': isLoading,
        'sortBy': sortBy,
        'isSortAscending': isSortAscending,
      };

  factory VaultList.fromMap(Map<String, dynamic> map) => VaultList(
        vaults: map['vaults'] == null ? [] : List<Vault>.from(map['vaults'].map<Vault>((d) => Vault.fromMap(d))),
        isLoading: map['isLoading'],
        sortBy: map['sortBy'],
        isSortAscending: map['isSortAscending'],
      );
}

class VaultForm {
  int? id;
  String? name;
  String? slug;
  String? category;
  String? type;
  String? color;
  String? other;
  int? order;
  List<VaultCardForm> cards;

  set updateName(String? value) {
    name = value;
  }

  set updateCategory(String? value) {
    category = value;
  }

  set updateType(String? value) {
    type = value;
  }

  set updateOther(String? value) {
    other = value;
  }

  set updateColor(String? value) {
    color = value;
  }

  VaultForm({
    this.id,
    this.name,
    this.slug,
    this.category,
    this.type,
    this.color,
    this.other,
    this.order,
    required this.cards,
  });
}

class VaultCardForm {
  final int cardId;
  final int variantId;
  final int count;

  VaultCardForm({
    required this.cardId,
    required this.variantId,
    required this.count,
  });

  Map<String, dynamic> toJson() => {
        'card_id': cardId,
        'variant_id': variantId,
        'count': count,
      };

  factory VaultCardForm.fromMap(Map<String, dynamic> map) => VaultCardForm(
        cardId: map['card_id'],
        variantId: map['variant_id'],
        count: map['count'],
      );
}

final List<Filter> vaultCategoryOptions = [
  Filter(label: 'Actual', value: 'actual'),
  Filter(label: 'Digital', value: 'digital'),
];

final List<Filter> vaultTypeOptions = [
  Filter(label: 'Binder', value: 'binder'),
  Filter(label: 'Card Cabinet', value: 'card cabinet'),
  Filter(label: 'Card Drawer', value: 'card drawer'),
  Filter(label: 'Deck Box', value: 'deck box'),
  Filter(label: 'Sorting Tray', value: 'sorting tray'),
  Filter(label: 'Storage Box', value: 'storage box'),
  Filter(label: 'Tin', value: 'tin'),
  Filter(label: 'Other', value: 'other'),
];
