import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/models/conversion.model.dart';

import 'package:rift/main.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

class ConversionsRepository {
  ConversionsRepository();

  Future<ConversionsResponse> searchConversions() async {
    try {
      final headers = {...httpHeaders};
      Session? session = supabase.auth.currentSession;

      if (session == null) return ConversionsResponse(conversions: [], symbol: null, isLoading: false);
      headers['AccessToken'] = session.accessToken;

      Map<String, dynamic> queryParams = {};
      final url = Uri.https(dotenv.env['API']!, 'api/v1/conversions/search', queryParams);
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode != 200) {
        final err = json.decode(response.body);
        throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
      }

      final responseData = json.decode(response.body);
      final conversions = responseData['data']['conversions'].map<Conversion>((dynamic c) {
        return Conversion(
          origin: c['origin'],
          target: c['target'],
          rate: c['rate'],
        );
      }).toList();

      return ConversionsResponse(conversions: conversions, symbol: responseData['data']['symbol'], isLoading: false);
    } catch (e) {
      print(e);
      throw Exception('Failed to load cards');
    }
  }
}
