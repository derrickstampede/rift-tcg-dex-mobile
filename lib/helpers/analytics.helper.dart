import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> logEvent({required String name, Map<String, dynamic>? parameters}) async {
  try {
    final isProd = bool.parse(dotenv.env['IS_PROD']!);
    if (!isProd) {
      return;
    }

    if (name.length >= 7 &&
        name.substring(0, 7) == "filter_" &&
        parameters != null &&
        parameters.containsKey('value') &&
        parameters['value'] == null) {
      parameters['value'] = 'all';
    }
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    final Map<String, Object>? objectParameters = parameters?.map((key, value) => 
        MapEntry(key, value as Object));
    analytics.logEvent(name: name, parameters: objectParameters);
  } catch (e) {
    // TODO: error handling
  }
}
