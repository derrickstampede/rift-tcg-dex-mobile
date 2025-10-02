import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/models/device.model.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

Future<Device> extractDevice(String userUid) async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Device device = Device(userUid: userUid, name: null, os: null, version: null, manufacturer: null);

  if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    device.name = iosInfo.name;
    device.os = iosInfo.systemName;
    device.version = iosInfo.systemVersion;
    device.manufacturer = "Apple";
  }
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    device.name = androidInfo.model;
    device.os = "Android";
    device.version = androidInfo.version.sdkInt.toString();
    device.manufacturer = androidInfo.manufacturer;
  }

  return device;
}

Future<Either<Map<String, dynamic>, dynamic>> storeDevice(Device device) async {
  try {
    final headers = {...httpHeaders};
    Session? session = supabase.auth.currentSession;
    if (session != null) {
      headers['AccessToken'] = session.accessToken;
    }

    final url = Uri.https(dotenv.env['API']!, 'api/v1/devices');
    final body = json.encode(device.toJson());
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

    return left({
      'device_created': responseData['data']['is_created'],
    });
  } catch (e) {
    return right(e);
  }
}
