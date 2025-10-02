import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/models/vault.model.dart';
import 'package:rift/models/card.model.dart';

import 'package:rift/main.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

class VaultRepository {
  final String slug;

  VaultRepository(this.slug);

  Future<Vault> findVault(String slug) async {
    try {
      final headers = {...httpHeaders};
      Session? session = supabase.auth.currentSession;
      if (session != null) {
        headers['AccessToken'] = session.accessToken;
      }
      
      final url = Uri.https(dotenv.env['API']!, 'api/v1/vaults/$slug');
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Vault.fromMap(responseData['data']['vault']);
      } else {
        throw Exception('Failed to load vault');
      }
    } catch (e) {
      throw Exception('Failed to load vault');
    }
  }

  Future<List<CardListItem>> searchtVaultCards(String slug, int? offset, int? limit) async {
    try {
      final headers = {...httpHeaders};
      Session? session = supabase.auth.currentSession;
      if (session != null) {
        headers['AccessToken'] = session.accessToken;
      }

      Map<String, dynamic> queryParams = {};
      if (offset != null) {
        queryParams.putIfAbsent('offset', () => offset.toString());
      }
      if (limit != null) {
        queryParams.putIfAbsent('limit', () => limit.toString());
      }
      
      final url = Uri.https(dotenv.env['API']!, 'api/v1/vaults/$slug/cards', queryParams);
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data']['cards'].map<CardListItem>((dynamic c) {
          return CardListItem.fromMap(c);
        }).toList();
      } else {
        throw Exception('Failed to load vault');
      }
    } catch (e) {
      throw Exception('Failed to load vault');
    }
  }
}
