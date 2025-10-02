import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/repositories/conversions.repository.dart';

part 'conversions-repository.provider.g.dart';

@riverpod
ConversionsRepository conversionsRepository(ConversionsRepositoryRef ref) {
  return ConversionsRepository();
}