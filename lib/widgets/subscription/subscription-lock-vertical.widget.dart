import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:rift/themes/theme-extension.dart';

// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/widgets/misc/pro-badge.widget.dart';

class SubscriptionLockVertical extends StatelessWidget {
  const SubscriptionLockVertical({super.key, required this.source,});

  final String source;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => showSubscribeDialog(context: context, source: source),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.proColor.colorContainer,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(
              Symbols.lock,
              size: 20,
              color: context.proColor.onColorContainer,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          const ProBadge()
        ],
      ),
    );
  }
}
