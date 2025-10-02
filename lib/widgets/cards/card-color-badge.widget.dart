import 'package:flutter/material.dart';

import 'package:rift/widgets/misc/color-circle.widget.dart';

import 'package:rift/helpers/util.helper.dart';

class CardColorBadge extends StatelessWidget {
  CardColorBadge({
    super.key,
    required String? colors,
  }) : _colors = colors;

  final String? _colors;
  final List<Widget> _badges = [];

  @override
  Widget build(BuildContext context) {
    if (_colors == null) {
      return const SizedBox();
    }

    final colorSplits = _colors.split('/');
    Color backgroundColor = Colors.transparent;

    for (var i = 0; i < colorSplits.length; i++) {
      backgroundColor = getColor(colorSplits[i]);

      _badges.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ColorCircle(
          size: 18,
          color: backgroundColor,
          colors: '',
        ),
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [..._badges],
    );
  }
}
