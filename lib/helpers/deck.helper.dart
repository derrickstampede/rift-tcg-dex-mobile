import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/models/deck.model.dart';
import 'package:rift/models/card.model.dart';
import 'package:rift/models/note.model.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

Future<Either<Map<String, dynamic>, dynamic>> searchDecks() async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/search');
    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);

    return left({'decks': responseData['data']['decks'].map<Deck>((d) => Deck.fromMap(d)).toList()});
  } catch (e) {
    print(e);
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> findDeck(String slug) async {
  try {
    final headers = {...httpHeaders};
    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug');
    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);

    return left({'deck': Deck.fromMap(responseData['data']['deck'])});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> exportDeck(String slug) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }
    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug/export');
    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);

    return left({'deckExport': responseData['data']['deck']});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> findDeckStats(String slug) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug/stats');
    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);

    return left({
      'stats': DeckStats.fromMap(responseData['data']['stats']),
      'note': responseData['data']['note'] != null ? Note.fromMap(responseData['data']['note']) : null,
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> storeDeck(dynamic deck) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks');
    final body = json.encode(deck);
    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode != 201) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({'is_created': responseData['data']['is_created'], 'deck': responseData['data']['deck']});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> shareDeck(dynamic deckShare) async {
  try {
    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/share');
    final body = json.encode(deckShare);
    final response = await http.post(url, body: body, headers: httpHeaders);

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);
    final deckData = responseData['data']['deck'];
    final deck = Deck(
      id: deckData['id'],
      name: deckData['name'],
      slug: deckData['slug'],
      legend: CardListItem(
        id: deckData['legend']['id'],
        cardId: deckData['legend']['card_id'],
        name: deckData['legend']['name'],
        slug: deckData['legend']['slug'],
        set: null,
        thumbnail: deckData['legend']['thumbnail'],
        backThumbnail: deckData['legend']['back_thumbnail'],
        type: deckData['legend']['type'],
        color: deckData['legend']['color'],
        domain: deckData['legend']['domain'],
        energy: deckData['legend']['energy'],
        might: deckData['legend']['might'],
        rarity: deckData['legend']['rarity'],
        power: deckData['legend']['power'],
        count: deckData['legend']['count'],
        print: deckData['legend']['print'],
        orientation: deckData['legend']['orientation'],
        variant: deckData['legend']['variant'],
        variants:
            deckData['legend']['variants'] != null
                ? deckData['legend']['variants'].map<CardVariant>((v) => CardVariant.fromJson(v)).toList()
                    as List<CardVariant>
                : [],
        maxDeckCards: 0,
        note: null,
        cardsProfiles: [],
        conversions: [],
        yytJp: deckData['leader']['yyt_jp'],
        tcgpEn: deckData['leader']['tcgp_en'],
        cmEn: deckData['leader']['cm_en'],
        cmJp: deckData['leader']['cm_jp'],
      ),
      champion: CardListItem(
        id: deckData['champion']['id'],
        cardId: deckData['champion']['card_id'],
        name: deckData['champion']['name'],
        slug: deckData['champion']['slug'],
        set: null,
        thumbnail: deckData['champion']['thumbnail'],
        backThumbnail: deckData['champion']['back_thumbnail'],
        type: deckData['champion']['type'],
        color: deckData['champion']['color'],
        domain: deckData['champion']['domain'],
        energy: deckData['champion']['energy'],
        might: deckData['champion']['might'],
        rarity: deckData['champion']['rarity'],
        power: deckData['champion']['power'],
        count: deckData['champion']['count'],
        print: deckData['champion']['print'],
        orientation: deckData['champion']['orientation'],
        variant: deckData['champion']['variant'],
        variants:
            deckData['champion']['variants'] != null
                ? deckData['champion']['variants'].map<CardVariant>((v) => CardVariant.fromJson(v)).toList()
                    as List<CardVariant>
                : [],
        maxDeckCards: 0,
        note: null,
        cardsProfiles: [],
        conversions: [],
        yytJp: deckData['champion']['yyt_jp'],
        tcgpEn: deckData['champion']['tcgp_en'],
        cmEn: deckData['champion']['cm_en'],
        cmJp: deckData['champion']['cm_jp'],
      ),
      battlefield: CardListItem(
        id: deckData['battlefield']['id'],
        cardId: deckData['battlefield']['card_id'],
        name: deckData['battlefield']['name'],
        slug: deckData['battlefield']['slug'],
        set: null,
        thumbnail: deckData['battlefield']['thumbnail'],
        backThumbnail: deckData['battlefield']['back_thumbnail'],
        type: deckData['battlefield']['type'],
        color: deckData['battlefield']['color'],
        domain: deckData['battlefield']['domain'],
        energy: deckData['battlefield']['energy'],
        might: deckData['battlefield']['might'],
        rarity: deckData['battlefield']['rarity'],
        power: deckData['battlefield']['power'],
        count: deckData['battlefield']['count'],
        print: deckData['battlefield']['print'],
        orientation: deckData['battlefield']['orientation'],
        variant: deckData['battlefield']['variant'],
        variants:
            deckData['battlefield']['variants'] != null
                ? deckData['battlefield']['variants'].map<CardVariant>((v) => CardVariant.fromJson(v)).toList()
                    as List<CardVariant>
                : [],
        maxDeckCards: 0,
        note: null,
        cardsProfiles: [],
        conversions: [],
        yytJp: deckData['battlefield']['yyt_jp'],
        tcgpEn: deckData['battlefield']['tcgp_en'],
        cmEn: deckData['battlefield']['cm_en'],
        cmJp: deckData['battlefield']['cm_jp'],
      ),
      note: null,
      sortBy: 'card',
      isSortAscending: true,
      cards:
          deckData['cards'].map<CardListItem>((dynamic c) {
            return CardListItem(
              id: c['id'],
              name: c['name'],
              slug: c['slug'],
              cardId: c['card_id'],
              set: null,
              thumbnail: c['thumbnail'],
              backThumbnail: c['back_thumbnail'],
              type: c['type'],
              color: c['color'],
              rarity: c['rarity'],
              domain: c['domain'],
              energy: c['energy'],
              might: c['might'],
              power: c['power'],
              print: c['print'],
              orientation: c['orientation'],
              count: c['count'],
              variant: c['variant'],
              variants:
                  c['variants'] != null
                      ? c['variants'].map<CardVariant>((v) => CardVariant.fromJson(v)).toList() as List<CardVariant>
                      : [],
              maxDeckCards: 0,
              note: null,
              cardsProfiles: [],
              conversions: [],
              yytJp: c['yyt_jp'],
              tcgpEn: c['tcgp_en'],
              cmEn: c['cm_en'],
              cmJp: c['cm_jp'],
            );
          }).toList(),
      markets: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return left({'deck': deck});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> copyDeck(String slug, bool isPro) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug/copy');
    final body = json.encode({"is_pro": isPro});
    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode != 201) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({'is_created': responseData['data']['is_created'], 'deck': responseData['data']['deck']});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updateDeck(dynamic deck, String slug) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug');
    final body = json.encode(deck);
    final response = await http.patch(url, body: body, headers: headers);

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({'is_updated': responseData['data']['is_updated']});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updateLegendDeck(String slug, int leaderId) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug/update-legend');
    final body = json.encode({"card_id": leaderId});
    final response = await http.patch(url, body: body, headers: headers);

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({'is_updated': responseData['data']['is_updated']});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updateChampionDeck(String slug, int championId) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug/update-champion');
    final body = json.encode({"card_id": championId});
    final response = await http.patch(url, body: body, headers: headers);

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({'is_updated': responseData['data']['is_updated']});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updateBattlefieldDeck(String slug, int battlefieldId) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug/update-battlefield');
    final body = json.encode({"card_id": battlefieldId});
    final response = await http.patch(url, body: body, headers: headers);

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({'is_updated': responseData['data']['is_updated']});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updateSortingDeck(String sortBy, bool isAscending, String slug) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug/sorting');
    final body = json.encode({"sort_by": sortBy, "is_sort_ascending": isAscending});
    final response = await http.patch(url, body: body, headers: headers);

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({'is_updated': responseData['data']['is_updated']});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updatePublicDeck(bool isPublic, String slug) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug/public');
    final body = json.encode({"is_public": isPublic});
    final response = await http.patch(url, body: body, headers: headers);

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({'is_updated': responseData['data']['is_updated']});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> importDeck(Map<String, dynamic> payload) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/import/onepiecetopdecks2');
    final response = await http.post(url, body: json.encode(payload), headers: headers);

    if (response.statusCode != 201) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({'is_created': responseData['data']['is_created'], 'deck': responseData['data']['deck']});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> deleteDeck(String slug) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/decks/$slug');
    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 201) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({'is_deleted': responseData['data']['is_deleted'], 'deck': responseData['data']['deck']});
  } catch (e) {
    return right(e);
  }
}
