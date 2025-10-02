import 'package:flutter/material.dart';

class Announcement with ChangeNotifier {
  final String title;
  final String subtitle;
  final String? image;
  final String? linkType;
  final String? link;

  Announcement({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.linkType,
    required this.link,
  });

  factory Announcement.fromMap(Map<String, dynamic> map) => Announcement(
        title: map['title'],
        subtitle: map['subtitle'],
        image: map['image'],
        linkType: map['link_type'],
        link: map['link'],
      );
}