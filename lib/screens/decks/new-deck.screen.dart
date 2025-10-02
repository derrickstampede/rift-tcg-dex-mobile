import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rift/models/deck.model.dart';
import 'package:rift/providers/decks.provider.dart';

import 'package:rift/widgets/decks/deck-import.widget.dart';
import 'package:rift/widgets/decks/deck-form.widget.dart';
// import 'package:rift/widgets/decks/deck-scan-qr.widget.dart';

class NewDeckScreen extends ConsumerStatefulWidget {
  const NewDeckScreen({super.key});

  @override
  ConsumerState<NewDeckScreen> createState() => _NewDeckScreenState();
}

class _NewDeckScreenState extends ConsumerState<NewDeckScreen> {
  final int _pageIndex = 0;

  void _goBack(Deck deck) {
    ref.read(deckListNotifierProvider.notifier).add(deck);
    Navigator.pop(context, deck);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Deck"),
        elevation: 1,
      ),
      body: DeckCreateForm(goBack: _goBack),
    );
    // DefaultTabController(
    //   initialIndex: _pageIndex,
    //   length: 2,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: const Text("New Deck"),
    //       elevation: 1,
    //       bottom: const TabBar(
    //         tabs: <Widget>[
    //           Tab(
    //             text: 'Select Leader',
    //           ),
    //           Tab(
    //             text: 'Import Code',
    //           ),
    //           // Tab(
    //           //   text: 'Scan QR',
    //           // ),
    //         ],
    //       ),
    //     ),
    //     body: TabBarView(
    //       children: <Widget>[
    //         DeckCreateForm(goBack: _goBack),
    //         DeckImport(
    //           goBack: _goBack,
    //         ),
    //         // DeckScanQR(goBack: _goBack),
    //       ],
    //     ),
    //   ),
    // );
  }
}
