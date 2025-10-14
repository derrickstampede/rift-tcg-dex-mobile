import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rift/themes/theme-extension.dart';

import 'package:rift/helpers/profile.helper.dart';
import 'package:rift/helpers/trial.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';

Future<void> initializeRevenueCat() async {
  PurchasesConfiguration? configuration;

  final String? apiKey =
      Platform.isIOS || Platform.isMacOS ? dotenv.env['RC_PUBLIC_KEY_IOS'] : dotenv.env['RC_PUBLIC_KEY_ANDROID'];
  if (apiKey == null) return;

  configuration = PurchasesConfiguration(apiKey);
  final profile = await fetchProfile();
  if (profile != null) {
    configuration = PurchasesConfiguration(apiKey)..appUserID = profile.userUid;
  }

  await Purchases.configure(configuration);
}

Future<void> loginRevenueCat(String userUid) async {
  await Purchases.logIn(userUid);
}

Future<void> logoutRevenueCat() async {
  bool isAnonymous = await Purchases.isAnonymous;
  if (!isAnonymous) {
    await Purchases.logOut();
  }
}

bool checkIfSubscribed(CustomerInfo customerInfo) {
  if (customerInfo.entitlements.all.isEmpty) {
    return false;
  }
  EntitlementInfo? pro = customerInfo.entitlements.all['pro'];
  if (pro != null && pro.isActive) {
    return true;
  }
  EntitlementInfo? proPromo = customerInfo.entitlements.all['pro_promo'];
  if (proPromo != null && proPromo.isActive) {
    return true;
  }
  return false;
}

Future<void> showPaywall(String source) async {
  logEvent(name: 'subscription_paywall', parameters: {'source': source});
  final PaywallResult paywallResult = await RevenueCatUI.presentPaywallIfNeeded("pro");
  if (paywallResult == PaywallResult.purchased) {
    profileSubscribe(true);
  }
}

Future<bool> showTrialPaywall(int trialCodeId, String offering, String entitlement) async {
  logEvent(name: 'subscription_trial_paywall');

  Offerings offerings = await Purchases.getOfferings();
  Offering? promoOffering = offerings.all[offering];

  final PaywallResult paywallResult = await RevenueCatUI.presentPaywallIfNeeded(entitlement, offering: promoOffering);
  if (paywallResult == PaywallResult.purchased) {
    storeTrial(trialCodeId);
    return true;
  }

  return false;
}

Future<void> closeRevenueCat() async {
  await Purchases.close();
}

Future<void> openUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $uri');
  }
}

Future<bool> redeemAppleSubscriptionOfferCode() async {
  try {
    // Present the subscription offer code redemption sheet
    await Purchases.presentCodeRedemptionSheet();

    // After the sheet is dismissed, check if the user is now subscribed
    final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    final isSubscribed = checkIfSubscribed(customerInfo);

    if (isSubscribed) {
      profileSubscribe(true);
      return true;
    }

    return false;
  } catch (e) {
    print('Error redeeming Apple subscription offer code: $e');
    return false;
  }
}

Future<void> showSubscribeDialog({required BuildContext context, required String source}) async {
  final subVaultLimit = int.parse(dotenv.env['SUBSCRIBED_VAULT_LIMIT']!);
  final isSubscriptionEnabled = bool.parse(dotenv.env['ENABLE_SUBSCRIPTION']!);

  final dynamic features = [
    {
      'asset': Image.asset('assets/images/cardmarket-sm.png'),
      'title': 'Check Cardmarket Prices',
      'subtitle': 'Monitor the latest card prices in Cardmarket!',
    },
    {
      'asset': Icon(Symbols.currency_exchange, color: context.proColor.color),
      'title': 'Access Currency Converter',
      'subtitle': 'Automatically convert market card prices to your local currency!',
    },
    {
      'asset': Icon(Symbols.cancel, color: context.proColor.color),
      'title': 'Remove Ads',
      'subtitle': 'No more annoying ads!',
    },
    {
      'asset': Icon(Symbols.heart_plus, color: context.proColor.color),
      'title': 'Support The Developer',
      'subtitle': "I'm Friedrich, the dev of this app. Your support will help me to keep the app running!",
    },
    {
      'asset': Icon(Symbols.arrow_upward, color: context.proColor.color),
      'title': 'Increase Decks/Vaults to $subVaultLimit',
      'subtitle': 'Add more decks and vaults to your collection!',
    },
    {
      'asset': Icon(Symbols.edit_note, color: context.proColor.color),
      'title': 'Add Notes to Cards and Decks',
      'subtitle':
          'Attach a note and write anything you want - how much you bought the card, how to play the deck, etc!',
    },
    {
      'asset': Icon(Symbols.bar_chart_4_bars, color: context.proColor.color),
      'title': 'View Deck Statistics',
      'subtitle': 'Acquire in-depth info about your deck - analyze cost curves, counters and effects, and more!',
    },
  ];

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        // titlePadding: const EdgeInsets.all(0),
        title: Text(
          'Unlock PRO Features',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: context.proColor.color),
          textAlign: TextAlign.center,
        ),
        scrollable: true,
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            children: [
              const SizedBox(height: 16),
              ...features.map<Widget>((feature) {
                return ListTile(
                  leading: SizedBox(width: 42, height: 42, child: feature['asset']),
                  title: Text(
                    feature['title'],
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: context.proColor.color),
                  ),
                  subtitle: Text(feature['subtitle'], style: Theme.of(context).textTheme.bodyMedium),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: context.proColor.colorContainer),
                onPressed:
                    isSubscriptionEnabled
                        ? () {
                          Navigator.of(context).pop();
                          showPaywall(source);
                        }
                        : null,
                child: Text(
                  isSubscriptionEnabled ? "SUBSCRIBE NOW" : "COMING SOON",
                  style: TextStyle(fontSize: 16, color: context.proColor.onColorContainer),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
