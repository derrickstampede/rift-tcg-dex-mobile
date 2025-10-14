import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/helpers/trial.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/revenuecat.helper.dart';

class TrialCodeScreen extends StatefulWidget {
  const TrialCodeScreen({super.key});

  @override
  State<TrialCodeScreen> createState() => _TrialCodeScreenState();
}

class _TrialCodeScreenState extends State<TrialCodeScreen> {
  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  final _formKey = GlobalKey<FormState>();
  String _code = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final isSubscribed = checkIfSubscribed(customerInfo);
      if (isSubscribed && mounted) setState(() => _isPro = isSubscribed);
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _isSaving) {
      return;
    }

    _isSaving = true;
    _formKey.currentState!.save();

    final response = await validateTrialCode(_code);
    response.fold(
      (l) async {
        int trialCodeId = l['trial_code_id'];
        String trialOffering = l['trial_offering'] ?? 'promo';
        String trialEntitlement = l['trial_entitlement'] ?? 'pro';
        bool trialIsAppleCode = l['trial_is_apple_code'] ?? false;

        if (Platform.isIOS && trialIsAppleCode) {
          await _submitAppleCode(trialCodeId);
        } else {
          await _showPaywall(trialCodeId, trialOffering, trialEntitlement);
        }
        _isSaving = false;
      },
      (r) {
        showSnackbar(r['message']);
        _isSaving = false;
      },
    );
  }

  Future<void> _submitAppleCode(int trialCodeId) async {
    try {
      final bool success = await redeemAppleSubscriptionOfferCode();

      if (success) {
        setState(() => _isPro = true);
        storeTrial(trialCodeId);
        showSnackbar('Subscription offer code applied successfully!');
        _popAtStart();
      } else {
        showSnackbar('Subscription offer code could not be applied');
      }
    } catch (e) {
      showSnackbar('Error applying subscription offer code: ${e.toString()}');
    }
  }

  Future<void> _showPaywall(int trialCodeId, String offering, String entitlement) async {
    bool hasPurchased = await showTrialPaywall(trialCodeId, offering, entitlement);
    if (hasPurchased) {
      _popAtStart();
    }
  }

  void _popAtStart() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    if (_isPro) {
      return Scaffold(
        appBar: AppBar(title: const Text('Apply Promo'), elevation: 1),
        body: const Center(child: Text("You're already a PRO user")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Promo'),
        elevation: 1,
        actions: [TextButton(onPressed: _submit, child: const Text("Apply"))],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '',
                      children: [
                        TextSpan(
                          text: 'Promo Code'.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Code',
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
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]"))],
                    maxLength: 14,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Code is required';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) {
                        setState(() => _code = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
