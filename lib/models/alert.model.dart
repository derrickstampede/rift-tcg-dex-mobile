import 'package:flutter/material.dart';

class Alert with ChangeNotifier {
  final int id;
  final String title;
  final String subtitle;
  final String link;
  bool hasViewed;

  Alert({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.link,
    required this.hasViewed,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'link': link,
        'has_viewed': hasViewed,
      };

  factory Alert.fromMap(Map<String, dynamic> map) => Alert(
        id: map['id'],
        title: map['title'],
        subtitle: map['subtitle'],
        link: map['link'],
        hasViewed: map['has_viewed'],
      );
}
