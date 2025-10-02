import 'package:flutter/material.dart';

class Note with ChangeNotifier {
  final String type;
  final String typeId;
  final String note;

  Note({
    required this.type,
    required this.typeId,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'type_id': typeId,
        'note': note,
      };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        typeId: map['type_id'].toString(),
        type: map['type'],
        note: map['note'],
      );
}
