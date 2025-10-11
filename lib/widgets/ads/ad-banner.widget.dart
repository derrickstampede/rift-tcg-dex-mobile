import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rift/helpers/analytics.helper.dart';

import 'package:rift/main.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  Session? session = supabase.auth.currentSession;

  final String _adUnitId = Platform.isIOS ? dotenv.env['AD_BANNER_IOS']! : dotenv.env['AD_BANNER_ANDROID']!;

  BannerAd? _bannerAd;
  bool _failedLoad = false;
  AdSize _currentAdSize = AdSize.banner;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  void _loadAd() async {
    final int screenWidth = MediaQuery.of(context).size.width.truncate();

    final AdSize? adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(screenWidth);

    AdSize finalAdSize;
    if (adSize != null && adSize.height <= 80 && adSize.height >= 50) {
      finalAdSize = adSize;
    } else {
      finalAdSize = AdSize.banner;
    }
    _currentAdSize = finalAdSize;

    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(
        keywords: ['games', 'trading cards', 'gundam', 'tcg', 'card game'],
        nonPersonalizedAds: false,
      ),
      size: finalAdSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          final bannerAd = ad as BannerAd;
          _currentAdSize = bannerAd.size;
          setState(() => _failedLoad = false);
        },
        onAdFailedToLoad: (ad, err) {
          print('Banner ad failed to load: ${err.message}');
          setState(() => _failedLoad = true);
          ad.dispose();

          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) _retryWithFallback();
          });
        },
        onAdOpened: (Ad ad) {
          print('Banner ad opened');
        },
        onAdClosed: (Ad ad) {
          print('Banner ad closed');
        },
        onAdImpression: (Ad ad) {
          final bannerAd = ad as BannerAd;
          logEvent(
            name: 'ad_impression',
            parameters: {'platform': Platform.isIOS ? 'ios' : 'android', 'ad_size': bannerAd.size.toString()},
          );
        },
      ),
    )..load();
  }

  void _retryWithFallback() {
    _currentAdSize = AdSize.banner;

    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(keywords: ['games', 'mobile'], nonPersonalizedAds: true),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _failedLoad = false);
        },
        onAdFailedToLoad: (ad, error) {
          logEvent(
            name: 'ad_fallback_failed',
            parameters: {'platform': Platform.isIOS ? 'ios' : 'android', 'error_code': error.code.toString()},
          );
          ad.dispose();
        },
        onAdImpression: (Ad ad) {
          logEvent(name: 'ad_impression_fallback');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null && !_failedLoad) {
      final double width = _currentAdSize.width > 0 ? _currentAdSize.width.toDouble() : 320.0;
      final double height = (_currentAdSize.height > 0 ? _currentAdSize.height.toDouble() : 50.0).clamp(50.0, 80.0);

      return Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1), // Debug border
        ),
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return const SizedBox(height: 0);
    }
  }
}
