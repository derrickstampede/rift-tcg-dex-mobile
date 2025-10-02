import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart' as http;

import 'package:rift/screens/account/consent-manager.screen.dart';

class ConsentWrapper extends StatefulWidget {
  final Widget child;

  const ConsentWrapper({super.key, required this.child});

  @override
  State<ConsentWrapper> createState() => _ConsentWrapperState();
}

class _ConsentWrapperState extends State<ConsentWrapper> {
  @override
  void initState() {
    super.initState();
    _showPreemptiveDialog();
  }

  // Check if user is in the EU based on their IP
  Future<bool> _isUserInEU() async {
    try {
      // Using a free IP geolocation API
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // EU country codes
        final euCountries = [
          'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR',
          'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL',
          'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'GB' // GB included for UK
        ];
        return euCountries.contains(data['country_code']);
      }
      return false; // Default to false if API fails
    } catch (e) {
      print('Error detecting location: $e');
      return false; // Default to false on error
    }
  }

  Future<void> _showPreemptiveDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownConsent = prefs.getBool('has_shown_consent_v2') ?? false;

    // Only proceed with consent dialog if the user is in the EU
    final isEUUser = await _isUserInEU();
    if (!hasShownConsent && isEUUser && mounted) {
      // Wait a moment to let the app initialize
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Privacy Settings'),
                content: const SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "To improve our app, we'd like to gather some anonymous usage insights. Rest assured, we NEVER collect sensitive personal data.",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('CUSTOMIZE', style: TextStyle(color: Colors.grey[500])),
                    onPressed: () {
                      _pop();
                      _checkAndShowConsentDialog();
                    },
                  ),
                  TextButton(
                    child: Text('ALLOW', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    onPressed: () async {
                      if (mounted) {
                        await _allowCookies();
                        await prefs.setBool('has_shown_consent_v2', true);
                        _pop();
                      }
                    },
                  ),
                ],
              );
            },
          );
        }
      });
    }
  }

  Future<void> _checkAndShowConsentDialog() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Privacy Settings'),
            content: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We value your privacy. Please choose how you want your data to be used:',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  ConsentManagerWidget(showSaveButton: false),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Save'),
                onPressed: () async {
                  await prefs.setBool('has_shown_consent_v2', true);
                  if (mounted) {
                    _pop();
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _allowCookies() async {
    final prefs = await SharedPreferences.getInstance();

    // Save settings to SharedPreferences
    await prefs.setBool('consent_analytics_storage', true);
    await prefs.setBool('consent_ad_storage', true);
    await prefs.setBool('consent_ad_user_data', true);
    await prefs.setBool('consent_ad_personalization', true);

    final isProd = bool.parse(dotenv.env['IS_PROD']!);
    if (isProd) {
      // Update Firebase Analytics consent settings
      await FirebaseAnalytics.instance.setConsent(
        analyticsStorageConsentGranted: true,
        adStorageConsentGranted: true,
        adUserDataConsentGranted: true,
        personalizationStorageConsentGranted: true,
      );
    }
  }

  void _pop() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
