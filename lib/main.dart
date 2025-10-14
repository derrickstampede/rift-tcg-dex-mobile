import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluro/fluro.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'globals.dart';
import 'firebase_options.dart';

import 'package:rift/themes/theme.dart';

import 'package:rift/routes/router.dart';
import 'package:rift/routes/config.dart' as app_config;

import 'package:rift/screens/home.screen.dart';

import 'package:rift/widgets/analytics/consent-wrapper.widget.dart';

import 'package:rift/helpers/revenuecat.helper.dart';
import 'package:rift/helpers/review.helper.dart';

import 'services/notification.service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    // await dotenv.load(fileName: ".env.dev");

    final router = FluroRouter.appRouter;
    FluroRoutes.configureRouter(router);
    app_config.Config.router = router;

    final isProd = bool.parse(dotenv.env['IS_PROD']!);
    if (isProd) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      print("Firebase initialized");

      final analytics = FirebaseAnalytics.instance;
      print("Firebase Analytics initialized");

      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

      FlutterError.onError = (errorDetails) {
        print("Flutter error caught: ${errorDetails.exception}");
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        print("Platform error caught: $error");
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      await analytics.logEvent(name: 'app_started', parameters: {'timestamp': DateTime.now().toIso8601String()});

      await NotificationService.instance.initialize();
    }
  } catch (e, stack) {
    print("Failed to initialize Firebase: $e");
    print("Stack trace: $stack");
    rethrow;
  }

  try {
    await Supabase.initialize(url: dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_ANON_KEY']!);
  } catch (e, stack) {
    print("Failed to initialize Supabase: $e");
    print("Stack trace: $stack");
    rethrow;
  }

  try {
    await MobileAds.instance.initialize().then((initializationStatus) {
      final adapterStatuses = initializationStatus.adapterStatuses;
      adapterStatuses.forEach((adapter, status) {
        print('Adapter status for $adapter: ${status.state}');
      });

      // Add test device ID
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: ['f0a1326b7a2ca2d1f8bb1999677a91e8']),
      );
    });
  } catch (e, stack) {
    print("Failed to initialize Google Mobile Ads: $e");
    print("Stack trace: $stack");
  }

  // Clear old caches on app initialization for memory management
  try {
    await DefaultCacheManager().emptyCache();
    print("Cache cleared successfully");
  } catch (e) {
    print("Failed to clear cache: $e");
  }

  initializePreq();
  await initializeRevenueCat();

  runApp(const MyApp());
}

DateTime? _lastPressedExitAt;

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          final now = DateTime.now();
          if (_lastPressedExitAt == null || now.difference(_lastPressedExitAt!) > const Duration(seconds: 2)) {
            _lastPressedExitAt = now;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Press back again to exit")));
          } else {
            Navigator.of(context).pop();
          }
        },
        child: MaterialApp(
          title: 'RIFT TCG Dex',
          scaffoldMessengerKey: snackbarKey,
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorScheme: MaterialTheme.lightScheme()),
          darkTheme: ThemeData(useMaterial3: true, colorScheme: MaterialTheme.darkScheme()),
          themeMode: ThemeMode.system,
          home: const ConsentWrapper(child: HomeScreen()),
          // initialRoute: 'home',
        ),
      ),
    );
  }
}
