import 'package:flutter/material.dart';

class Profile with ChangeNotifier {
  final String userUid;
  String username;
  String? displayName;
  String? photo;
  int? maxDecks;
  int? maxVaults;
  int? usernameChanges;
  int? countryId;
  String? cardTranslation;

  Profile({
    required this.userUid,
    required this.username,
    required this.displayName,
    required this.photo,
    required this.maxDecks,
    required this.maxVaults,
    required this.usernameChanges,
    required this.countryId,
    this.cardTranslation,
  });

  Map<String, dynamic> toJson() => {
        'user_uid': userUid,
        'username': username,
        'display_name': displayName,
        'photo': photo,
        'max_decks': maxDecks,
        'max_vaults': maxVaults,
        'username_changes': usernameChanges,
        'country_id': countryId,
        'card_translation': cardTranslation,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        userUid: json['user_uid'],
        username: json['username'],
        displayName: json['display_name'],
        photo: json['photo'],
        maxDecks: json['max_decks'],
        maxVaults: json['max_vaults'],
        usernameChanges: json['username_changes'],
        countryId: json['country_id'],
        cardTranslation: json['card_translation'],
      );
}

class ProfileStat with ChangeNotifier {
  final int totalCards;
  final int uniqueCards;
  final int totalDecks;
  final int totalVaults;
  int maxDecks;
  int maxVaults;

  ProfileStat({
    required this.totalCards,
    required this.uniqueCards,
    required this.totalDecks,
    required this.totalVaults,
    required this.maxDecks,
    required this.maxVaults,
  });

  Map<String, dynamic> toJson() => {
        'totalCards': totalCards,
        'uniqueCards': uniqueCards,
        'totalDecks': totalDecks,
        'totalVaults': totalVaults,
        'maxDecks': maxDecks,
        'maxVaults': maxVaults,
      };

  factory ProfileStat.fromJson(Map<String, dynamic> json) => ProfileStat(
        totalCards: json['totalCards'],
        uniqueCards: json['uniqueCards'],
        totalDecks: json['totalDecks'],
        totalVaults: json['totalVaults'],
        maxDecks: json['maxDecks'],
        maxVaults: json['maxVaults'],
      );
}

class Market with ChangeNotifier {
  final String name;
  final String language;
  final String currency;
  final String squareLogo;
  final bool isPro;
  final String format;
  final num total;

  Market({
    required this.name,
    required this.language,
    required this.currency,
    required this.squareLogo,
    required this.isPro,
    required this.format,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'language': language,
        'currency': currency,
        'square_logo': squareLogo,
        'is_pro': isPro,
        'format': format,
        'total': total,
      };

  factory Market.fromJson(Map<String, dynamic> json) => Market(
        name: json['name'],
        language: json['language'],
        currency: json['currency'],
        squareLogo: json['square_logo'],
        isPro: json['is_pro'],
        format: json['format'],
        total: json['total'],
      );
}
