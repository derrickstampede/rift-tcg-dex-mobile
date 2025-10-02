import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/main.dart';

import 'package:rift/widgets/auth/google-button.widget.dart';
import 'package:rift/widgets/auth/apple-button.widget.dart';

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $uri');
  }
}

void showSignInModal(BuildContext context, {required String title, Function()? fetchStorage}) {
  Session? session = supabase.auth.currentSession;

  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return session == null
              ? SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 18),
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const Text('Sign in to DBFW TCG Dex', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    if (Platform.isIOS) const AppleButton(),
                    const GoogleButton(),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        text: '',
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: () {
                                _launchUrl('https://${dotenv.env['API']!}/terms-of-service');
                              },
                              child: const Text(
                                'Terms of Service',
                                style: TextStyle(fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: () {
                                _launchUrl('https://${dotenv.env['API']!}/privacy-policy');
                              },
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              )
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 18),
                  const Text('You are already logged in', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close"),
                  ),
                  const SizedBox(height: 24),
                ],
              );
        },
      );
    },
  ).whenComplete(() {
    if (fetchStorage != null) {
      Timer(const Duration(seconds: 2), () {
        fetchStorage();
      });
    }
  });
}

void showDeleteAccountDialog(BuildContext context, {required Function() delete}) {
  Session? session = supabase.auth.currentSession;
  if (session == null) return;

  showDialog(
    context: context, // Provide the context of your widget
    builder: (_) {
      return AlertDialog(
        title: const Text(
          'Are you sure you want to delete your account?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'All of your data will be permanently removed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.of(context).pop();
              showPermanentDeleteAccountDialog(context, delete: delete);
            },
            child: Text("Delete", style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onError)),
          ),
        ],
      );
    },
  );
}

void showPermanentDeleteAccountDialog(BuildContext context, {required Function() delete}) {
  final formKey = GlobalKey<FormState>();
  final TextEditingController inputController = TextEditingController();

  void submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();

    delete();
  }

  showDialog(
    context: context, // Provide the context of your widget
    builder: (_) {
      return AlertDialog(
        title: const Text(
          'Type "permanently delete" to continue',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextFormField(
              controller: inputController,
              maxLength: 32,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Input is required';
                }
                if (val != 'permanently delete') {
                  return 'Text is incorrect';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'permanently delete',
                counterText: '',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              ),
              onSaved: (value) {
                inputController.text = value!;
              },
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              submit();
              Navigator.of(context).pop();
            },
            child: Text(
              "Permanently Delete",
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onError),
            ),
          ),
        ],
      );
    },
  );
}
