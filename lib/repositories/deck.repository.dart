import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/models/deck.model.dart';

import 'package:rift/main.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

class DeckRepository {
  final String slug;

  DeckRepository(this.slug);

  Future<Deck> findDeck(String slug) async {
    try {
      final headers = {...httpHeaders};
      Session? session = supabase.auth.currentSession;
      if (session != null) {
        headers['AccessToken'] = session.accessToken;
      }

      final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug');
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final deck = Deck.fromMap(responseData['data']['deck']);
        return deck;
      } else {
        throw Exception('Failed to load deck');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load deck');
    }
  }
}
