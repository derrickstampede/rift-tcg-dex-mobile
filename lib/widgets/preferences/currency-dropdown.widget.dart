import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/helpers/preference.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/util.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';
import 'package:rift/helpers/profile.helper.dart';

import 'package:rift/models/preference.model.dart';
import 'package:rift/models/profile.model.dart';

import 'package:rift/constants/main-card-search.constant.dart';

import 'package:rift/providers/card-search.provider.dart';
import 'package:rift/providers/conversions.provider.dart';

import 'package:rift/widgets/misc/pro-badge.widget.dart';

class CurrencyDropdown extends ConsumerStatefulWidget {
  const CurrencyDropdown({super.key, required this.refreshOnChange, required this.onChange});

  final bool refreshOnChange;
  final Function(int? selectedCountry)? onChange;

  @override
  ConsumerState<CurrencyDropdown> createState() => _CurrencyDropdownState();
}

class _CurrencyDropdownState extends ConsumerState<CurrencyDropdown> {
  Profile? _profile;

  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  List<PreferenceCountryOption> _countries = [];

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

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

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed) setState(() => _isPro = isSubscribed);
    // });
  }

  Future<void> _init() async {
    final profile = await fetchProfile();
    if (profile == null) {
      showSnackbar('Unable to load profile');
      setState(() => _isLoading = false);
      return;
    }

    _findProfile(profile.userUid);
  }

  void _findProfile(String userUid) async {
    final response = await findProfile(userUid);
    response.fold((l) {
      setState(() {
        _profile = l['profile'];
        _fetchOptions();
      });
    }, (r) {
      // TODO error handling
      print(r);
    });
  }

  Future<void> _fetchOptions() async {
    final response = await getPreferenceOptions();
    response.fold((l) {
      setState(() {
        _countries = l['countries'];
        _isLoading = false;
      });
    }, (r) {
      setState(() {
        _isLoading = false;
      });
      // TODO error handling
    });
  }

  Future<void> _updateCountry(String? countryId) async {
    final response = await updatePreferenceCountry(countryId);
    response.fold((l) {
      if (widget.refreshOnChange) { // refresh main card search
        ref
            .watch(cardSearchNotifierProvider(screen: MAIN_CARD_SCREEN, cardSearch: MAIN_CARD_SEARCH).notifier)
            .search(refresh: true);
      }
      if (widget.onChange != null) {
        widget.onChange!(countryId == null ? 0 : int.parse(countryId));
      }
  
      ref.read(conversionsNotifierProvider.notifier).search();

      String? logId = countryId;
      logId ??= '-';
      if (_isPro) logEvent(name: 'currency_change', parameters: {'id': logId});
    }, (r) {
      showSnackbar('Unable to update currency');
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(text: '', children: [
                    TextSpan(
                      text: 'Currency'.toUpperCase(),
                      style: TextStyle(
                          fontSize: 14, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: ProBadge(showUnlock: false),
                        )),
                  ]),
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
                      value: _profile!.countryId?.toString(),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: const InputDecoration(border: InputBorder.none),
                      onChanged: (String? value) {
                        _updateCountry(value);
                      },
                      onSaved: (value) {},
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text("-"),
                        ),
                        for (var i = 0; i < _countries.length; i++)
                          DropdownMenuItem<String>(
                            value: _countries[i].id.toString(),
                            enabled: _isPro,
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(text: '', children: [
                                TextSpan(
                                  text: '${_countries[i].name} (${_countries[i].currency})',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: _isPro
                                          ? Theme.of(context).colorScheme.onSurface
                                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                      fontWeight: FontWeight.w600),
                                ),
                                if (!_isPro)
                                  const WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: ProBadge(),
                                      )),
                              ]),
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
