import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/deck.model.dart';
import 'package:rift/models/vault.model.dart';
import 'package:rift/models/note.model.dart';
import 'package:rift/models/card-translation.model.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

Future<Either<Map<String, dynamic>, dynamic>> findCard({
  required String id,
}) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, '/api/v1/cards/$id');
    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);
    final card = CardItemView(
        id: responseData['data']['card']['id'],
        cardId: responseData['data']['card']['card_id'],
        name: responseData['data']['card']['name'],
        backName: responseData['data']['card']['back_name'],
        slug: responseData['data']['card']['slug'],
        isParallel: responseData['data']['card']['is_parallel'],
        isSpecialParallel: responseData['data']['card']['is_special_parallel'],
        setId: responseData['data']['card']['set_id'],
        setName: responseData['data']['card']['set']['name'],
        rarity: responseData['data']['card']['rarity'],
        cost: responseData['data']['card']['cost'],
        specifiedCost: responseData['data']['card']['specified_cost'],
        power: responseData['data']['card']['power'],
        awakenPower: responseData['data']['card']['awaken_power'],
        combo: responseData['data']['card']['combo'],
        color: responseData['data']['card']['color'],
        type: responseData['data']['card']['type'],
        features: responseData['data']['card']['features'],
        awakenFeatures: responseData['data']['card']['awaken_features'],
        print: responseData['data']['card']['print'],
        image: responseData['data']['card']['image'],
        thumbnail: responseData['data']['card']['thumbnail'],
        backThumbnail: responseData['data']['card']['back_thumbnail'],
        backImage: responseData['data']['card']['back_image'],
        orientation: responseData['data']['card']['orientation'],
        effect: responseData['data']['card']['effect'],
        awakenEffect: responseData['data']['card']['awaken_effect'],
        originalId: responseData['data']['card']['original_id'],
        maxDeckCards: responseData['data']['card']['max_deck_cards'],
        variants: responseData['data']['card']['variants'].map<CardVariant>((v) => CardVariant.fromJson(v)).toList()
            as List<CardVariant>,
        cardsProfiles: responseData['data']['card']['cardsProfiles'] != null
            ? responseData['data']['card']['cardsProfiles']
                .map<CardsProfiles>((v) => CardsProfiles.fromJson(v))
                .toList() as List<CardsProfiles>
            : [],
        yytJp: responseData['data']['card']['yyt_jp'],
        tcgpEn: responseData['data']['card']['tcgp_en'],
        cmEn: responseData['data']['card']['cm_en'],
        cmJp: responseData['data']['card']['cm_jp']);

    final markets = responseData['data']['markets'].map<CardMarket>((v) => CardMarket.fromJson(v)).toList();
    final note = responseData['data']['note'] != null ? Note.fromMap(responseData['data']['note']) : null;
    final conversions = CardConversions.fromMap(responseData['data']['conversions']);
    final translation = responseData['data']['translation'] != null
        ? CardTranslation.fromMap(responseData['data']['translation'])
        : null;
    final translationError = responseData['data']['translation_error'];

    return left({
      'card': card,
      'markets': markets,
      'note': note,
      'conversions': conversions,
      'translation': translation,
      'translationError': translationError
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> findCardMany({
  required String ids,
}) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    Map<String, dynamic> queryParams = {};
    queryParams.putIfAbsent('card_id', () => ids);

    final url = Uri.https(dotenv.env['API']!, '/api/v1/cards/find', queryParams);
    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(utf8.decode(response.body.codeUnits));
    final cards = responseData['data']['cards'].map<CardCheck>((dynamic c) {
      return CardCheck(
          id: c['id'],
          name: c['name'],
          cardId: c['card_id'],
          cardsProfiles: c['cardsProfiles'] != null
              ? c['cardsProfiles'].map<CardsProfiles>((v) => CardsProfiles.fromJson(v)).toList() as List<CardsProfiles>
              : []);
    }).toList();

    return left({'cards': cards});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> findCardWhere(String id) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/cards/$id/where');
    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(utf8.decode(response.body.codeUnits));

    return left({
      'decks': responseData['data']['decks'].map<Deck>((d) => Deck.fromMap(d)).toList(),
      'vaults': responseData['data']['vaults'].map<Vault>((d) => Vault.fromMap(d)).toList(),
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> findCardByCardId(String cardId) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/cards/search/$cardId');
    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(utf8.decode(response.body.codeUnits));
    final cards = responseData['data']['cards'].map<CardItemView>((c) => CardItemView.fromMap(c)).toList();

    return left({
      'cards': cards,
    });
  } catch (e) {
    return right(e);
  }
}

List<List<CardListItem>> createCardBatches(List<CardListItem> cards) {
  List<List<CardListItem>> cardBatches = [];
  int batchLength = int.parse(dotenv.env['AD_BANNER_CARDS_PER_AD']!);

  for (int i = 0; i < cards.length; i += batchLength) {
    int end = (i + batchLength < cards.length) ? i + batchLength : cards.length;
    cardBatches.add(cards.sublist(i, end));
  }

  return cardBatches;
}
