import 'package:flutter/material.dart';

class Market with ChangeNotifier {
  String name;
  String slug;
  String language;
  bool isPro;
  String currency;
  String logo;
  String squareLogo;
  String format;
  String column;

  Market({
    required this.name,
    required this.slug,
    required this.language,
    required this.isPro,
    required this.currency,
    required this.logo,
    required this.squareLogo,
    required this.format,
    required this.column,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'slug': slug,
    'language': language,
    'is_pro': isPro,
    'currency': currency,
    'logo': logo,
    'square_logo': squareLogo,
    'format': format,
    'column': column,
  };

  factory Market.fromMap(Map<String, dynamic> map) => Market(
    name: map['name'],
    slug: map['slug'],
    language: map['language'],
    isPro: map['is_pro'],
    currency: map['currency'],
    logo: map['logo'],
    squareLogo: map['square_logo'],
    format: map['format'],
    column: map['column'],
  );
}

class DeckMarket with ChangeNotifier {
  String name;
  String slug;
  String language;
  String column;
  bool isPro;
  String currency;
  String squareLogo;
  String format;
  num value;

  DeckMarket({
    required this.name,
    required this.slug,
    required this.language,
    required this.column,
    required this.isPro,
    required this.currency,
    required this.squareLogo,
    required this.format,
    this.value = 0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'slug': slug,
    'language': language,
    'column': column,
    'is_pro': isPro,
    'currency': currency,
    'square_logo': squareLogo,
    'format': format,
    'value': value,
  };

  factory DeckMarket.fromMap(Map<String, dynamic> map) => DeckMarket(
    name: map['name'],
    slug: map['slug'],
    language: map['language'],
    column: map['column'],
    isPro: map['is_pro'],
    currency: map['currency'],
    squareLogo: map['square_logo'],
    format: map['format'],
    value: map['value'],
  );
}

class VaultMarket with ChangeNotifier {
  String name;
  String slug;
  String language;
  String column;
  bool isPro;
  String currency;
  String squareLogo;
  String format;
  num value;

  VaultMarket({
    required this.name,
    required this.slug,
    required this.language,
    required this.column,
    required this.isPro,
    required this.currency,
    required this.squareLogo,
    required this.format,
    this.value = 0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'slug': slug,
    'language': language,
    'column': column,
    'is_pro': isPro,
    'currency': currency,
    'square_logo': squareLogo,
    'format': format,
    'value': value,
  };

  factory VaultMarket.fromMap(Map<String, dynamic> map) => VaultMarket(
    name: map['name'],
    slug: map['slug'],
    language: map['language'],
    column: map['column'],
    isPro: map['is_pro'],
    currency: map['currency'],
    squareLogo: map['square_logo'],
    format: map['format'],
    value: map['value'],
  );
}