import 'package:flutter/material.dart';

class Conversion with ChangeNotifier {
  final String origin;
  final String target;
  final num rate;

  Conversion({
    required this.origin,
    required this.target,
    required this.rate,
  });

  Map<String, dynamic> toJson() => {
    'origin': origin,
    'target': target,
    'rate': rate,
  };

  factory Conversion.fromMap(Map<String, dynamic> map) => Conversion(
    origin: map['origin'], 
    target: map['target'],
    rate: map['rate'],
  );
}

class ConversionsResponse {
  List<Conversion> conversions;
  String? symbol;
  bool isLoading;

  ConversionsResponse({
    required this.conversions,
    required this.symbol,
    required this.isLoading,
  });
}