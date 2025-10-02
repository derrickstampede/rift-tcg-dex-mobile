import 'package:flutter/material.dart';

import 'package:rift/themes/theme-extension.dart';

class ProBadge extends StatelessWidget {
  const ProBadge({super.key, this.showUnlock = true});

  final bool showUnlock;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: context.proColor.colorContainer, borderRadius: BorderRadius.circular(4)),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      child: Text(
        showUnlock ? 'UNLOCK PRO' : 'PRO',
        textAlign: TextAlign.center,
        style: TextStyle(color: context.proColor.onColorContainer, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}
