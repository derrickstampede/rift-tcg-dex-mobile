import 'dart:async';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/models/conversion.model.dart';

import 'package:rift/repositories/conversions.repository.dart';
import 'package:rift/repositories/conversions-repository.provider.dart';

part 'conversions.provider.g.dart';

@riverpod
class ConversionsNotifier extends _$ConversionsNotifier {
  late final ConversionsRepository conversionsRepository;
  final defaultValue = ConversionsResponse(conversions: [], symbol: null, isLoading: true);

  @override
  ConversionsResponse build() {
    conversionsRepository = ref.watch(conversionsRepositoryProvider);
    search();

    return ConversionsResponse(conversions: [], symbol: null, isLoading: true);
  }

  Future<void> search() async {
    try {
      final conversions = await conversionsRepository.searchConversions();
      update(conversions);
    } catch (e) {
      update(ConversionsResponse(conversions: [], symbol: null, isLoading: false));
    }
  }

  void update(ConversionsResponse value) => state = value;

  void updateIsLoading(bool isLoading) {
    final newState = state;
    newState.isLoading = isLoading;

    update(newState);
  }

  Conversion findRate(String origin) {
    Conversion? conversion = state.conversions.firstWhereOrNull((c) => c.origin == origin);
    return conversion ?? Conversion(origin: origin, target: origin, rate: 1);
  }
}
