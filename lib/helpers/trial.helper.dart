import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/main.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

Future<Either<Map<String, dynamic>, dynamic>> findTrial() async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/trials/find');
    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);
    return left({
      'has_trial': responseData['data']['has_trial'],
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> storeTrial(int trialCodeId) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/trials');
    final body = json.encode({"trial_code_id": trialCodeId});
    final response = await http.post(
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
    });
  } catch (e) {
    return right(e);
  }
}


Future<Either<Map<String, dynamic>, dynamic>> validateTrialCode(String code) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/trial-codes/validate');
    final body = json.encode({"code": code});
    final response = await http.post(
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
      'trial_code_id': responseData['data']['trial_code_id'],
      'trial_offering': responseData['data']['trial_offering'],
      'trial_is_apple_code': responseData['data']['trial_is_apple_code'],
      'code': responseData['data']['code'],
    });
  } catch (e) {
    return right(e);
  }
}


