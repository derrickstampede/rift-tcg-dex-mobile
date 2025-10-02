import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/main.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

Future<Either<Map<String, dynamic>, dynamic>> updateNote(dynamic payload) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/notes');
    final body = json.encode(payload);
    final response = await http.patch(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({
      'is_created': responseData['data']['is_created'],
      'is_updated': responseData['data']['is_updated'],
    });
  } catch (e) {
    return right(e);
  }
}
