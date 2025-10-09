import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:rift/screens/home.screen.dart';
import 'package:rift/screens/cards/stock.screen.dart';
import 'package:rift/screens/cards/card-full.screen.dart';
import 'package:rift/screens/decks/new-deck.screen.dart';
import 'package:rift/screens/decks/select-leader.screen.dart';
import 'package:rift/screens/decks/select-champion.screen.dart';
import 'package:rift/screens/decks/select-battlefield.screen.dart';
import 'package:rift/screens/vaults/vault-form.screen.dart';
import 'package:rift/screens/vaults/vault.screen.dart';
import 'package:rift/screens/vaults/add-cards.screen.dart';
import 'package:rift/screens/subscription/subscription-learn.screen.dart';

import 'package:rift/screens/decks/select-cards.screen.dart';
import 'package:rift/screens/decks/deck.screen.dart';

import 'package:rift/screens/account/update-profile.screen.dart';
import 'package:rift/screens/account/update-username.screen.dart';
import 'package:rift/screens/account/settings.screen.dart';
import 'package:rift/screens/account/user-preferences.screen.dart';
import 'package:rift/screens/account/trial-code.screen.dart';
import 'package:rift/screens/account/consent-manager.screen.dart';

class FluroRoutes {
  static void configureRouter(FluroRouter router) {
    router.define(
      '/home',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const HomeScreen();
        },
      ),
      transitionType: TransitionType.native,
    );

    router.define(
      '/card/full',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          String? image;
          if (params['image'] != null) {
            image = params['image'].first;
          }
          return CardFullScreen(image: image!);
        },
      ),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/card/stock',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          final arg = context!.settings!.arguments as Map<String, dynamic>;
          return StockScreen(card: arg['card'], conversions: arg['conversions'], markets: arg['markets']);
        },
      ),
      transitionType: TransitionType.native,
    );

    router.define(
      '/decks/new',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const NewDeckScreen();
        },
      ),
      transitionType: TransitionType.native,
    );
    router.define(
      '/decks/select-leader',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const SelectLeaderScreen();
        },
      ),
      transitionType: TransitionType.native,
    );
    router.define(
      '/decks/select-champion',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          String color = '';
          if (params['color'] != null) {
            color = Uri.decodeComponent(params['color'].first);
          }
          return SelectChampionScreen(color: color);
        },
      ),
      transitionType: TransitionType.native,
    );
    router.define(
      '/decks/select-battlefield',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const SelectBattlefieldScreen();
        },
      ),
      transitionType: TransitionType.native,
    );
    router.define(
      '/decks/edit',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          String slug = '';
          String? name;
          String? color;
          if (params['slug'] != null) {
            slug = params['slug'].first;
          }
          if (params['name'] != null) {
            name = params['name'].first;
          }
          if (params['color'] != null) {
            color = params['color'].first;
          }

          return DeckScreen(slug: slug, name: name, color: color);
        },
      ),
      transitionType: TransitionType.native,
    );
    router.define(
      '/decks/pick',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          String? slug;
          String? color;
          if (params['slug'] != null) {
            slug = params['slug'].first;
          }
          if (params['color'] != null) {
            color = params['color'].first;
          }
          return SelectCardsScreen(slug: slug, color: color);
        },
      ),
      transitionType: TransitionType.native,
    );

    router.define(
      '/vaults/form',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          String? slug;
          if (params['slug'] != null) {
            slug = params['slug'].first;
          }

          return VaultFormScreen(slug: slug);
        },
      ),
      transitionType: TransitionType.native,
    );
    router.define(
      '/vaults/view',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          String slug = params['slug'].first;
          String name = params['name'].first;
          String color = params['color'].first;

          return VaultScreen(slug: slug, name: name, color: color);
        },
      ),
      transitionType: TransitionType.native,
    );
    router.define(
      '/vaults/add-cards',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          String slug = params['slug'].first;

          return AddCardsScreen(slug: slug);
        },
      ),
      transitionType: TransitionType.native,
    );

    // router.define('/battle/select-deck',
    //     handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    //   return const SelectDeckScreen();
    // }), transitionType: TransitionType.native);

    router.define(
      '/profile/update',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const UpdateProfile();
        },
      ),
      transitionType: TransitionType.native,
    );
    router.define(
      '/profile/update-username',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const UpdateUsername();
        },
      ),
      transitionType: TransitionType.native,
    );

    router.define(
      '/profile/settings',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const SettingsScreen();
        },
      ),
      transitionType: TransitionType.native,
    );
    router.define(
      '/profile/settings/user-preferences',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const UserPreferenceScreen();
        },
      ),
      transitionType: TransitionType.native,
    );
    router.define(
      '/profile/settings/trial-code',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const TrialCodeScreen();
        },
      ),
      transitionType: TransitionType.native,
    );
    router.define(
      '/profile/settings/consent-manager',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const ConsentManagerScreen();
        },
      ),
      transitionType: TransitionType.native,
    );

    router.define(
      '/subscription/learn-more',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const SubscriptionLearn();
        },
      ),
      transitionType: TransitionType.inFromBottom,
    );
  }
}
