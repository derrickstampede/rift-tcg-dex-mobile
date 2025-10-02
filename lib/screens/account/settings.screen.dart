import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rift/main.dart';

import 'package:rift/routes/config.dart';

import 'package:rift/helpers/auth.helper.dart';
import 'package:rift/helpers/profile.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';

import 'package:rift/models/profile.model.dart';

import 'package:rift/providers/conversions.provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Profile? _profile;

  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final profile = await fetchProfile();
    setState(() {
      _isLoading = false;
      _profile = profile;
    });
    if (profile == null) {
      showSnackbar('Unable to load profile');
    }
  }

  void _delete() async {
    setState(() {
      _isDeleting = true;
    });

    final response = await deleteProfile();
    response.fold((l) {
      logEvent(name: 'account_delete');
      _logout();
    }, (r) {
      // TODO error handling
    });
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    await clearProfile();
    _resetConversions();

    showSnackbar('Account permanently deleted');
    _popAtStart();
  }

  void _resetConversions() {
    ref.read(conversionsNotifierProvider.notifier).search();
  }

  void _popAtStart() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _launchAdsCenter() async {
    final Uri uri = Uri.parse('https://myadcenter.google.com/home');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 1,
      ),
      body: _isLoading || _isDeleting
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _profile != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Symbols.settings_account_box),
                      title: const Text(
                        'User Preferences',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3),
                      ),
                      subtitle: const Text(
                        'Personalize your app experience',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Symbols.chevron_forward),
                      onTap: () {
                        const route = '/profile/settings/user-preferences';
                        Config.router.navigateTo(context, route);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Symbols.star),
                      title: const Text(
                        'Apply Promo Code',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3),
                      ),
                      subtitle: const Text(
                        'Get special offers on PRO features!',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Symbols.chevron_forward),
                      onTap: () {
                        const route = '/profile/settings/trial-code';
                        Config.router.navigateTo(context, route);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Symbols.analytics),
                      title: const Text(
                        'Analytics Manager',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3),
                      ),
                      subtitle: const Text(
                        'Manage your analytics settings',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Symbols.chevron_forward),
                      onTap: () {
                        const route = '/profile/settings/consent-manager';
                        Config.router.navigateTo(context, route);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Symbols.ads_click),
                      title: const Text(
                        'Ad Preferences',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3),
                      ),
                      subtitle: const Text(
                        'Personalize Google Ads behavior',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Symbols.chevron_forward),
                      onTap: () {
                        _launchAdsCenter();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Symbols.cancel),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3),
                      ),
                      subtitle: const Text(
                        'Permanently delete your account',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Symbols.chevron_forward),
                      onTap: () {
                        showDeleteAccountDialog(context, delete: _delete);
                      },
                    ),
                  ],
                )
              : const Center(
                  child: Text('Unable to load profile'),
                ),
    );
  }
}
