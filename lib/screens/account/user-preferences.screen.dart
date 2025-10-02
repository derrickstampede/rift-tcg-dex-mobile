import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rift/widgets/preferences/currency-dropdown.widget.dart';
import 'package:rift/widgets/preferences/card-translation-dropdown.widget.dart';

class UserPreferenceScreen extends ConsumerStatefulWidget {
  const UserPreferenceScreen({super.key});

  @override
  ConsumerState<UserPreferenceScreen> createState() => _UserPreferenceScreenState();
}

class _UserPreferenceScreenState extends ConsumerState<UserPreferenceScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('User Preferences'),
          elevation: 1,
        ),
        body: const Column(
          children: [
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CardTranslationDropdown(
                onChange: null,
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CurrencyDropdown(
                refreshOnChange: true,
                onChange: null,
              ),
            ),
          ],
        ));
  }
}
