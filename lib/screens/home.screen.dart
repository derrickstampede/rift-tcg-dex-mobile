import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:gma_mediation_unity/gma_mediation_unity.dart' as mediation_unity;

import 'package:rift/main.dart';

import 'package:rift/screens/decks/decks.screen.dart';
import 'package:rift/screens/cards/cards.screen.dart';
import 'package:rift/screens/vaults/vaults.screen.dart';
// import 'package:rift/screens/battle/battle.screen.dart';
import 'package:rift/screens/account/profile.screen.dart';

import 'package:rift/providers/card-search.provider.dart';
import 'package:rift/providers/set.provider.dart';
import 'package:rift/providers/filter.provider.dart';
import 'package:rift/providers/market.provider.dart';
import 'package:rift/providers/decks.provider.dart';
import 'package:rift/providers/vaults.provider.dart';
import 'package:rift/providers/conversions.provider.dart';
import 'package:rift/providers/alerts.provider.dart';
// import 'package:rift/providers/ad.provider.dart';
import 'package:rift/providers/promoted-trial-code.provider.dart';

// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/constants/main-card-search.constant.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Session? session = supabase.auth.currentSession;

  late List<Widget> _pages;
  int _pageIndex = 0;

  @override
  void initState() {
    // Setup RC app id, get current user if available
    // supabase.auth.onAuthStateChange.listen((data) {
    //   setState(() {
    //     session = data.session;
    //     if (session != null) {
    //       loginRevenueCat(session!.user.id);
    //     } else {
    //       logoutRevenueCat();
    //     }
    //   });
    // });

    // Admob consent form
    // ConsentInformation.instance.requestConsentInfoUpdate(
    //   ConsentRequestParameters(),
    //   () async {
    //     bool isFormAvailable = await ConsentInformation.instance.isConsentFormAvailable();
    //     if (isFormAvailable) {
    //       _loadConsentForm();
    //     }
    //   },
    //   (FormError formError) {},
    // );
    // mediation_unity.GmaMediationUnity().setGDPRConsent(true);
    // mediation_unity.GmaMediationUnity().setCCPAConsent(true);

    _pages = [
      CardsScreen(
        searchScreen: MAIN_CARD_SCREEN,
        cardSearch: MAIN_CARD_SEARCH,
      ),
      const DecksScreen(),
      const VaultsScreen(),
      const ProfileScreen()
    ];

    super.initState();
  }

  void _loadConsentForm() {
    // ConsentForm.loadConsentForm(
    //   (ConsentForm consentForm) async {
    //     final consentStatus = await ConsentInformation.instance.getConsentStatus();
    //     if (consentStatus == ConsentStatus.required) {
    //       consentForm.show((FormError? formError) => _loadConsentForm());
    //     }
    //   },
    //   (FormError formError) {},
    // );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(setsProvider);
    ref.watch(filtersProvider);
    ref.watch(conversionsNotifierProvider);
    ref.watch(marketProvider);
    ref.watch(conversionsNotifierProvider);
    ref.watch(alertsNotifierProvider);
    // ref.watch(adNotifierProvider);
    ref.watch(trialCodesProvider);

    ref.watch(deckListNotifierProvider);
    ref.watch(vaultListNotifierProvider);

    ref.watch(cardSearchNotifierProvider(screen: MAIN_CARD_SCREEN, cardSearch: MAIN_CARD_SEARCH));

    return Scaffold(
      body: _pages[_pageIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            labelTextStyle: WidgetStateProperty.all(TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ))),
        child: NavigationBar(
          selectedIndex: _pageIndex,
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          backgroundColor: Theme.of(context).colorScheme.primary,
          onDestinationSelected: (int index) {
            setState(() {
              _pageIndex = index;
            });
          },
          destinations: <NavigationDestination>[
            NavigationDestination(
              selectedIcon: Icon(
                Symbols.search,
                color: Theme.of(context).colorScheme.primary,
              ),
              icon: Icon(
                Symbols.search,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: 'Search'.toUpperCase(),
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Symbols.stacks,
                color: Theme.of(context).colorScheme.primary,
              ),
              icon: Icon(
                Symbols.stacks,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: 'Decks'.toUpperCase(),
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Symbols.lock,
                color: Theme.of(context).colorScheme.primary,
              ),
              icon: Icon(
                Symbols.lock,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: 'Vaults'.toUpperCase(),
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Symbols.account_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              icon: Icon(
                Symbols.account_circle,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: 'Profile'.toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }
}