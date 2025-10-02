import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/repositories/deck.repository.dart';

part 'deck-repository.provider.g.dart';

@riverpod
DeckRepository deckRepository(DeckRepositoryRef ref, String slug) {
  return DeckRepository(slug);
}