import 'package:flutter/material.dart';

import 'package:rift/models/card.model.dart';

import 'package:rift/widgets/cards/card-variant-stamp.widget.dart';

class CardInCollection extends StatelessWidget {
  const CardInCollection({super.key, required this.card, required this.cardProfile});

  final CardItemView card;
  final CardsProfiles cardProfile;

  @override
  Widget build(BuildContext context) {
    final index = card.variants.indexWhere((cv) => cv.id == cardProfile.variantId);
    if (index < 0) {
      return const SizedBox();
    }
    final variant = card.variants[index];

    return RichText(
        text: TextSpan(text: '', children: [
      TextSpan(text: '${cardProfile.count}x', style: Theme.of(context).textTheme.bodyLarge),
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
            margin: const EdgeInsets.only(left: 4, right: 8),
            width: 24,
            height: 24,
            child: CardVariantStamp(
              language: variant.language,
            )),
      ),
    ]));
  }
}
