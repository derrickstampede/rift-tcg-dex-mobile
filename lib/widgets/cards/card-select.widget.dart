import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:rift/models/card.model.dart';

class CardSelect extends StatelessWidget {
  const CardSelect({super.key, required CardListItem card, required Function({required CardListItem card}) select})
      : _card = card,
        _select = select;

  final CardListItem _card;
  final Function({required CardListItem card}) _select;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _select(card: _card);
        },
        style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary),
        child: Icon(
          Symbols.check,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
