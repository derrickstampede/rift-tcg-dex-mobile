import 'package:flutter/material.dart';

class TrialCode with ChangeNotifier {
  final int id;
  final bool isActive;
  final bool isAppleCode;
  final DateTime startAt;
  final DateTime endAt;
  final String? offering;
  final String? entitlement;
  final String? text;

  TrialCode({
    required this.id,
    required this.isActive,
    required this.isAppleCode,
    required this.startAt,
    required this.endAt,
    this.offering,
    this.entitlement,
    this.text,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'is_active': isActive,
        'is_apple_code': isAppleCode,
        'start_at': startAt,
        'end_at': endAt,
        'offering': offering,
        'entitlement': entitlement,
        'text': text,
      };

  factory TrialCode.fromMap(Map<String, dynamic> map) => TrialCode(
        id: map['id'],
        isActive: map['is_active'],
        isAppleCode: map['is_apple_code'],
        startAt: DateTime.parse(map['start_at']),
        endAt: DateTime.parse(map['end_at']),
        offering: map['offering'],
        entitlement: map['entitlement'],
        text: map['text'],
      );
}
