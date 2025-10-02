import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CardPrice extends StatelessWidget {
  const CardPrice(
      {super.key,
      required this.price,
      this.fontSize = 14,
      this.currency = 'JPY',
      this.isCentered = true,
      this.format = '#,###,##0.00',
      this.replaceSymbol,
      this.color});

  final num? price;
  final double? fontSize;
  final String? currency;
  final String? replaceSymbol;
  final Color? color;
  final bool isCentered;
  final String? format;

  @override
  Widget build(BuildContext context) {
    num? amount = price;

    Color? priceColor = color;
    if (color == null) {
      priceColor = Theme.of(context).colorScheme.onSurface;
    }

    String priceLabel = "-";
    String suffix = "";
    if (amount != null) {
      if (amount > 1000000) {
        amount /= 1000;
        suffix = 'k';
      }
      priceLabel = NumberFormat(format).format(amount);
    }

    // TODO: CHECK IF PRO
    String symbol = '';
    if (priceLabel != "-") {
      switch (currency) {
        case 'JPY':
          symbol = '¥';
          break;
        case 'USD':
          symbol = '\$';
          break;
        case 'EUR':
          symbol = '€';
          break;
      }
    }
    if (replaceSymbol != null) {
      symbol = replaceSymbol!;
      switch (symbol) {
        case 'JPY':
          symbol = '¥';
          break;
        case 'USD':
          symbol = '\$';
          break;
        case 'EUR':
          symbol = '€';
          break;
      }
    }

    final text = AutoSizeText(
      '$symbol$priceLabel$suffix',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: priceColor),
      maxLines: 1,
    );

    if (!isCentered) {
      return text;
    }

    return Center(
        child: FittedBox(
      child: text,
    ));
  }
}
