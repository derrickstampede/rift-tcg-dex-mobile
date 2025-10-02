import 'package:flutter/material.dart';

class CardVariantStamp extends StatelessWidget {
  const CardVariantStamp({
    super.key,
    required this.language,
  });

  final String? language;

  @override
  Widget build(BuildContext context) {
    if (language == null) return const SizedBox();

    Color backgroundColor = Colors.white;
    Color foregroundColor = Colors.red;
    Color borderColor = Colors.white;

    if (language == 'en') {
      backgroundColor = Colors.red;
      foregroundColor = Colors.white;
      borderColor = Colors.blue;
    }
    if (language == 'fr') {
      backgroundColor = Colors.blue;
      foregroundColor = Colors.white;
      borderColor = Colors.blue;
    }
    if (language == 'kr') {
      backgroundColor = Colors.white;
      foregroundColor = Colors.blue;
      borderColor = Colors.red;
    }
    if (language == 'cn') {
      backgroundColor = Colors.red;
      foregroundColor = Colors.yellow;
      borderColor = Colors.red;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: Text(
          language!.toUpperCase(),
          style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
    );
  }
}
