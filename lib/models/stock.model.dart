import 'package:flutter/material.dart';

class StockGraph with ChangeNotifier {
  final String name;
  final String slug;
  String currency;
  String logo;
  bool isPro;
  String format;
  final List<Stock> stocks;
  int xMax;
  int xMin;
  int yMax;
  int yMin;
  final List<String> leftTitles;
  final List<String> bottomTitles;
  List<Spot> spots;
  List<Tooltip> tooltips;

  StockGraph({
    required this.name,
    required this.slug,
    required this.currency,
    required this.logo,
    required this.isPro,
    required this.format,
    required this.stocks,
    required this.xMax,
    required this.xMin,
    required this.yMax,
    required this.yMin,
    required this.leftTitles,
    required this.bottomTitles,
    required this.spots,
    required this.tooltips,
  });

  factory StockGraph.fromMap(Map<String, dynamic> map) => StockGraph(
        name: map['name'],
        slug: map['slug'],
        currency: map['currency'],
        logo: map['logo'],
        isPro: map['is_pro'],
        format: map['format'],
        stocks: map['stocks'].map<Stock>((s) => Stock.fromMap(s)).toList(),
        xMax: map['xMax'],
        xMin: map['xMin'],
        yMax: map['yMax'],
        yMin: map['yMin'],
        leftTitles: List<String>.from(map['leftTitles']),
        bottomTitles: List<String>.from(map['bottomTitles']),
        spots: map['spots'].map<Spot>((s) => Spot.fromMap(s)).toList(),
        tooltips: map['tooltips'].map<Tooltip>((t) => Tooltip.fromMap(t)).toList(),
      );
}

class Stock with ChangeNotifier {
  final int cardId;
  final num price;
  final DateTime createdAt;

  Stock({
    required this.cardId,
    required this.price,
    required this.createdAt,
  });

  factory Stock.fromMap(Map<String, dynamic> map) => Stock(
        cardId: map['card_id'],
        price: map['price'],
        createdAt: DateTime.parse(map['created_at']),
      );
}

class StockAdjustedPrice with ChangeNotifier {
  final String market;
  final num? price;

  StockAdjustedPrice({
    required this.market,
    required this.price,
  });

  factory StockAdjustedPrice.fromMap(Map<String, dynamic> map) => StockAdjustedPrice(
        market: map['market'],
        price: map['price'],
      );
}

class Spot with ChangeNotifier {
  final num x;
  final num y;

  Spot({
    required this.x,
    required this.y,
  });

  factory Spot.fromMap(Map<String, dynamic> map) => Spot(
        x: map['x'],
        y: map['y'],
      );
}

class Tooltip with ChangeNotifier {
  final String price;
  final String date;

  Tooltip({
    required this.price,
    required this.date,
  });

  factory Tooltip.fromMap(Map<String, dynamic> map) => Tooltip(
        price: map['price'],
        date: map['date'],
      );
}
