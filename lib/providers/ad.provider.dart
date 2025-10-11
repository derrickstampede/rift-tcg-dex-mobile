import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rift/repositories/ad.repository.dart';
import 'package:rift/repositories/ad-repository.provider.dart';

import 'package:rift/helpers/analytics.helper.dart';

import 'package:rift/models/app-config.model.dart';

part 'ad.provider.g.dart';

class AdConfig with ChangeNotifier {
  bool isLoading;
  AppConfig appConfig;
  InterstitialAd? interstitialAd;

  AdConfig({
    required this.isLoading,
    required this.appConfig,
    required this.interstitialAd,
  });

  Map<String, dynamic> toJson() => {
        'isLoading': isLoading,
        'appConfig': appConfig.toJson(),
        'interstitialAd': interstitialAd,
      };

  factory AdConfig.fromMap(Map<String, dynamic> map) => AdConfig(
        isLoading: map['isLoading'],
        appConfig: AppConfig.fromMap(map['appConfig']),
        interstitialAd: map['interstitialAd'],
      );
}

@riverpod
class AdNotifier extends _$AdNotifier {
  late final AdRepository adRepository;

  @override
  AdConfig build() {
    adRepository = ref.watch(adRepositoryProvider);
    Timer(const Duration(seconds: 1), () {
      loadAppConfig();
      loadAd();
    });
    saveStartupTime();

    return AdConfig(
        isLoading: true,
        appConfig: AppConfig(
            id: 1,
            adBannerCardsPerAd: int.parse(dotenv.env['AD_BANNER_CARDS_PER_AD']!),
            adInterstitialShowSecondsFromStartup: int.parse(dotenv.env['AD_INTERSTITIAL_SHOW_SECONDS_FROM_STARTUP']!),
            adInterstitialShowShowEveryMinutes: int.parse(dotenv.env['AD_INTERSTITIAL_SHOW_EVERY_MINUTES']!)),
        interstitialAd: null);
  }

  void update(AdConfig value) => state = value;

  Future<void> loadAppConfig() async {
    try {
      final appConfig = await adRepository.loadAppConfig();
      final newState = AdConfig(
          isLoading: false,
          appConfig: AppConfig(
              id: 1,
              adBannerCardsPerAd: appConfig.adBannerCardsPerAd,
              adInterstitialShowSecondsFromStartup: appConfig.adInterstitialShowSecondsFromStartup,
              adInterstitialShowShowEveryMinutes: appConfig.adInterstitialShowShowEveryMinutes),
          interstitialAd: state.interstitialAd);
      update(newState);
    } catch (e) {
      final newState = AdConfig(
          isLoading: false,
          appConfig: AppConfig(
              id: 1,
              adBannerCardsPerAd: state.appConfig.adBannerCardsPerAd,
              adInterstitialShowSecondsFromStartup: state.appConfig.adInterstitialShowSecondsFromStartup,
              adInterstitialShowShowEveryMinutes: state.appConfig.adInterstitialShowShowEveryMinutes),
          interstitialAd: state.interstitialAd);
      update(newState);
    }
  }

  Future<void> loadAd() async {
    try {
      final interstitialAd = await adRepository.loadInterstitialAd();
      final newState = AdConfig(
          isLoading: state.isLoading,
          appConfig: AppConfig(
              id: 1,
              adBannerCardsPerAd: state.appConfig.adBannerCardsPerAd,
              adInterstitialShowSecondsFromStartup: state.appConfig.adInterstitialShowSecondsFromStartup,
              adInterstitialShowShowEveryMinutes: state.appConfig.adInterstitialShowShowEveryMinutes),
          interstitialAd: interstitialAd);
      update(newState);
    } catch (e) {
      nullInterstitialAd();
    }
  }

  void nullInterstitialAd() {
    final newState = AdConfig(
        isLoading: state.isLoading,
        appConfig: AppConfig(
            id: 1,
            adBannerCardsPerAd: state.appConfig.adBannerCardsPerAd,
            adInterstitialShowSecondsFromStartup: state.appConfig.adInterstitialShowSecondsFromStartup,
            adInterstitialShowShowEveryMinutes: state.appConfig.adInterstitialShowShowEveryMinutes),
        interstitialAd: null);
    update(newState);
  }

  Future<void> showInterstitialAd() async {
    print('Attempting to show interstitial ad...');
    final ad = state.interstitialAd;
    if (ad == null) {
      print('No interstitial ad loaded, loading new ad...');
      loadAd();
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final startupDatetime = prefs.getString('startupDatetime');
    if (startupDatetime == null) {
      print('No startup time found, saving current time...');
      saveStartupTime();
      return;
    }

    final now = DateTime.now();
    final startup = DateTime.parse(startupDatetime);
    if (now.difference(startup).inSeconds < state.appConfig.adInterstitialShowSecondsFromStartup) {
      print(
          'STARTUP TIME: ${now.difference(startup).inSeconds} secs lapsed : ${state.appConfig.adInterstitialShowSecondsFromStartup} secs (too soon)');
      return;
    }
    print('Startup time check passed: ${now.difference(startup).inSeconds} seconds elapsed');

    final loadedMinuteGap = state.appConfig.adInterstitialShowShowEveryMinutes;
    String? adLoadedDatetime = prefs.getString('adLoadedDatetime');
    adLoadedDatetime ??=
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().subtract(Duration(minutes: loadedMinuteGap)));
    final loaded = DateTime.parse(adLoadedDatetime);
    if (now.difference(loaded).inMinutes < loadedMinuteGap) {
      print(
          'LOADED TIME: ${now.difference(loaded).inMinutes} mins lapsed : ${state.appConfig.adInterstitialShowShowEveryMinutes} mins (too soon)');
      return;
    }
    print('Ad frequency check passed: ${now.difference(loaded).inMinutes} minutes since last ad');

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('Interstitial ad dismissed');
        logEvent(name: 'ad_interstitial_impression', parameters: {
          'platform': Platform.isIOS ? 'ios' : 'android',
          'ad_type': 'interstitial',
          'action': 'dismissed',
        });

        nullInterstitialAd();
        ad.dispose();
        loadAd();

        saveLoadedTime();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        logEvent(name: 'ad_interstitial_show_failed', parameters: {
          'platform': Platform.isIOS ? 'ios' : 'android',
          'error_code': error.code.toString(),
          'error_message': error.message,
        });
        
        nullInterstitialAd();
        ad.dispose();
        loadAd();
      },
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        logEvent(name: 'ad_interstitial_shown', parameters: {
          'platform': Platform.isIOS ? 'ios' : 'android',
          'ad_type': 'interstitial',
        });
      },
    );

    print('Showing interstitial ad...');
    ad.show();
  }

  Future<void> saveStartupTime() async {
    final formattedNow = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('startupDatetime', formattedNow);
  }

  Future<void> saveLoadedTime() async {
    final formattedNow = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('adLoadedDatetime', formattedNow);
  }
}
