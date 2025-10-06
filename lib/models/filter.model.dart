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
  final List<Filter> domain;
  final List<Filter> type;
  final List<Filter> art;
  final List<Filter> energy;
  final List<Filter> might;
  final List<Filter> power;
  final List<Filter> tag;
  final List<Filter> effect;

  Filters({
    required this.rarity,
    required this.language,
    required this.cardTranslation,
    required this.color,
    required this.domain,
    required this.type,
    required this.art,
    required this.energy,
    required this.might,
    required this.power,
    required this.tag,
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
    domain: List<Filter>.from(
      map['domain'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    type: List<Filter>.from(
      map['type'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    art: List<Filter>.from(
      map['art'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    energy: List<Filter>.from(
      map['energy'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    might: List<Filter>.from(
      map['might'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    power: List<Filter>.from(
      map['power'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    tag: List<Filter>.from(
      map['awaken_power'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    effect: List<Filter>.from(
      map['effect'].map<Filter>((r) => Filter.fromMap(r)),
    ),
    
  );
}