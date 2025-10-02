import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/models/deck.model.dart';
import 'package:rift/models/card.model.dart';

import 'package:rift/widgets/cards/card-item.widget.dart';

import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/deck.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/routes/config.dart';

class FilterForm {
  String? name;
  int? leaderId;
  String? thumbnail;

  set updateName(String? value) {
    name = value;
  }

  set updateLeaderId(int? value) {
    leaderId = value;
  }

  set updateThumbnail(String? value) {
    thumbnail = value;
  }

  FilterForm({
    @required this.name,
    @required this.leaderId,
    @required this.thumbnail,
  });
}

class DeckCreateForm extends ConsumerStatefulWidget {
  const DeckCreateForm({super.key, required this.goBack});

  final Function(Deck deck) goBack;

  @override
  ConsumerState<DeckCreateForm> createState() => _DeckCreateFormState();
}

class _DeckCreateFormState extends ConsumerState<DeckCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _filterForm = FilterForm(name: null, leaderId: null, thumbnail: null);

  bool _isSaving = false;

  bool _isLeaderValid = true;
  CardListItem? _leaderCard;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    super.initState();

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed) setState(() => _isPro = isSubscribed);
    // });
  }

  void _goToSelectLeader() async {
    CardListItem? leaderCard = await Config.router.navigateTo(context, '/decks/select-leader');
    setState(() {
      _leaderCard = leaderCard;
    });
  }

  Future<void> _submit(WidgetRef ref) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _isSaving) {
      return;
    }
    _isSaving = true;
    _formKey.currentState!.save();

    if (_leaderCard == null) {
      setState(() {
        _isLeaderValid = false;
        _isSaving = false;
      });
      return;
    }

    final deckForm = {"name": _filterForm.name!, "leader_id": _leaderCard!.id, "cards": [], "is_pro": _isPro};
    final response = await storeDeck(deckForm);
    response.fold((l) {
      logEvent(
          name: 'deck_create',
          parameters: {'id': _leaderCard!.id, 'card_id': _leaderCard!.cardId, 'leader': _leaderCard!.name});
      final Deck deck = Deck.fromMap(l['deck']);

      widget.goBack(deck);
    }, (r) {
      // TODO error handling
      showSnackbar('Unable to create deck', subtitle: r['message']);
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Deck Name",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(
                  height: 6,
                ),
                TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Name',
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
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_ ]")),
                    ],
                    maxLength: 32,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _filterForm.updateName = value;
                    }),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "Leader Card",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(
                  height: 6,
                ),
                _leaderCard == null
                    ? GestureDetector(
                        onTap: _goToSelectLeader,
                        child: DottedBorder(
                          color: _isLeaderValid
                              ? Theme.of(context).colorScheme.onSecondaryContainer
                              : Theme.of(context).colorScheme.onErrorContainer,
                          strokeWidth: 1,
                          child: Container(
                            width: double.infinity,
                            color: _isLeaderValid
                                ? Theme.of(context).colorScheme.secondaryContainer
                                : Theme.of(context).colorScheme.errorContainer,
                            height: 100,
                            child: const Center(
                                child: Text(
                              "Select a Leader Card",
                              style: TextStyle(fontSize: 16),
                            )),
                          ),
                        ))
                    : SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 300,
                              child: AspectRatio(
                                  aspectRatio: 420 / 300, child: CardItem(card: _leaderCard!, showTiled: false)),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextButton(onPressed: _goToSelectLeader, child: const Text('Change Leader'))
                          ],
                        ),
                      ),
                if (!_isLeaderValid)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 6),
                    child: Text('Leader is required', style: TextStyle(fontSize: 12, color: Colors.red[500])),
                  ),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () => _submit(ref),
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                        child: Text(
                          'Save',
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        ))),
              ],
            ),
          ),
        )
      ],
    );
  }
}
