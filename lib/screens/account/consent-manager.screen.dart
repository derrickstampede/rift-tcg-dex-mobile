import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentManagerWidget extends StatefulWidget {
  final bool showSaveButton;

  const ConsentManagerWidget({super.key, this.showSaveButton = true});

  @override
  State<ConsentManagerWidget> createState() => _ConsentManagerWidgetState();
}

class _ConsentManagerWidgetState extends State<ConsentManagerWidget> {
  bool analyticsConsent = false;
  bool adStorageConsent = false;
  bool adUserDataConsent = false;
  bool adPersonalizationConsent = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsentSettings();
  }

  Future<void> _loadConsentSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      analyticsConsent = prefs.getBool('consent_analytics_storage') ?? true;
      adStorageConsent = prefs.getBool('consent_ad_storage') ?? true;
      adUserDataConsent = prefs.getBool('consent_ad_user_data') ?? true;
      adPersonalizationConsent = prefs.getBool('consent_ad_personalization') ?? true;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          title: const Text('Analytics Storage'),
          subtitle: const Text('Allow us to analyze app usage to improve experience'),
          value: analyticsConsent,
          onChanged: (value) {
            setState(() {
              analyticsConsent = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Ad Storage'),
          subtitle: const Text('Allow us to store information for ads'),
          value: adStorageConsent,
          onChanged: (value) {
            setState(() {
              adStorageConsent = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Ad User Data'),
          subtitle: const Text('Allow us to use your data to show relevant ads'),
          value: adUserDataConsent,
          onChanged: (value) {
            setState(() {
              adUserDataConsent = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Ad Personalization'),
          subtitle: const Text('Allow personalized ads'),
          value: adPersonalizationConsent,
          onChanged: (value) {
            setState(() {
              adPersonalizationConsent = value;
            });
          },
        ),
        if (widget.showSaveButton)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary)),
              child: Text('Save Preferences', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
              onPressed: () {
                _updateConsentSettings();
              },
            ),
          ),
      ],
    );
  }

  Future<void> _updateConsentSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Save settings to SharedPreferences
    await prefs.setBool('consent_analytics_storage', analyticsConsent);
    await prefs.setBool('consent_ad_storage', adStorageConsent);
    await prefs.setBool('consent_ad_user_data', adUserDataConsent);
    await prefs.setBool('consent_ad_personalization', adPersonalizationConsent);

    // Update Firebase Analytics consent settings
    await FirebaseAnalytics.instance.setConsent(
      analyticsStorageConsentGranted: analyticsConsent ? true : false,
      adStorageConsentGranted: adStorageConsent ? true : false,
      adUserDataConsentGranted: adUserDataConsent ? true : false,
      personalizationStorageConsentGranted: adPersonalizationConsent ? true : false,
    );

    if (mounted && widget.showSaveButton) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Privacy preferences updated')),
      );
    }
  }
}

class ConsentManagerScreen extends StatelessWidget {
  const ConsentManagerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Manager'),
        elevation: 1,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage your privacy settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Update how your data is collected and used in the app',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            ConsentManagerWidget(),
          ],
        ),
      ),
    );
  }
}
