import 'dart:convert';

import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/helpers/analytics.helper.dart';

String storageName = 'reviewPreq';

Future<Map<String, dynamic>> initializePreq() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final preq = prefs.getString(storageName);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    if (preq == null) {
      Map<String, dynamic> newPreq = await setPreq(version, DateTime.now().toIso8601String());
      return newPreq;
    }

    Map<String, dynamic> decodedPreq = jsonDecode(preq);
    if (decodedPreq['version'] != version) {
      Map<String, dynamic> newPreq = await setPreq(version, decodedPreq['date']);
      return newPreq;
    }

    return decodedPreq;
  } catch (e) {
    // TODO: error handling
    throw Error();
  }
}

Future<void> incrementReviewPreq(event) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> preq = await initializePreq();
    Map<String, dynamic> newPreq = {...preq, event: ++preq[event]};

    String encoded = jsonEncode(newPreq);
    prefs.setString(storageName, encoded);
  } catch (e) {
    // TODO: error handling
    throw Error();
  }
}

Future<void> askReview() async {
  try {
    Map<String, dynamic> preq = await initializePreq();

    final int minDays = int.parse(dotenv.env['REVIEW_PREQ_DAYS']!);
    final int minDeckCompletions = int.parse(dotenv.env['REVIEW_PREQ_COMPLETE_DECK']!);
    final int minCollectionUpdates = int.parse(dotenv.env['REVIEW_PREQ_UPDATE_COLLECTION']!);

    final int days = DateTime.now().difference(DateTime.parse(preq['date'])).inDays;
    if (days >= minDays &&
        (preq['deck_complete'] >= minDeckCompletions || preq['collection_update'] >= minCollectionUpdates)) {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
        resetPreq();

        logEvent(name: 'review_ask');
      }
    }
  } catch (e) {
    // TODO: error handling
  }
}

Future<void> resetPreq() async {
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    await setPreq(version, DateTime.now().toIso8601String());
  } catch (e) {
    // TODO: error handling
  }
}

Future<Map<String, dynamic>> setPreq(String version, String date) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> preq = {'version': version, 'date': date, 'deck_complete': 0, 'collection_update': 0};
    String encoded = jsonEncode(preq);
    prefs.setString(storageName, encoded);

    return preq;
  } catch (e) {
    // TODO: error handling
    throw Error();
  }
}

Future<void> removePreq() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageName);
  } catch (e) {
    // TODO: error handling
  }
}
