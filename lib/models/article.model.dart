import 'package:flutter/material.dart';

class Article with ChangeNotifier {
  int id;
  DateTime createdAt;
  String title;
  String source;
  String? author;
  String? image;
  String link;
  String? region;

  Article({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.source,
    required this.author,
    required this.image,
    required this.link,
    required this.region,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt,
        'title': title,
        'source': source,
        'author': author,
        'image': image,
        'link': link,
        'region': region,
      };

  factory Article.fromMap(Map<String, dynamic> map) => Article(
        id: map['id'],
        createdAt: DateTime.parse(map['created_at']),
        title: map['title'],
        source: map['source'],
        author: map['author'],
        image: map['image'],
        link: map['link'],
        region: map['region'],
      );
}
