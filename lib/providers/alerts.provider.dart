import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/models/alert.model.dart';

import 'package:rift/repositories/alerts.repository.dart';

import 'package:rift/repositories/alerts-repository.provider.dart';

part 'alerts.provider.g.dart';

class AlertSearch with ChangeNotifier {
  List<Alert> alerts;
  int unread;

  AlertSearch({
    required this.alerts,
    required this.unread,
  });

  Map<String, dynamic> toJson() => {
        'alerts': alerts.map((c) => c.toJson()).toList(),
        'unread': unread,
      };

  factory AlertSearch.fromMap(Map<String, dynamic> map) => AlertSearch(
      alerts: map['alerts'] != null ? map['alerts'].map<Alert>((c) => Alert.fromMap(c)).toList() : [],
      unread: map['unread']);
}

@riverpod
class AlertsNotifier extends _$AlertsNotifier {
  late final AlertsRepository alertsRepository;

  @override
  AlertSearch build() {
    alertsRepository = ref.watch(alertsRepositoryProvider);
    getLatest();

    return AlertSearch(alerts: [], unread: 0);
  }

  Future<void> getLatest() async {
    try {
      final alerts = await alertsRepository.latestAlerts();
      update(AlertSearch(alerts: alerts, unread: alerts.where((alert) => !alert.hasViewed).length));
    } catch (e) {
      // update([]);
    }
  }

  void update(AlertSearch value) => state = value;

  void viewAlert(int index) {
    AlertSearch alertSearch = state;
    alertSearch.alerts[index].hasViewed = true;

    alertSearch.unread = alertSearch.alerts.where((alert) => !alert.hasViewed).length;

    update(AlertSearch(alerts: alertSearch.alerts, unread: alertSearch.unread));

    alertsRepository.viewAlert(alertSearch.alerts[index].id);
  }
}
