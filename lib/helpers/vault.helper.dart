import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/models/vault.model.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

Future<Either<Map<String, dynamic>, dynamic>> searchVaults() async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/vaults/search');
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
      'vaults': responseData['data']['vaults'].map<Vault>((d) => Vault.fromMap(d)).toList(),
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> findVault(String slug) async {
  try {
    final headers = {...httpHeaders};
    final url = Uri.https(dotenv.env['API']!, 'api/v1/vaults/$slug');
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
      'vault': Vault.fromMap(responseData['data']['vault']),
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> storeVault(dynamic vault) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/vaults');
    final body = json.encode(vault);
    final response = await http.post(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode != 201) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({
      'is_created': responseData['data']['is_created'],
      'vault': responseData['data']['vault'],
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updateVault(dynamic vault, String slug) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/vaults/$slug');
    final body = json.encode(vault);
    final response = await http.patch(
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
      'is_updated': responseData['data']['is_updated'],
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updatePhoto(String slug, String base64, String filetype) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/vaults/$slug/upload-photo');
    final body = json.encode({
      "base64": base64,
      "filetype": filetype
    });
    final response = await http.patch(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['error']['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({
      'photo': responseData['data']['photo'],
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> deleteVault(String slug) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/vaults/$slug');
    final response = await http.delete(
      url,
      headers: headers,
    );

    if (response.statusCode != 201) {
      final err = json.decode(response.body);
      throw {"statusCode": response.statusCode, "statusText": err['statusText'], "message": err['error']['message']};
    }

    final responseData = json.decode(response.body);

    return left({
      'is_deleted': responseData['data']['is_deleted'],
      'vault': responseData['data']['vault'],
    });
  } catch (e) {
    return right(e);
  }
}

Future<Either<Map<String, dynamic>, dynamic>> updateSortingVault(String sortBy, bool isAscending, String slug) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/vaults/$slug/sorting');
    final body = json.encode({
      "sort_by": sortBy,
      "is_sort_ascending": isAscending,
    });
    final response = await http.patch(
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
      'is_updated': responseData['data']['is_updated'],
    });
  } catch (e) {
    return right(e);
  }
}