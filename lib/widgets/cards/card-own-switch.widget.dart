import 'package:flutter/material.dart';

class CardOwnSwitch extends StatelessWidget {
  const CardOwnSwitch({super.key, required this.showOwned, required this.toggleShowOwned});

  final bool showOwned;
  final Function(bool card) toggleShowOwned;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Switch(
        value: showOwned,
        onChanged: (value) {
          toggleShowOwned(value);
        },
      ),
    );
  }
}
