import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/models/announcement.model.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

Future<Either<Map<String, dynamic>, dynamic>> latestAnnouncement() async {
  try {
    final url = Uri.https(dotenv.env['API']!, '/api/v1/announcements/latest');
    final response = await http.get(
      url,
      headers: httpHeaders,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);
    Announcement? announcement;
    if (responseData['data']['announcement'] != null) {
      announcement = Announcement.fromMap(responseData['data']['announcement']);
    }

    return left({'announcement': announcement});
  } catch (e) {
    return right(e);
  }
}
