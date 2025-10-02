import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/main.dart';

import 'package:rift/models/device.model.dart';

import 'package:rift/constants/main-card-search.constant.dart';

import 'package:rift/providers/card-search.provider.dart';
import 'package:rift/providers/conversions.provider.dart';
import 'package:rift/providers/alerts.provider.dart';

import 'package:rift/helpers/profile.helper.dart';
import 'package:rift/helpers/device.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';

class GoogleButton extends ConsumerStatefulWidget {
  const GoogleButton({super.key});

  @override
  ConsumerState<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends ConsumerState<GoogleButton> {
  void _refreshConversions() {
    ref.read(conversionsNotifierProvider.notifier).search();
  }

  void _closeModal() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> googleSignIn() async {
      try {
        final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']!;
        final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID']!;

        final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId: iosClientId,
          serverClientId: webClientId,
          scopes: ['profile', 'email'],
          signInOption: SignInOption.standard,
        );
        
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw 'Sign in was cancelled by user';
        }

        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (accessToken == null) {
          throw 'No Access Token found.';
        }
        if (idToken == null) {
          throw 'No ID Token found.';
        }

        final authResponse = await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        final userUid = authResponse.user!.id;

        //* STORE PROFILE
        await storeProfile(userUid);

        //* STORE DEVICE
        final Device device = await extractDevice(userUid);
        await storeDevice(device);

        logEvent(name: 'auth_login', parameters: {'method': 'google'});

        ref
            .watch(cardSearchNotifierProvider(screen: MAIN_CARD_SCREEN, cardSearch: MAIN_CARD_SEARCH).notifier)
            .search(refresh: true);
        ref.watch(alertsNotifierProvider.notifier).getLatest();

        showSnackbar('Logged in successfully');
        _refreshConversions();
        _closeModal();
      } catch (e) {
        print('Google Sign In Error: $e');
        showSnackbar('Failed to sign in with Google. Please try again.');
      }
    }

    return SignInButton(
      Buttons.googleDark,
      onPressed: googleSignIn,
    );
  }
}
