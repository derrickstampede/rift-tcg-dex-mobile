import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:rift/models/app-config.model.dart';

final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};

class AdRepository {
  AdRepository();

  Timer? _adLoadTimer;
  bool _isLoading = false;

  void cancelTimers() {
    _adLoadTimer?.cancel();
    _adLoadTimer = null;
  }

  Future<InterstitialAd?> loadInterstitialAd() async {
    // Debounce ad loading to prevent excessive requests
    if (_isLoading) {
      return null;
    }

    _isLoading = true;
    _adLoadTimer?.cancel();

    final completer = Completer<InterstitialAd?>();

    _adLoadTimer = Timer(const Duration(seconds: 2), () async {
      try {
        final String adUnitId =
            Platform.isIOS ? dotenv.env['AD_INTERSTITIAL_IOS']! : dotenv.env['AD_INTERSTITIAL_ANDROID']!;

        await InterstitialAd.load(
          adUnitId: adUnitId,
          request: const AdRequest(
            // Enhanced targeting for interstitial ads
            keywords: ['games', 'trading cards', 'gundam', 'tcg', 'card game'],
            nonPersonalizedAds: false,
          ),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (loadedAd) {
              _isLoading = false;
              completer.complete(loadedAd);
            },
            onAdFailedToLoad: (LoadAdError error) {
              _loadInterstitialAdFallback(adUnitId, completer);
            },
          ),
        );
      } catch (e) {
        print('Error loading ad: $e');
        _isLoading = false;
        completer.complete(null);
      }
    });

    return completer.future;
  }

  Future<void> _loadInterstitialAdFallback(String adUnitId, Completer<InterstitialAd?> completer) async {
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(
        keywords: ['games', 'mobile'],
        nonPersonalizedAds: true, // Fallback to non-personalized
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (loadedAd) {
          completer.complete(loadedAd);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoading = false;
          completer.complete(null);
        },
      ),
    );
  }

  static AppConfig? _cachedAppConfig;
  static DateTime? _lastConfigFetch;
  static const Duration _cacheExpiry = Duration(hours: 24);

  Future<AppConfig> loadAppConfig() async {
    try {
      // Check if we have cached data that's still valid
      if (_cachedAppConfig != null &&
          _lastConfigFetch != null &&
          DateTime.now().difference(_lastConfigFetch!) < _cacheExpiry) {
        print('Using cached app config');
        return _cachedAppConfig!;
      }

      final headers = {...httpHeaders};
      final url = Uri.https(dotenv.env['API']!, 'api/v1/app-config');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final appConfig = AppConfig.fromMap(responseData['data']['appConfig']);

        // Cache the result
        _cachedAppConfig = appConfig;
        _lastConfigFetch = DateTime.now();
        print('App config cached successfully');

        return appConfig;
      } else {
        // If request fails and we have cached data, use it as fallback
        if (_cachedAppConfig != null) {
          print('Using cached app config as fallback');
          return _cachedAppConfig!;
        }
        throw Exception('Failed to load app config');
      }
    } catch (e) {
      print('Error loading app config: $e');
      // Use cached data as fallback if available
      if (_cachedAppConfig != null) {
        print('Using cached app config as fallback after error');
        return _cachedAppConfig!;
      }
      throw Exception('Failed to load app config');
    }
  }
}
