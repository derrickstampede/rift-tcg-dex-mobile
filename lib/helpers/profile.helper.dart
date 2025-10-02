import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/models/profile.model.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

Future<Either<Map<String, dynamic>, dynamic>> findProfile(String userUid) async {
  try {
    final url = Uri.https(dotenv.env['API']!, 'api/v1/profiles/$userUid');
    final response = await http.get(
      url,
      headers: httpHeaders,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);

    final Profile profile = Profile.fromJson(responseData['data']['profile']);

    return left({
      'profile': profile,
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> storeProfile(String userUid) async {
  try {
    final url = Uri.https(dotenv.env['API']!, 'api/v1/profiles');
    final body = json.encode({"user_uid": userUid});
    final response = await http.post(
      url,
      body: body,
      headers: httpHeaders,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);

    final Profile profile = Profile.fromJson(responseData['data']['profile']);
    await saveProfile(profile);

    return left({
      'profile_created': responseData['data']['is_created'],
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updateProfile(Map<String, dynamic> payload) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/profiles');
    final body = json.encode(payload);
    final response = await http.patch(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    return left({
      'profile_updated': true,
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updateUsername(Map<String, dynamic> payload) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/profiles/username');
    final body = json.encode(payload);
    final response = await http.patch(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {
        "statusCode": response.statusCode,
        "statusText": err['error']['statusText'],
        "message": err['error']['message']
      };
    }

    return left({
      'profile_updated': true,
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updateProfilePhoto(String base64, String filetype) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/profiles/upload-photo');
    final body = json.encode({"base64": base64, "filetype": filetype});
    final response = await http.patch(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {
        "statusCode": response.statusCode,
        "statusText": err['error']['statusText'],
        "message": err['error']['message']
      };
    }

    final responseData = json.decode(response.body);

    return left({
      'photo': responseData['data']['photo'],
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> profileSubscribe(bool subscribe) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/profiles/subscribe');
    final body = json.encode({"is_subscribed": subscribe});
    final response = await http.patch(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {
        "statusCode": response.statusCode,
        "statusText": err['error']['statusText'],
        "message": err['error']['message']
      };
    }

    return left({
      'profile_updated': true,
    });
  } catch (e) {
    return right(e);
  }
}

Future<void> saveProfile(Profile profile) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String encoded = jsonEncode(profile.toJson());
  prefs.setString('profile', encoded);
}

Future<Profile?> fetchProfile() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final profile = prefs.getString('profile');

  if (profile != null) {
    Map<String, dynamic> decoded = jsonDecode(profile);
    return Profile.fromJson(decoded);
  }

  return null;
}

Future<void> clearProfile() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('profile');
}

Future<Either<Map<String, dynamic>, dynamic>> fetchProfileStats({
  required String userUid,
}) async {
  try {
    final url = Uri.https(dotenv.env['API']!, '/api/v1/profiles/$userUid/stats');
    final response = await http.get(
      url,
      headers: httpHeaders,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);
    final stats = ProfileStat(
      totalCards: responseData['data']['totalCards'],
      uniqueCards: responseData['data']['uniqueCards'],
      totalDecks: responseData['data']['totalDecks'],
      totalVaults: responseData['data']['totalVaults'],
      maxDecks: responseData['data']['maxDecks'],
      maxVaults: responseData['data']['maxVaults'],
    );

    return left({'stats': stats});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> fetchProfileMarkets() async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, '/api/v1/profiles/collection');
    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    final responseData = json.decode(response.body);
    final markets = responseData['data']['markets'].map<Market>((dynamic c) {
      return Market(
        name: c['name'],
        language: c['language'],
        currency: c['currency'],
        squareLogo: c['square_logo'],
        isPro: c['is_pro'],
        format: c['format'],
        total: c['total'],
      );
    }).toList();

    return left({'markets': markets});
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> deleteProfile() async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/profiles/terminate');
    final body = json.encode({});
    final response = await http.delete(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['message']};
    }

    return left({
      'profile_deleted': true,
    });
  } catch (e) {
    return right(e);
  }
}
