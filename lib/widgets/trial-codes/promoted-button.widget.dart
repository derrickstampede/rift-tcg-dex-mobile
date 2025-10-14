import 'package:flutter/material.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:badges/badges.dart' as badges;
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rift/themes/theme-extension.dart';

import 'package:rift/models/trial-code.model.dart';

import 'package:rift/providers/promoted-trial-code.provider.dart';

import 'package:rift/helpers/revenuecat.helper.dart';

class TrialCodePromotedButton extends ConsumerStatefulWidget {
  const TrialCodePromotedButton({super.key});

  @override
  ConsumerState<TrialCodePromotedButton> createState() => _TrialCodePromotedButtonState();
}

class _TrialCodePromotedButtonState extends ConsumerState<TrialCodePromotedButton> with SingleTickerProviderStateMixin {
  void showPaywall(TrialCode trialCode) async {
    bool hasPurchased = await showTrialPaywall(trialCode.id, trialCode.offering!, trialCode.entitlement!);
    if (hasPurchased) {
      _popAtStart();
    }
  }

  void _popAtStart() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final trialCode$ = ref.read(trialCodesProvider).value;
    if (trialCode$ == null) {
      return const SizedBox.shrink();
    }

    final timeDifference = trialCode$.endAt.difference(DateTime.now());
    final isExpired = timeDifference.isNegative;
    if (isExpired) {
      return const SizedBox.shrink();
    }

    final onColor = context.proColor.onColorContainer;
    final containerColor = context.proColor.colorContainer;

    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -8, end: 8),
      showBadge: true,
      ignorePointer: false,
      onTap: null,
      badgeContent: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(Symbols.lock_open, color: containerColor, size: 24),
      ),
      badgeStyle: badges.BadgeStyle(
        badgeColor: onColor,
        padding: const EdgeInsets.all(5),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('LIMITED TIME OFFER', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: onColor)),
            const Text('Access PRO Features Now!', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onColor,
                    foregroundColor: containerColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => showPaywall(trialCode$),
                  child: Text(trialCode$.text ?? 'Unlock PRO Features',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ),
            SlideCountdown(
              duration: trialCode$.endAt.difference(DateTime.now()),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
