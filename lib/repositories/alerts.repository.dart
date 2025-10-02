import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/models/alert.model.dart';

import 'package:rift/main.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

class AlertsRepository {
  AlertsRepository();

  Future<List<Alert>> latestAlerts() async {
    try {
      final headers = {...httpHeaders};
      Session? session = supabase.auth.currentSession;
      if (session != null) {
        headers['AccessToken'] = session.accessToken;
      }

      final url = Uri.https(dotenv.env['API']!, 'api/v1/alerts/latest');
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final alerts = responseData['data']['alerts'].map<Alert>((dynamic a) {
          return Alert(
            id: a['id'],
            title: a['title'],
            subtitle: a['subtitle'],
            link: a['link'],
            hasViewed: a['has_viewed'],
          );
        }).toList();
        return alerts;
      } else {
        throw Exception('Failed to load latest alerts');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load latest alerts');
    }
  }

  Future<void> viewAlert(int alertId) async {
    try {
      final headers = {...httpHeaders};
      Session? session = supabase.auth.currentSession;
      if (session != null) {
        headers['AccessToken'] = session.accessToken;
      }

      final url = Uri.https(dotenv.env['API']!, 'api/v1/alerts-profiles');
      final body = json.encode({"alert_id": alertId});
      final response = await http.post(
        url,
        body: body,
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load latest alerts');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load latest alerts');
    }
  }
}
