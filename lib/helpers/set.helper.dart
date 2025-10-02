import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/models/set.model.dart';

final Map<String, String> httpHeaders = {
  "Content-Type": "application/json",
  "APIKey": dotenv.env['API_KEY']!
};

Future<Either<Map<String, dynamic>, dynamic>> searchSets() async {
  try {
    final url = Uri.https(dotenv.env['API']!, 'api/v1/sets/search');
    final response = await http.get(
      url,
      headers: httpHeaders,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {
        "statusCode": response.statusCode,
        "statusText": err['statusText'],
        "message": err['message']
      };
    }

    final responseData = json.decode(response.body);
    final sets = responseData['data']['sets'].map<SetListItem>((dynamic c) {
      return SetListItem(
        id: c['id'],
        name: c['name'],
        slug: c['slug'],
        order: c['order'],
        releasedAt: DateTime.parse(c['released_at']),
      );
    }).toList();
    return left({
      'sets': sets,
    });
  } catch (e) {
    return right(e);
  }
}
