import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/models/trial-code.model.dart';

part 'promoted-trial-code.provider.g.dart';

@riverpod
Future<TrialCode?> trialCodes(TrialCodesRef ref) async {
  final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};
  final url = Uri.https(dotenv.env['API']!, 'api/v1/trial-codes/promoted');
  final response = await http.get(
    url,
    headers: httpHeaders,
  );
  final responseData = jsonDecode(response.body) as Map<String, dynamic>;
  final trialCode = responseData['data'] != null ? TrialCode.fromMap(responseData['data']['trial_code']) : null;

  return trialCode;
}
