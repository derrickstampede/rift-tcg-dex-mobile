import 'package:flutter/material.dart';

class CardTranslation with ChangeNotifier {
  final String cardId;
  final String language;
  final String name;
  final String? backName;
  final String? color;
  final String? type;
  final String? effect;
  final String? awakenEffect;
  final String? features;

  CardTranslation({
    required this.cardId,
    required this.language,
    required this.name,
    required this.backName, 
    required this.color,
    required this.type,
    required this.effect,
    required this.awakenEffect,
    required this.features,
  });

  Map<String, dynamic> toJson() => {
        'card_id': cardId,
        'language': language,
        'name': name,
        'back_name': backName,
        'color': color,
        'type': type,
        'effect': effect,
        'awaken_effect': awakenEffect,
        'feature': features,
      };

  factory CardTranslation.fromMap(Map<String, dynamic> map) => CardTranslation(
        cardId: map['card_id'].toString(),
        language: map['language'],
        name: map['name'],
        backName: map['back_name'],
        color: map['color'],
        type: map['type'],
        effect: map['effect'],
        awakenEffect: map['awaken_effect'],
        features: map['features'],
      );
}
