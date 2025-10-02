import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/note.model.dart';

import 'package:rift/main.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

class SearchResponse {
  List<CardListItem> cards;
  String? symbol;

  SearchResponse({required this.cards, required this.symbol});
}

class CardSearchRepository {
  CardSearchRepository();

  Future<SearchResponse> searchCards({
    bool collection = false,
    String? name,
    String? setId,
    List<String>? rarity,
    List<String>? language,
    List<String>? color,
    List<String>? type,
    List<String>? art,
    List<int>? cost,
    String? specifiedCost,
    List<int>? power,
    List<int>? awakenPower,
    List<String>? feature,
    List<String>? effect,
    String? asc,
    String? desc,
    int? offset,
  }) async {
    try {
      final headers = {...httpHeaders};
      Session? session = supabase.auth.currentSession;
      if (session != null) {
        headers['AccessToken'] = session.accessToken;
      }

      Map<String, dynamic> queryParams = {};
      if (collection) {
        queryParams.putIfAbsent('collection', () => "true");
      }
      if (name != null) {
        queryParams.putIfAbsent('name', () => name);
      }
      if (setId != null) {
        queryParams.putIfAbsent('set', () => setId);
      }
      if (rarity != null && rarity.isNotEmpty) {
        queryParams.putIfAbsent('rarity', () => rarity.join(","));
      }
      if (language != null && language.isNotEmpty) {
        queryParams.putIfAbsent('language', () => language.join(","));
      }
      if (color != null && color.isNotEmpty) {
        queryParams.putIfAbsent('color', () => color.join(","));
      }
      if (type != null && type.isNotEmpty) {
        queryParams.putIfAbsent('type', () => type.join(","));
      }
      if (art != null && art.isNotEmpty) {
        queryParams.putIfAbsent('art', () => art.join(","));
      }

      if (cost != null && cost.isNotEmpty) {
        queryParams.putIfAbsent('cost', () => cost.join(","));
      }
      if (specifiedCost != null) {
        queryParams.putIfAbsent('specifiedCost', () => specifiedCost);
      }
      if (power != null && power.isNotEmpty) {
        queryParams.putIfAbsent('power', () => power.join(","));
      }
      if (awakenPower != null && awakenPower.isNotEmpty) {
        queryParams.putIfAbsent('awakenPower', () => awakenPower.join(","));
      }

      if (feature != null) {
        queryParams.putIfAbsent('feature', () => feature);
      }
      if (effect != null && effect.isNotEmpty) {
        queryParams.putIfAbsent('effect', () => effect.join(","));
      }

      if (asc != null) {
        queryParams.putIfAbsent('asc', () => asc);
      }
      if (desc != null) {
        queryParams.putIfAbsent('desc', () => desc);
      }

      if (offset != null) {
        queryParams.putIfAbsent('offset', () => offset.toString());
      }

      final url = Uri.https(dotenv.env['API']!, 'api/v1/cards/search', queryParams);
      final response = await http.get(url, headers: headers);

      if (response.statusCode != 200) {
        final err = json.decode(response.body);
        throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
      }

      final responseData = json.decode(response.body);
      final cards =
          responseData['data']['cards'].map<CardListItem>((dynamic c) {
            return CardListItem(
              id: c['id'],
              cardId: c['card_id'],
              name: c['name'],
              slug: c['slug'],
              set: CardSet.fromMap(c['set']),
              thumbnail: c['thumbnail'],
              backThumbnail: c['back_thumbnail'],
              type: c['type'],
              rarity: c['rarity'],
              color: c['color'],
              domain: c['domain'],
              energy: c['energy'],
              might: c['might'],
              print: c['print'],
              orientation: c['orientation'],
              power: c['power'],
              variant: c['variant'],
              variants:
                  c['variants'] != null
                      ? c['variants'].map<CardVariant>((v) => CardVariant.fromJson(v)).toList() as List<CardVariant>
                      : [],
              cardsProfiles:
                  c['cardsProfiles'] != null
                      ? c['cardsProfiles'].map<CardsProfiles>((v) => CardsProfiles.fromJson(v)).toList()
                          as List<CardsProfiles>
                      : [],
              conversions:
                  c['conversions'] != null
                      ? c['conversions']
                              .map<CardListItemConversions>((v) => CardListItemConversions.fromJson(v))
                              .toList()
                          as List<CardListItemConversions>
                      : [],
              maxDeckCards: c['max_deck_cards'],
              note: c['note'] != null ? Note.fromMap(c['note']) : null,
              count: 0,
              yytJp: c['yyt_jp'],
              tcgpEn: c['tcgp_en'],
              cmEn: c['cm_en'],
              cmJp: c['cm_jp'],
            );
          }).toList();

      return SearchResponse(cards: cards, symbol: responseData['data']['symbol']);
    } catch (e) {
      print(e);
      throw Exception('Failed to load cards');
    }
  }
}
