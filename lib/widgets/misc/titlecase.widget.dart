import 'package:flutter/material.dart';

class TitleCase extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TitleCase({Key? key, required this.text, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      toTitleCase(text),
      style: style,
    );
  }
}

String toTitleCase(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text.split(' ').map((word) {
    if (word.isEmpty) {
      return word;
    }
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}