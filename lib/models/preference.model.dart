import 'package:flutter/material.dart';

class PreferenceCountryOption with ChangeNotifier {
  final int id;
  final String name;
  final String currency;

  PreferenceCountryOption({
    required this.id,
    required this.name,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'currency': currency,
  };

  factory PreferenceCountryOption.fromMap(Map<String, dynamic> map) => PreferenceCountryOption(
    id: map['id'], 
    name: map['name'],
    currency: map['currency'],
  );
}