import 'package:flutter/material.dart';

class Filter with ChangeNotifier {
  final String label;
  final String value;

  Filter({
    required this.label,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
  };

  factory Filter.fromMap(Map<String, dynamic> map) => Filter(
    label: map['label'], 
    value: map['value'],
  );
}

class Filters with ChangeNotifier {
  final List<Filter> rarity;
  final List<Filter> language;
  final List<Filter> cardTranslation;
  final List<Filter> color;
  final List<Filter> type;
  final List<Filter> art;
  final List<Filter> cost;
  final List<Filter> specifiedCost;
  final List<Filter> power;
  final List<Filter> awakenPower;
  final List<Filter> combo;
  final List<Filter> feature;
  final List<Filter> effect;

  Filters({
    required this.rarity,
    required this.language,
    required this.cardTranslation,
    required this.color,
    required this.type,
    required this.art,
    required this.cost,
    required this.specifiedCost,
    required this.power,
    required this.awakenPower,
    required this.combo,
    required this.feature,
    required this.effect,
  });

  factory Filters.fromMap(Map<String, dynamic> map) => Filters(
    rarity: List<Filter>.from(
      map['rarity'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    language: List<Filter>.from(
      map['language'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    cardTranslation: List<Filter>.from(
      map['card_translation'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    color: List<Filter>.from(
      map['color'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    type: List<Filter>.from(
      map['type'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    art: List<Filter>.from(
      map['art'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    cost: List<Filter>.from(
      map['cost'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    specifiedCost: List<Filter>.from(
      map['specified_cost'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    power: List<Filter>.from(
      map['power'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    awakenPower: List<Filter>.from(
      map['awaken_power'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    combo: List<Filter>.from(
      map['combo'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    feature: List<Filter>.from(
      map['feature'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    effect: List<Filter>.from(
      map['effect'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    
  );
}