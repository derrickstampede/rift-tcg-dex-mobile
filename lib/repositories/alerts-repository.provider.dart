import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/repositories/alerts.repository.dart';

part 'alerts-repository.provider.g.dart';

@riverpod
AlertsRepository alertsRepository(AlertsRepositoryRef ref) {
  return AlertsRepository();
}