import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/repositories/card-search.repository.dart';

part 'card-search-repository.provider.g.dart';

@riverpod
CardSearchRepository cardSearchRepository(CardSearchRepositoryRef ref) {
  return CardSearchRepository();
}