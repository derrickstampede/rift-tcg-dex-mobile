import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/models/stock.model.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

Future<Either<Map<String, dynamic>, dynamic>> fetchGraph({
  required int cardId,
}) async {
  try {
    Map<String, dynamic> queryParams = {};
    queryParams.putIfAbsent('card', () => cardId.toString());

    final url = Uri.https(dotenv.env['API']!, '/api/v1/stocks/graph', queryParams);
    final response = await http.get(
      url,
      headers: httpHeaders,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);
    final graphs = responseData['data']['graphs'].map<StockGraph>((dynamic g) {
      return StockGraph.fromMap(g);
    }).toList();

    return left({'graphs': graphs});
  } catch (e) {
    return right(e);
  }
}
