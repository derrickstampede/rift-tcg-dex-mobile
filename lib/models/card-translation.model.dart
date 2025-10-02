import 'package:flutter/material.dart';

class CardTranslation with ChangeNotifier {
  final String cardId;
  final String language;
  final String name;
  final String? color;
  final String? type;
  final String? ability;
  final String? tags;

  CardTranslation({
    required this.cardId,
    required this.language,
    required this.name,
    required this.color,
    required this.type,
    required this.ability,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
        'card_id': cardId,
        'language': language,
        'name': name,
        'color': color,
        'type': type,
        'ability': ability,
        'feature': tags,
      };

  factory CardTranslation.fromMap(Map<String, dynamic> map) => CardTranslation(
        cardId: map['card_id'].toString(),
        language: map['language'],
        name: map['name'],
        color: map['color'],
        type: map['type'],
        ability: map['ability'],
        tags: map['tags'],
      );
}
