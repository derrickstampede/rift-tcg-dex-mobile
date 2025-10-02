import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/models/deck.model.dart';

import 'package:rift/main.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

class DecksRepository {
  DecksRepository();

  Future<Map<String, dynamic>> search() async {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/search');
    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {
        'decks': responseData['data']['decks'].map<Deck>((d) => Deck.fromMap(d)).toList(),
        'sortBy': responseData['data']['sort_by'],
        'isSortAscending': responseData['data']['is_sort_ascending'],
      };
    } else {
      throw Exception('Failed to load deck list');
    }
  }

  Future<void> updateDeckSorting(String sortBy, bool isSortAscending) async {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/profiles/sorting');
    final body = json.encode({"type": "deck", "sort_by": sortBy, "is_sort_ascending": isSortAscending});
    final response = await http.patch(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to update deck sorting');
    }
  }

  Future<void> delete(String slug) async {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug');
    final response = await http.delete(
      url,
      headers: headers,
    );

    if (response.statusCode == 201) {
      return;
    } else {
      throw Exception('Failed to delete deck');
    }
  }
}
