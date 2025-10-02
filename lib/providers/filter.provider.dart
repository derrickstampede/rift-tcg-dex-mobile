import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/models/filter.model.dart';

part 'filter.provider.g.dart';

@riverpod
Future<Filters> filters(FiltersRef ref) async {
  try {
    final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};
    final url = Uri.https(dotenv.env['API']!, 'api/v1/filters/search');
    final response = await http.get(
      url,
      headers: httpHeaders,
    );
    // final responseData = jsonDecode(utf8.decode(response.body.codeUnits)) as Map<String, dynamic>;
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final filters = Filters.fromMap(responseData['data']);
    
    return filters;
  } catch (e) {
    throw Exception('Failed to load filters: $e');
  }
}
