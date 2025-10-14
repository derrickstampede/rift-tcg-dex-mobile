import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/providers/deck.provider.dart';
import 'package:rift/providers/decks.provider.dart';

import 'package:rift/helpers/deck.helper.dart';
import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/models/deck.model.dart';

import 'package:rift/screens/decks/deck-cards.screen.dart';
import 'package:rift/screens/decks/deck-stats.screen.dart';

import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';

import 'package:rift/widgets/decks/deck-drawer.widget.dart';

class DeckScreen extends ConsumerStatefulWidget {
  const DeckScreen({super.key, required this.slug, this.name, this.color});

  final String slug;
  final String? name;
  final String? color;

  @override
  ConsumerState<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends ConsumerState<DeckScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final int _pageIndex = 0;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isEditingName = false;

  String _exportString = '';

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.name!;
    logEvent(name: 'deck_view');

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final isSubscribed = checkIfSubscribed(customerInfo);
      if (isSubscribed) setState(() => _isPro = isSubscribed);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleNameForm() {
    setState(() {
      _isEditingName = !_isEditingName;
    });
  }

  void _updateName(WidgetRef ref) {
    _formKey.currentState!.save();
    if (_nameController.text == '') {
      return;
    }

    ref.read(deckBuildNotifierProvider(widget.slug).notifier).updateName(_nameController.text);
    ref.read(deckListNotifierProvider.notifier).patch(widget.slug, _nameController.text);
    ref.read(deckListNotifierProvider.notifier).updateUpdatedAt(widget.slug);

    _toggleNameForm();
  }

  Future<void> _fetchExport(Deck deck) async {
    showSnackbar('Generating export code');

    final response = await exportDeck(deck.slug);
    response.fold((l) {
      hideSnackbar();
      setState(() {
        _exportString = l['deckExport'];
      });
      _showExportDialog();
    }, (r) {
      showSnackbar('Unable to generate code at this time');
    });
  }

  Future<void> _showExportDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(
                  height: 4,
                ),
                const Text('Copy the code below then paste to a simulator'),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  initialValue: _exportString,
                  readOnly: true,
                  minLines: 8,
                  maxLines: 20,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Copy Text',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () {
                _copyToClipboard();
              },
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _exportString));
    showSnackbar('Copied to Clipboard');
  }
  
  Future<void> _copyDeck(Deck deck) async {
    showSnackbar('Copying deck');

    final response = await copyDeck(deck.slug, _isPro);
    response.fold((l) {
      hideSnackbar();

      final Deck deck = Deck.fromMap(l['deck']);
      ref.read(deckListNotifierProvider.notifier).add(deck);
      showSnackbar('Deck copied successfully');
    }, (r) {
      showSnackbar(r['message']);
    });

  }
  
  Future<void> _showDeleteDialog(Deck deck, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You are about to delete this deck.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                _deleteDeck(deck, ref);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteDeck(Deck deck, WidgetRef ref) {
    ref.read(deckListNotifierProvider.notifier).remove(deck.slug);
    logEvent(name: 'deck_delete', parameters: {'method': 'popmenu button'});
    showSnackbar('${deck.name} deleted');

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final deck$ = ref.watch(deckBuildNotifierProvider(widget.slug));

    Color backgroundColor = Theme.of(context).colorScheme.primary;
    Color foregroundColor = Theme.of(context).colorScheme.onPrimary;
    if (widget.color != null) {
      final colorSplits = widget.color!.split('/');
      backgroundColor = getColor(colorSplits[0]);
      foregroundColor = backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }
    if (deck$ == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_nameController.text),
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          elevation: 1,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultTabController(
      initialIndex: _pageIndex,
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: !_isEditingName
              ? GestureDetector(onTap: _toggleNameForm, child: Text(_nameController.text))
              : Form(
                  key: _formKey,
                  child: TextFormField(
                      autofocus: true,
                      controller: _nameController,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_ ]")),
                      ],
                      style: TextStyle(color: foregroundColor),
                      decoration: InputDecoration(
                        hintText: 'Name',
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: foregroundColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: foregroundColor, width: 1),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      ),
                      maxLength: 32,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                      onSaved: (value) {}),
                ),
          elevation: 1,
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          actions: [
            if (_isEditingName)
              TextButton(
                onPressed: () {
                  _updateName(ref);
                },
                child: Text("Save", style: TextStyle(color: foregroundColor)),
              ),
            if (!_isEditingName)
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(
                      Symbols.attach_money,
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState!.openEndDrawer();
                    },
                    tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  );
                },
              ),
            if (!_isEditingName)
              PopupMenuButton(itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Symbols.edit,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Text(
                          'Edit Name',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Symbols.content_copy,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Text(
                          'Copy',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Symbols.share_windows,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Text(
                          'Export',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 3,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Symbols.delete,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Text(
                          'Delete',
                        ),
                      ],
                    ),
                  ),
                ];
              }, onSelected: (value) {
                if (value == 0) {
                  _toggleNameForm();
                }
                if (value == 1) {
                  _copyDeck(deck$);
                }
                if (value == 2) {
                  _fetchExport(deck$);
                }
                if (value == 3) {
                  _showDeleteDialog(deck$, ref);
                }
              }),
          ],
          bottom: TabBar(
            indicatorColor: backgroundColor,
            labelStyle: TextStyle(color: foregroundColor),
            unselectedLabelStyle: TextStyle(color: foregroundColor),
            tabs: const <Widget>[
              Tab(
                text: 'Card List',
              ),
              Tab(
                text: 'Notes & Stats',
              ),
            ],
          ),
        ),
        endDrawer: DeckDrawer(slug: widget.slug),
        body: TabBarView(
          children: <Widget>[
            DeckCardsScreen(
              slug: widget.slug,
              deck: deck$,
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
            ),
            DeckStatsScreen(
              deck: deck$,
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
            )
          ],
        ),
      ),
    );
  }
}
