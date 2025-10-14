import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:rift/themes/theme-extension.dart';

import 'package:rift/helpers/revenuecat.helper.dart';

class SubscriptionBoxSm extends StatefulWidget {
  const SubscriptionBoxSm({super.key, required this.source});

  final String source;

  @override
  State<SubscriptionBoxSm> createState() => _SubscriptionBoxSmState();
}

class _SubscriptionBoxSmState extends State<SubscriptionBoxSm> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.proColor.colorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text('Unlock PRO Features',
            style: TextStyle(color: context.proColor.onColorContainer, fontWeight: FontWeight.w700)),
        subtitle: Text(
          'Tap to check out PRO features',
          style: TextStyle(color: context.proColor.onColorContainer),
        ),
        onTap: () => showSubscribeDialog(context: context, source: widget.source),
        trailing: Container(
          decoration: BoxDecoration(
              color: context.proColor.colorContainer,
              shape: BoxShape.circle,
              border: Border.all(color: context.proColor.onColorContainer)),
          padding: const EdgeInsets.all(10),
          child: Icon(
            Symbols.lock,
            size: 24,
            color: context.proColor.onColorContainer,
          ),
        ),
      ),
    );
  }
}
