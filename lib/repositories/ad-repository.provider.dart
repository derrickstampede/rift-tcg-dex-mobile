import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/repositories/ad.repository.dart';

part 'ad-repository.provider.g.dart';

@riverpod
AdRepository adRepository(AdRepositoryRef ref) {
  return AdRepository();
}