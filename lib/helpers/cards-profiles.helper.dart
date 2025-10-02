import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/vault.model.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

Future<Either<Map<String, dynamic>, dynamic>> searchCardsProfiles(int cardId) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session == null) throw Exception('Session is null');

    headers['AccessToken'] = session.accessToken;

    Map<String, dynamic> queryParams = {};
    queryParams.putIfAbsent('card_id', () => cardId.toString());

    final url = Uri.https(dotenv.env['API']!, 'api/v1/cards-profiles/search', queryParams);
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
      'cardProfiles': responseData['data']['cardProfiles'].map<CardsProfiles>((d) => CardsProfiles.fromMap(d)).toList(),
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> storeCardsProfiles(List<CardsProfiles> cardsProfiles) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/cards-profiles');

    final payload = [];
    for (var i = 0; i < cardsProfiles.length; i++) {
      payload.add(cardsProfiles[i].toJson());
    }
    final body = json.encode({"cardsProfiles": payload});
    final response = await http.post(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    return left({
      'is_saved': true,
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> addToVault(CardsProfiles cardsProfile, Vault vault) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/cards-profiles/vault/add');
    final body =
        json.encode({"card_id": cardsProfile.cardId, "variant_id": cardsProfile.variantId, "vault_id": vault.id});
    final response = await http.post(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);
    final card = CardListItem.fromMap(responseData['data']['card']);

    return left({
      'card': card,
      'is_added': true,
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> removeFromVault(CardsProfiles cardsProfile, Vault vault) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/cards-profiles/vault/remove');
    final body =
        json.encode({"card_id": cardsProfile.cardId, "variant_id": cardsProfile.variantId, "vault_id": vault.id});
    final response = await http.post(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    return left({
      'is_removed': true,
    });
  } catch (e) {
    return right(e);
  }
}
