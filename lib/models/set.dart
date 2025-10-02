import 'package:flutter/material.dart';

class Set with ChangeNotifier {
  final int id;
  final String name;
  final String slug;
  final int order;
  final DateTime releasedAt;

  Set({required this.id, required this.name, required this.slug, required this.order, required this.releasedAt});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug, 'order': order, 'released_at': releasedAt};

  factory Set.fromJson(Map<String, dynamic> json) => Set(
    id: json['id'],
    name: json['name'],
    slug: json['slug'],
    order: json['order'],
    releasedAt: json['released_at'],
  );
}
