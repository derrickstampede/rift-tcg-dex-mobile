import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/helpers/deck.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/models/deck.model.dart';

class DeckImport extends StatefulWidget {
  const DeckImport({super.key, required this.goBack});

  final Function(Deck deck) goBack;

  @override
  State<DeckImport> createState() => _DeckImportState();
}

class _DeckImportState extends State<DeckImport> {
  final _formKey = GlobalKey<FormState>();
  String _importString = '';

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    super.initState();

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final isSubscribed = checkIfSubscribed(customerInfo);
      if (isSubscribed) setState(() => _isPro = isSubscribed);
    });
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    final response = await importDeck({'cards': _importString, "is_pro": _isPro});
    response.fold((l) {
      logEvent(name: 'deck_import_optopdecks', parameters: {
        'id': l['deck']['leader']['id'],
        'card_id': l['deck']['leader']['card_id'],
        'leader': l['deck']['leader']['name']
      });
      final Deck deck = Deck.fromMap(l['deck']);
      widget.goBack(deck);
    }, (r) {
      // TODO error handling
      showSnackbar('Unable to create deck', subtitle: r['message']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Import from onepiecetopdecks.com",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(
                  height: 6,
                ),
                TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Import Code',
                      counterText: "",
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
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'''[a-zA-Z0-9'", _\[\]-]*''')),
                    ],
                    maxLength: 1000,
                    maxLines: 2,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Code is required';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _importString = value!;
                    }),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                        child: Text(
                          'Import',
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        ))),
                const SizedBox(
                  height: 6,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
