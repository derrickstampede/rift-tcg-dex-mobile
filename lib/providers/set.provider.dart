import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/models/set.dart';

part 'set.provider.g.dart';

@riverpod
Future<List<Set>> sets(SetsRef ref) async {
  final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};
  final url = Uri.https(dotenv.env['API']!, 'api/v1/sets/search');
  final response = await http.get(
    url,
    headers: httpHeaders,
  );
  final responseData = jsonDecode(response.body) as Map<String, dynamic>;
  final sets = responseData['data']['sets'].map<Set>((dynamic c) {
    return Set(
      id: c['id'],
      name: c['name'],
      slug: c['slug'],
      order: c['order'],
      releasedAt: DateTime.parse(c['released_at']),
    );
  }).toList();
  
  return sets;
}
