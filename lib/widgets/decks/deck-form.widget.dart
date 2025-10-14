import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/models/deck.model.dart';
import 'package:rift/models/card.model.dart';

import 'package:rift/widgets/cards/card-item.widget.dart';

import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/deck.helper.dart';
import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/routes/config.dart';

class FilterForm {
  String? name;
  int? legendId;
  String? thumbnail;

  set updateName(String? value) {
    name = value;
  }

  set updateLegendId(int? value) {
    legendId = value;
  }

  set updateThumbnail(String? value) {
    thumbnail = value;
  }

  FilterForm({@required this.name, @required this.legendId, @required this.thumbnail});
}

class DeckCreateForm extends ConsumerStatefulWidget {
  const DeckCreateForm({super.key, required this.goBack});

  final Function(Deck deck) goBack;

  @override
  ConsumerState<DeckCreateForm> createState() => _DeckCreateFormState();
}

class _DeckCreateFormState extends ConsumerState<DeckCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _filterForm = FilterForm(name: null, legendId: null, thumbnail: null);

  bool _isSaving = false;

  bool _isLegendValid = true;
  CardListItem? _legendCard;
  bool _isChampionValid = true;
  CardListItem? _championCard;
  bool _isBattlefieldValid = true;
  CardListItem? _battlefieldCard;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    super.initState();

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final isSubscribed = checkIfSubscribed(customerInfo);
      if (isSubscribed) setState(() => _isPro = isSubscribed);
    });
  }

  void _goToSelectLegend() async {
    CardListItem? legendCard = await Config.router.navigateTo(context, '/decks/select-leader');
    setState(() {
      _legendCard = legendCard;
    });
  }

  void _goToSelectChampion() async {
    if (_legendCard == null) return;

    final encodedColor = Uri.encodeComponent(_legendCard!.color ?? '');
    final url = '/decks/select-champion?color=$encodedColor';
    CardListItem? championCard = await Config.router.navigateTo(context, url);
    setState(() {
      _championCard = championCard;
    });
  }

  void _goToSelectBattlefield() async {
    CardListItem? battlefieldCard = await Config.router.navigateTo(context, '/decks/select-battlefield');
    setState(() {
      _battlefieldCard = battlefieldCard;
    });
  }

  Future<void> _submit(WidgetRef ref) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _isSaving) {
      return;
    }
    _isSaving = true;
    _formKey.currentState!.save();

    if (_legendCard == null) {
      setState(() {
        _isLegendValid = false;
        _isSaving = false;
      });
      return;
    }
    setState(() => _isLegendValid = true);
    if (_championCard == null) {
      setState(() {
        _isChampionValid = false;
        _isSaving = false;
      });
      return;
    }
    setState(() => _isChampionValid = true);
    if (_battlefieldCard == null) {
      setState(() {
        _isBattlefieldValid = false;
        _isSaving = false;
      });
      return;
    }
    setState(() => _isBattlefieldValid = true);

    final deckForm = {
      "name": _filterForm.name!,
      "legend_id": _legendCard!.id,
      "champion_id": _championCard!.id,
      "battlefield_id": _battlefieldCard!.id,
      "cards": [],
      "is_pro": _isPro,
    };
    final response = await storeDeck(deckForm);
    response.fold(
      (l) {
        logEvent(
          name: 'deck_create',
          parameters: {
            'id': _legendCard!.id,
            'card_id': _legendCard!.cardId,
            'legend': _legendCard!.name,
            'champion': _championCard!.name,
          },
        );
        final Deck deck = Deck.fromMap(l['deck']);

        widget.goBack(deck);
      },
      (r) {
        // TODO error handling
        showSnackbar('Unable to create deck', subtitle: r['message']);
        _isSaving = false;
      },
    );
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
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 6),
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
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_ ]"))],
                  maxLength: 32,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _filterForm.updateName = value;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  "Legend",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 6),
                if (_legendCard == null)
                  GestureDetector(
                    onTap: _goToSelectLegend,
                    child: DottedBorder(
                      color:
                          _isLegendValid
                              ? Theme.of(context).colorScheme.onSecondaryContainer
                              : Theme.of(context).colorScheme.onErrorContainer,
                      strokeWidth: 1,
                      child: Container(
                        width: double.infinity,
                        color:
                            _isLegendValid
                                ? Theme.of(context).colorScheme.secondaryContainer
                                : Theme.of(context).colorScheme.errorContainer,
                        height: 100,
                        child: const Center(child: Text("Tap to Select Your Legend", style: TextStyle(fontSize: 16))),
                      ),
                    ),
                  ),
                if (_legendCard != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 300,
                              child: AspectRatio(
                                aspectRatio: 420 / 300,
                                child: CardItem(card: _legendCard!, showTiled: false),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(onPressed: _goToSelectLegend, child: const Text('Change Legend')),
                          ],
                        ),
                      ),
                      if (!_isLegendValid)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 6),
                          child: Text('Legend is required', style: TextStyle(fontSize: 12, color: Colors.red[500])),
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            "Champion",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (_championCard == null)
                            GestureDetector(
                              onTap: _goToSelectChampion,
                              child: DottedBorder(
                                color:
                                    _isChampionValid
                                        ? Theme.of(context).colorScheme.onSecondaryContainer
                                        : Theme.of(context).colorScheme.onErrorContainer,
                                strokeWidth: 1,
                                child: Container(
                                  width: double.infinity,
                                  color:
                                      _isChampionValid
                                          ? Theme.of(context).colorScheme.secondaryContainer
                                          : Theme.of(context).colorScheme.errorContainer,
                                  height: 100,
                                  child: const Center(
                                    child: Text("Tap to Select Your Champion", style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ),
                            ),
                          if (_championCard != null)
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 300,
                                    child: AspectRatio(
                                      aspectRatio: 420 / 300,
                                      child: CardItem(card: _championCard!, showTiled: false),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(onPressed: _goToSelectChampion, child: const Text('Change Champion')),
                                ],
                              ),
                            ),
                          if (!_isChampionValid)
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0, top: 6),
                              child: Text(
                                'Champion is required',
                                style: TextStyle(fontSize: 12, color: Colors.red[500]),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Text(
                  "Battlefield",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 6),
                if (_battlefieldCard == null)
                  GestureDetector(
                    onTap: _goToSelectBattlefield,
                    child: DottedBorder(
                      color:
                          _isBattlefieldValid
                              ? Theme.of(context).colorScheme.onSecondaryContainer
                              : Theme.of(context).colorScheme.onErrorContainer,
                      strokeWidth: 1,
                      child: Container(
                        width: double.infinity,
                        color:
                            _isBattlefieldValid
                                ? Theme.of(context).colorScheme.secondaryContainer
                                : Theme.of(context).colorScheme.errorContainer,
                        height: 100,
                        child: const Center(
                          child: Text("Tap to Select Your Battlefield", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ),
                if (_battlefieldCard != null)
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          child: Transform.rotate(
                            angle: pi / 2,
                            child: AspectRatio(
                              aspectRatio: 420 / 300,
                              child: CardItem(card: _battlefieldCard!, showTiled: false),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(onPressed: _goToSelectBattlefield, child: const Text('Change Battlefield')),
                      ],
                    ),
                  ),
                if (!_isBattlefieldValid)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 6),
                    child: Text('Battlefield is required', style: TextStyle(fontSize: 12, color: Colors.red[500])),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submit(ref),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text('Save', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
