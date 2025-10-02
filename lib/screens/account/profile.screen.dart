import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/themes/theme-extension.dart';

import 'package:rift/helpers/profile.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/util.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/models/profile.model.dart';

import 'package:rift/widgets/auth/signin-button.widget.dart';
import 'package:rift/widgets/misc/pro-badge.widget.dart';
import 'package:rift/widgets/subscription/subscription-box-sm.widget.dart';
import 'package:rift/widgets/cards/card-price.widget.dart';
import 'package:rift/widgets/preferences/currency-dropdown.widget.dart';
import 'package:rift/widgets/misc/subheader.widget.dart';
import 'package:rift/widgets/trial-codes/promoted-button.widget.dart';

import 'package:rift/routes/config.dart';

import 'package:rift/constants/main-card-search.constant.dart';

import 'package:rift/providers/card-search.provider.dart';
import 'package:rift/providers/decks.provider.dart';
import 'package:rift/providers/vaults.provider.dart';
import 'package:rift/providers/conversions.provider.dart';
import 'package:rift/providers/promoted-trial-code.provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Session? session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  Profile? _profile;
  ProfileStat? _profileStats;
  List<Market> _markets = [];

  bool _isLoadingMarkets = true;
  bool _isUploadingPhoto = false;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);
  bool _initPro = true;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        session = data.session;
        if (session == null) {
          _profile = null;
          return;
        } else {
          _fetchAll();
        }
      });
    });

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed) {
    //     if (!_initPro && !_isPro) {
    //       _storeProfile();
    //     }
    //     if (!_isPro) {
    //       _fetchAll();
    //     }
    //     if (mounted) setState(() => _isPro = isSubscribed);
    //   }

    //   if (mounted) setState(() => _initPro = false);
    // });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    _fetchStorage();
    _fetchStats();
  }

  void _fetchStorage() async {
    final profile = await fetchProfile();

    if (profile == null) return;
    if (profile.maxDecks == null || profile.usernameChanges == null) {
      _findProfile(profile.userUid);
      return;
    }

    setState(() {
      _profile = profile;
    });
  }

  void _findProfile(String userUid) async {
    final response = await findProfile(userUid);
    response.fold(
      (l) {
        setState(() {
          _profile = l['profile'];
          saveProfile(_profile!);
        });
      },
      (r) {
        // TODO error handling
        print(r);
      },
    );
  }

  Future<void> _storeProfile() async {
    if (_profile == null) return;

    await storeProfile(_profile!.userUid);
    _fetchStorage();
  }

  void _pickProfilePhoto() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Take a Photo'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Select from Gallery'),
            ),
          ],
        );
      },
    );

    if (source == null) {
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source, imageQuality: 85, maxHeight: 300, maxWidth: 300);

    if (file != null) {
      setState(() => _isUploadingPhoto = true);
      final String filetype = file.path.split('.').last;
      final imageFile = File(file.path);
      List<int> imageBytes = imageFile.readAsBytesSync();
      String base64 = base64Encode(imageBytes);

      final response = await updateProfilePhoto(base64, filetype);
      response.fold(
        (l) {
          setState(() {
            _profile!.photo = l['photo'];
          });

          saveProfile(_profile!);
          setState(() => _isUploadingPhoto = false);
          logEvent(name: 'account_upload_photo');
        },
        (r) {
          // TODO error handling
          setState(() => _isUploadingPhoto = false);
        },
      );
    }
  }

  void _fetchStats() async {
    final profile = await fetchProfile();
    if (profile == null) return;

    final statResponse = await fetchProfileStats(userUid: profile.userUid);
    statResponse.fold(
      (l) {
        setState(() {
          _profileStats = l['stats'];
          if (_profile != null && _profile!.maxVaults != null && _profile!.maxVaults! < 8) {
            setState(() => _profileStats!.maxVaults = 8);
          }
          if (_isPro) {
            setState(() {
              _profileStats!.maxDecks = int.parse(dotenv.env['SUBSCRIBED_DECK_LIMIT']!);
              _profileStats!.maxVaults = int.parse(dotenv.env['SUBSCRIBED_VAULT_LIMIT']!);
            });
          }

          _fetchMarkets();
        });
      },
      (r) {
        // TODO error handling
        print(r);
      },
    );
  }

  void _fetchMarkets() async {
    setState(() => _isLoadingMarkets = true);

    final marketResponse = await fetchProfileMarkets();
    marketResponse.fold(
      (l) {
        setState(() {
          _markets = l['markets'];
          _isLoadingMarkets = false;
        });
      },
      (r) {
        // TODO error handling
        print(r);
      },
    );
  }

  void _goToUpdate() async {
    const route = '/profile/update';
    final isUpdated = await Config.router.navigateTo(context, route);
    if (isUpdated != null) {
      _fetchStorage();
      showSnackbar('Profile updated successfully');
    }
  }

  void _goToUpdateUsername() async {
    const route = '/profile/update-username';
    final isUpdated = await Config.router.navigateTo(context, route);
    if (isUpdated != null) {
      _fetchStorage();
      showSnackbar('Username updated successfully');
    }
  }

  void _goToSettings() async {
    const route = '/profile/settings';
    // final settingsResponse =
    await Config.router.navigateTo(context, route);
    // print(settingsResponse);
    // if (settingsResponse != null) {
    //   print(settingsResponse['is_deleted']);
    //   print(settingsResponse['is_deletedds']);
    // }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    await clearProfile();

    ref.watch(vaultListNotifierProvider.notifier).reset();
    ref.watch(deckListNotifierProvider.notifier).reset();

    ref
        .watch(cardSearchNotifierProvider(screen: MAIN_CARD_SCREEN, cardSearch: MAIN_CARD_SEARCH).notifier)
        .search(refresh: true);

    setState(() {
      _profileStats = null;
    });

    showSnackbar('Logged out successfully');
  }

  Future<void> _showCurrencyConverterDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(height: 32, width: double.infinity),
                CurrencyDropdown(
                  refreshOnChange: false,
                  onChange: (int? selectedCountry) {
                    ref.read(conversionsNotifierProvider.notifier).updateIsLoading(true);
                    ref.read(conversionsNotifierProvider.notifier).search();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final trialCode$ = ref.watch(trialCodesProvider);
    final conversions$ = ref.watch(conversionsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (session != null)
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Symbols.edit_square_rounded, size: 18),
                        ),
                        Text('Edit Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: [
                        Padding(padding: EdgeInsets.only(right: 8.0), child: Icon(Symbols.settings, size: 18)),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(Symbols.logout, size: 18, color: Theme.of(context).colorScheme.error),
                        ),
                        Text('Log out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  _goToUpdate();
                }
                if (value == 1) {
                  _goToSettings();
                }
                if (value == 2) {
                  _logout();
                }
              },
            ),
        ],
        elevation: 1,
      ),
      body:
          session != null
              ? RefreshIndicator(
                onRefresh: _fetchAll,
                child: ListView(
                  children: [
                    const SizedBox(height: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: Container(
                                  color: Colors.grey,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child:
                                        _profile?.photo != null
                                            ? FancyShimmerImage(imageUrl: _profile!.photo!, boxFit: BoxFit.cover)
                                            : Image.asset('assets/images/avatar.jpg'),
                                  ),
                                ),
                              ),
                            ),
                            if (_isUploadingPhoto) const Positioned.fill(child: CircularProgressIndicator()),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: SizedBox(
                                height: 32,
                                width: 32,
                                child: ElevatedButton(
                                  onPressed: _pickProfilePhoto,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(4),
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                  ),
                                  child: const Icon(Symbols.edit, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        //   child: SelectableText(
                        //     _profile != null ? '${session!.accessToken}' : '-',
                        //     style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
                        //   ),
                        // ),
                        if (_profile != null && _profile!.displayName != null)
                          Text(
                            _profile!.displayName!,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        RichText(
                          text: TextSpan(
                            text: '',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium!.color,
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                            ),
                            children: [
                              if (_isPro)
                                const WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: ProBadge(showUnlock: false),
                                  ),
                                ),
                              TextSpan(text: _profile != null ? '@${_profile!.username}' : '-'),
                              const WidgetSpan(child: SizedBox(width: 4)),
                              if (_profile != null && _profile!.usernameChanges! <= 0)
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: ElevatedButton(
                                      onPressed: _goToUpdateUsername,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(4),
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                      ),
                                      child: const Icon(Symbols.edit_square_rounded, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!_isPro && trialCode$.valueOrNull == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SubscriptionBoxSm(source: 'profile'),
                      ),
                    if (!_isPro && trialCode$.valueOrNull != null) const TrialCodePromotedButton(),
                    const SizedBox(height: 16),
                    if (!_isLoadingMarkets)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var market in _markets)
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Column(
                                      children: [
                                        SizedBox(width: 86, height: 42, child: Image.network(market.squareLogo)),
                                        (market.isPro && !_isPro)
                                            ? const ProBadge(showUnlock: true)
                                            : Column(
                                              children: [
                                                if (_isPro && !conversions$.isLoading)
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                                                    child: CardPrice(
                                                      price:
                                                          market.total *
                                                          ref
                                                              .read(conversionsNotifierProvider.notifier)
                                                              .findRate(market.currency)
                                                              .rate,
                                                      currency: 'USD',
                                                      fontSize: 18,
                                                      replaceSymbol: conversions$.symbol,
                                                      color: context.proColor.color,
                                                    ),
                                                  ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                                                  child: CardPrice(
                                                    price: market.total,
                                                    currency: market.currency,
                                                    fontSize: _isPro && !conversions$.isLoading ? 12 : 18,
                                                    format: market.format,
                                                  ),
                                                ),
                                              ],
                                            ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Symbols.currency_exchange, size: 20),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.proColor.colorContainer,
                              foregroundColor: context.proColor.onColorContainer,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            ),
                            onPressed: () {
                              if (!_isPro) {
                                // showSubscribeDialog(context: context, source: 'card-view');
                                return;
                              }
                              _showCurrencyConverterDialog();
                            },
                            label: const Text('Change Currency'),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    Center(
                      child: SizedBox(
                        width: 250,
                        child: GridView.count(
                          crossAxisCount: 2,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          children: <Widget>[
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Subheader(text: 'Total Cards'),
                                  FittedBox(
                                    child: Text(
                                      _profileStats != null ? '${_profileStats!.totalCards}' : '-',
                                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Subheader(text: 'Unique Cards'),
                                  FittedBox(
                                    child: Text(
                                      _profileStats != null ? '${_profileStats!.uniqueCards}' : '-',
                                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Subheader(text: 'Total Decks'),
                                  FittedBox(
                                    child: RichText(
                                      text: TextSpan(
                                        text: _profileStats != null ? '${_profileStats!.totalDecks}' : '-',
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyMedium!.color,
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        children: [
                                          if (_profileStats != null)
                                            TextSpan(
                                              text: " / ${_profileStats!.maxDecks}",
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyMedium!.color,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Subheader(text: 'Total Vaults'),
                                  FittedBox(
                                    child: RichText(
                                      text: TextSpan(
                                        text: _profileStats != null ? '${_profileStats!.totalVaults}' : '-',
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyMedium!.color,
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        children: [
                                          if (_profileStats != null)
                                            TextSpan(
                                              text: " / ${_profileStats!.maxVaults}",
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyMedium!.color,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              )
              : SigninButton(fetchStorage: _fetchAll),
    );
  }
}
