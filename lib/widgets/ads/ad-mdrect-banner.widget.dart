import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/widgets/ads/ad-banner.widget.dart';

import 'package:rift/main.dart';

class AdMdRectBanner extends StatefulWidget {
  const AdMdRectBanner({super.key});

  @override
  State<AdMdRectBanner> createState() => _AdMdRectBannerState();
}

class _AdMdRectBannerState extends State<AdMdRectBanner> {
  Session? session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;
  bool _isLoggedIn = false;

  final String _adUnitId = Platform.isIOS ? dotenv.env['AD_BANNER_IOS']! : dotenv.env['AD_BANNER_ANDROID']!;
  BannerAd? _bannerAd;
  bool _failedLoad = false;

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        session = data.session;
        if (session != null) {
          setState(() => _isLoggedIn = true);
        } else {
          setState(() => _isLoggedIn = false);
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(
        keywords: ['games', 'trading cards', 'gundam', 'tcg', 'card game'],
        nonPersonalizedAds: false,
      ),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('ad impression!');
          final bannerAd = ad as BannerAd;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          logEvent(
            name: 'ad_load_failed',
            parameters: {
              'platform': Platform.isIOS ? 'ios' : 'android',
              'ad_type': 'medium_rectangle',
              'error_code': error.code.toString(),
              'error_message': error.message,
              'ad_unit_id': _adUnitId,
            },
          );

          setState(() => _failedLoad = true);
          ad.dispose();

          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) _retryWithFallback();
          });
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {
          logEvent(name: 'ad_impression');
        },
      ),
    )..load();
  }

  void _retryWithFallback() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(
        keywords: ['games', 'mobile'],
        nonPersonalizedAds: true, // Fallback to non-personalized
      ),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // print('Fallback medium rectangle ad loaded');
          setState(() => _failedLoad = false);
        },
        onAdFailedToLoad: (ad, error) {
          // print('Fallback medium rectangle ad also failed: ${error.message}');
          logEvent(
            name: 'ad_fallback_failed',
            parameters: {
              'platform': Platform.isIOS ? 'ios' : 'android',
              'ad_type': 'medium_rectangle',
              'error_code': error.code.toString(),
            },
          );
          ad.dispose();
        },
        onAdImpression: (Ad ad) {
          logEvent(name: 'ad_impression_fallback', parameters: {'ad_type': 'medium_rectangle'});
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return _bannerAd != null && !_failedLoad
        ? Column(
          children: [
            SizedBox(width: 320, height: _bannerAd != null ? 250 : 0, child: AdWidget(ad: _bannerAd!)),
            if (_isLoggedIn)
              GestureDetector(
                onTap: () => showSubscribeDialog(context: context, source: 'ad-remove'),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Remove Ads',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ),
              ),
            const SizedBox(height: 4),
          ],
        )
        : const Column(
          children: [
            AdBanner(),
            SizedBox(height: 4),
          ],
        );
  }
}
