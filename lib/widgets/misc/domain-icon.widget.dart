import 'package:flutter/material.dart';

class DomainIcon extends StatelessWidget {
  const DomainIcon({super.key, required String domain}) : _domain = domain;

  final String _domain;

  @override
  Widget build(BuildContext context) {
    Widget image = SizedBox.shrink();

    switch (_domain) {
      case 'Body':
        image = Image.asset('assets/images/rune-body.webp');
        break;
      case 'Calm':
        image = Image.asset('assets/images/rune-calm.webp');
        break;
      case 'Chaos':
        image = Image.asset('assets/images/rune-chaos.webp');
        break;
      case 'Fury':
        image = Image.asset('assets/images/rune-fury.webp');
        break;
      case 'Mind':
        image = Image.asset('assets/images/rune-mind.webp');
        break;
      case 'Order':
        image = Image.asset('assets/images/rune-order.webp');
        break;
      case 'Orange':
        image = Image.asset('assets/images/rune-body.webp');
        break;
      case 'Green':
        image = Image.asset('assets/images/rune-calm.webp');
        break;
      case 'Purple':
        image = Image.asset('assets/images/rune-chaos.webp');
        break;
      case 'Red':
        image = Image.asset('assets/images/rune-fury.webp');
        break;
      case 'Blue':
        image = Image.asset('assets/images/rune-mind.webp');
        break;
      case 'Yellow':
        image = Image.asset('assets/images/rune-order.webp');
        break;
      default:
        image = SizedBox.shrink();
        break;
    }

    return SizedBox(width: 24, height: 24, child: image);
  }
}
