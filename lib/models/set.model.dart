import 'package:flutter/material.dart';

class SetListItem with ChangeNotifier {
  final int id;
  final String name;
  final String slug;
  final int order;
  final DateTime releasedAt;

  SetListItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.order,
    required this.releasedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'order': order,
    'released_at': releasedAt,
  };
}
