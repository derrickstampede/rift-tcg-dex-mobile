import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/profile.helper.dart';
import 'package:rift/helpers/preference.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';

import 'package:rift/models/profile.model.dart';

import 'package:rift/providers/filter.provider.dart';

class CardTranslationDropdown extends ConsumerStatefulWidget {
  const CardTranslationDropdown({super.key, required this.onChange});

  final Function()? onChange;

  @override
  ConsumerState<CardTranslationDropdown> createState() => _CardTranslationDropdownState();
}

class _CardTranslationDropdownState extends ConsumerState<CardTranslationDropdown> {
  Profile? _profile;

  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final profile = await fetchProfile();
    if (profile == null) {
      showSnackbar('Unable to load profile');
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _updateCardTranslation(String? translation) async {
    final response = await updateCardTranslation(translation);
    response.fold((l) {
      if (widget.onChange != null) {
        widget.onChange!();
      }

      _saveCardTranslation(translation);

      logEvent(name: 'card_translation_change', parameters: {'translation': translation});
    }, (r) {
      showSnackbar('Unable to update currency');
    });
  }

  Future<void> _saveCardTranslation(String? translation) async {
    if (_profile == null) return;

    _profile!.cardTranslation = translation;
    await saveProfile(_profile!);
  }

  @override
  Widget build(BuildContext context) {
    final filters$ = ref.read(filtersProvider);
    final cardTranslations = filters$.value!.cardTranslation;

    return !_isLoading
        ? Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Translation'.toUpperCase(),
                  style: TextStyle(
                      fontSize: 14, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    border:
                        Border.all(color: Theme.of(context).colorScheme.outline, style: BorderStyle.solid, width: 1),
                  ),
                  child: DropdownButtonFormField<String>(
                      value: _profile?.cardTranslation ?? 'en',
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: const InputDecoration(border: InputBorder.none),
                      onChanged: (String? value) {
                        _updateCardTranslation(value);
                      },
                      onSaved: (value) {},
                      items: [
                        for (var i = 0; i < cardTranslations.length; i++)
                          DropdownMenuItem<String>(
                            value: cardTranslations[i].value,
                            child: Text(
                              '${cardTranslations[i].label} ',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                      ]),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          )
        : const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
  }
}
