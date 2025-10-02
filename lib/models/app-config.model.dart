import 'package:flutter/material.dart';

class AppConfig with ChangeNotifier {
  final int id;
  final int adBannerCardsPerAd;
  final int adInterstitialShowSecondsFromStartup;
  final int adInterstitialShowShowEveryMinutes;

  AppConfig({
    required this.id,
    required this.adBannerCardsPerAd,
    required this.adInterstitialShowSecondsFromStartup,
    required this.adInterstitialShowShowEveryMinutes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ad_banner_cards_per_ad': adBannerCardsPerAd,
        'ad_interstitial_show_seconds_from_startup': adInterstitialShowSecondsFromStartup,
        'ad_interstitial_show_every_minutes': adInterstitialShowShowEveryMinutes,
      };

  factory AppConfig.fromMap(Map<String, dynamic> map) => AppConfig(
        id: map['id'],
        adBannerCardsPerAd: map['ad_banner_cards_per_ad'],
        adInterstitialShowSecondsFromStartup: map['ad_interstitial_show_seconds_from_startup'],
        adInterstitialShowShowEveryMinutes: map['ad_interstitial_show_every_minutes'],
      );
}
