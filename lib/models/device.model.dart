import 'package:flutter/material.dart';

class Device with ChangeNotifier {
  String userUid;
  String? name;
  String? os;
  String? version;
  String? manufacturer;

  Device({
    required this.userUid,
    required this.name,
    required this.os,
    required this.version,
    required this.manufacturer,
  });

  Map<String, dynamic> toJson() => {
    'user_uid': userUid,
    'name': name,
    'os': os,
    'version': version,
    'manufacturer': manufacturer,
  };
}
