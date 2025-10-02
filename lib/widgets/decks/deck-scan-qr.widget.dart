import 'package:flutter/material.dart';

import 'package:rift/models/deck.model.dart';

class DeckScanQR extends StatefulWidget {
  const DeckScanQR({super.key, required this.goBack});

  final Function(Deck deck) goBack;

  @override
  State<DeckScanQR> createState() => _DeckScanQRState();
}

class _DeckScanQRState extends State<DeckScanQR> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // _selectDeckOrigin('opponent');
      },
      child: Center(
        child: Text(
          'Tap to Scan QR',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
