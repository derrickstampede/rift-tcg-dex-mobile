import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sign_in_button/sign_in_button.dart';

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

class AppleButton extends ConsumerStatefulWidget {
  const AppleButton({super.key});

  @override
  ConsumerState<AppleButton> createState() => _AppleButtonState();
}

class _AppleButtonState extends ConsumerState<AppleButton> {
  void _refreshConversions() {
    ref.read(conversionsNotifierProvider.notifier).search();
  }
  
  void _closeModal() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> appleSignIn() async {
      try {
        final rawNonce = supabase.auth.generateRawNonce();
        final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: hashedNonce,
        );

        final idToken = credential.identityToken;
        if (idToken == null) {
          throw const AuthException('Could not find ID Token from generated credential.');
        }

        final authResponse = await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: idToken,
          nonce: rawNonce,
        );
        final userUid = authResponse.user!.id;

        //* STORE PROFILE
        await storeProfile(userUid);

        //* STORE DEVICE
        final Device device = await extractDevice(userUid);
        await storeDevice(device);

        logEvent(name: 'auth_login', parameters: {'method': 'apple'});

        ref
            .watch(cardSearchNotifierProvider(screen: MAIN_CARD_SCREEN, cardSearch: MAIN_CARD_SEARCH).notifier)
            .search(refresh: true);
        ref.watch(alertsNotifierProvider.notifier).getLatest();

        showSnackbar('Logged in successfully');
        _refreshConversions();
        _closeModal();
      } catch (e) {
        // TODO: add error handling
        print(e);
      }
    }

    return SignInButton(
      Buttons.apple,
      onPressed: appleSignIn,
    );
  }
}
