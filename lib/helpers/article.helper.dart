import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/models/article.model.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

Future<Either<Map<String, dynamic>, dynamic>> searchNews({int? offset}) async {
  try {
    Map<String, dynamic> queryParams = {};
    if (offset != null) {
      queryParams.putIfAbsent('offset', () => offset.toString());
    }

    final headers = {...httpHeaders};
    final url = Uri.https(dotenv.env['API']!, 'api/v1/news/search', queryParams);
    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);

    return left({
      'articles': responseData['data']['articles'].map<Article>((d) => Article.fromMap(d)).toList(),
    });
  } catch (e) {
    return right(e);
  }
}
