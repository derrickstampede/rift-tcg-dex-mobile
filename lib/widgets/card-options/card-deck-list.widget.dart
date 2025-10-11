import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/providers/decks.provider.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/deck.model.dart';

import 'package:rift/widgets/cards/card-image.widget.dart';
import 'package:rift/widgets/misc/color-hexagon.widget.dart';

class CardDeckList extends ConsumerStatefulWidget {
  const CardDeckList({super.key, required this.card, required this.selectDeck});

  final CardItemView card;
  final Function(String slug) selectDeck;

  @override
  ConsumerState<CardDeckList> createState() => _CardDeckListState();
}

class _CardDeckListState extends ConsumerState<CardDeckList> {
  Session? _session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
        if (_session != null) {
          _fetchDecks(force: false);
        }
      });
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchDecks({required bool force}) async {
    await ref.watch(deckListNotifierProvider.notifier).search(force: force);
  }

  void _selectDeck(String slug) {
    widget.selectDeck(slug);
  }

  @override
  Widget build(BuildContext context) {
    final deckList$ = ref.watch(deckListNotifierProvider);
    List<Deck> allowedDecks = deckList$.decks;
    if (widget.card.color != null) {
      allowedDecks = deckList$.decks.where((d) => d.legend.color!.contains(widget.card.color!)).toList();
    }

    return (widget.card.type == 'Legend' || widget.card.type == 'Champion Unit' || widget.card.type == 'Battlefield')
        ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Legend, Champion Unit, or Battlefield cards cannot be added to a deck',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
            ),
          ),
        )
        : !deckList$.isLoading
        ? allowedDecks.isNotEmpty
            ? Column(
              children: [
                for (int i = 0; i < allowedDecks.length; i++)
                  ListTile(
                    leading: SizedBox(width: 42, child: CardImage(imageUrl: allowedDecks[i].legend.thumbnail)),
                    title: Text(
                      allowedDecks[i].name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${allowedDecks[i].legend.name} \u2981 ${allowedDecks[i].cardCount} cards',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectDeck(allowedDecks[i].slug),
                    trailing: ColorHexagon(size: 24, colors: allowedDecks[i].legend.color!),
                  ),
              ],
            )
            : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.card.color != null ? 'No ${widget.card.color!.toLowerCase()} decks yet' : 'No decks yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                ),
              ),
            )
        : const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: CircularProgressIndicator());
  }
}
