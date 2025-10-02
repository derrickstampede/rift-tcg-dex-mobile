import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/repositories/decks.repository.dart';

part 'decks-repository.provider.g.dart';

@riverpod
DecksRepository decksRepository(DecksRepositoryRef ref) {
  return DecksRepository();
}