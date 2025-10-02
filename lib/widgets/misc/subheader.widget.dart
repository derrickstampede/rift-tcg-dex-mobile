import 'package:flutter/material.dart';

class Subheader extends StatelessWidget {
  const Subheader({super.key, required this.text, this.textAlign = TextAlign.start});

  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.secondary),
    );
  }
}
