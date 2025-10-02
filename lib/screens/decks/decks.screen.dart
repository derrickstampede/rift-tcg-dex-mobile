import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/main.dart';

import 'package:rift/routes/config.dart';

import 'package:rift/themes/theme-extension.dart';

import 'package:rift/models/deck.model.dart';
import 'package:rift/models/filter.model.dart';

import 'package:rift/widgets/cards/card-image.widget.dart';
import 'package:rift/widgets/auth/signin-button.widget.dart';
import 'package:rift/widgets/misc/color-hexagon.widget.dart';
// import 'package:rift/widgets/ads/ad-banner.widget.dart';

import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/profile.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/review.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/providers/decks.provider.dart';
// import 'package:rift/providers/ad.provider.dart';

class DecksScreen extends ConsumerStatefulWidget {
  const DecksScreen({super.key});

  @override
  ConsumerState<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends ConsumerState<DecksScreen> {
  Session? session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  final _deckLimit = int.parse(dotenv.env['ANONYMOUS_DECK_LIMIT']!);
  final _subDeckLimit = int.parse(dotenv.env['SUBSCRIBED_DECK_LIMIT']!);
  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  final List<Filter> _sortingOptions = [
    Filter(label: 'Name', value: 'name'),
    Filter(label: 'Leader', value: 'leader'),
    Filter(label: 'Color', value: 'color'),
    Filter(label: 'Created', value: 'date_created'),
    Filter(label: 'Updated', value: 'date_updated'),
  ];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        session = data.session;
        if (session != null) {
          _fetchDecks(force: true);
        }
      });
    });

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed && mounted) setState(() => _isPro = isSubscribed);
    // });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchDecks({required bool force}) async {
    await ref.watch(deckListNotifierProvider.notifier).search(force: force);
  }

  void _validateDeckCount(List<Deck> decks) async {
    int limit = _deckLimit;
    if (_isPro) {
      limit = _subDeckLimit;
    }

    if (decks.length >= limit) {
      // showSubscribeDialog(context: context, source: 'deck-limit');
      return;
    }
    _goToNewDeck();
  }

  void _goToNewDeck() async {
    Config.router.navigateTo(context, '/decks/new');
  }

  void _goToDeck(int index, DeckList decklist) async {
    final deck = decklist.decks[index];
    final encodedColor = Uri.encodeComponent(deck.leader.color!);

    await Config.router.navigateTo(context, '/decks/edit?slug=${deck.slug}&name=${deck.name}&color=$encodedColor');

    // if (!_isPro) ref.watch(adNotifierProvider.notifier).showInterstitialAd();
    askReview();
  }

  void _removeDeck(Deck deck, WidgetRef ref) async {
    await ref.read(deckListNotifierProvider.notifier).remove(deck.slug);

    logEvent(name: 'deck_delete', parameters: {'method': 'swipe'});
    showSnackbar('${deck.name} deleted');
  }

  Future<bool?> _showDeleteDialog(Deck deck) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text('You are about to delete deck ${deck.name}.')]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deckList$ = ref.watch(deckListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck List'),
        elevation: 1,
        // bottom:
        //     session != null && !deckList$.isLoading && !_isPro
        //         ? const PreferredSize(preferredSize: Size.fromHeight(50.0), child: AdBanner())
        //         : null,
      ),
      body:
          session != null
              ? !deckList$.isLoading
                  ? deckList$.decks.isNotEmpty
                      ? RefreshIndicator(
                        onRefresh: () => _fetchDecks(force: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: deckList$.decks.length,
                          itemBuilder: (context, index) {
                            if (!_isPro && _deckLimit <= index) {
                              return ListTile(
                                leading: const SizedBox(width: 42, child: Icon(Symbols.lock)),
                                title: Text(
                                  "Locked Deck",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: DefaultTextStyle.of(context).style.color,
                                  ),
                                ),
                                subtitle: const Text('Subscribe to unlock'),
                                // onTap: () => showSubscribeDialog(context: context, source: 'deck-locked'),
                              );
                            }

                            final visibility = deckList$.decks[index].isPublic ? 'Public' : 'Private';
                            final visibilityIcon = deckList$.decks[index].isPublic ? Symbols.public : Symbols.lock;

                            return Dismissible(
                              key: UniqueKey(),
                              background: Container(color: Theme.of(context).colorScheme.error),
                              onDismissed: (direction) {
                                _removeDeck(deckList$.decks[index], ref);
                              },
                              confirmDismiss: (direction) async {
                                return _showDeleteDialog(deckList$.decks[index]);
                              },
                              child: ListTile(
                                leading: SizedBox(
                                  width: 42,
                                  child: CardImage(imageUrl: deckList$.decks[index].leader.thumbnail),
                                ),
                                title: RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    text: '',
                                    children: [
                                      if (deckList$.decks[index].note != null &&
                                          deckList$.decks[index].note!.note != '')
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 2),
                                            child: Icon(Symbols.edit_note, size: 18, color: context.successColor.color),
                                          ),
                                        ),
                                      TextSpan(
                                        text: deckList$.decks[index].name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: DefaultTextStyle.of(context).style.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                subtitle: RichText(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    text: '',
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      TextSpan(text: '${deckList$.decks[index].cardCount} cards \u2981 '),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(visibilityIcon, size: 16),
                                      ),
                                      TextSpan(text: ' $visibility'),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _goToDeck(index, deckList$);
                                },
                                trailing: ColorHexagon(size: 24, colors: deckList$.decks[index].leader.color!),
                              ),
                            );
                          },
                        ),
                      )
                      : const Center(child: Text('No decks yet'))
                  : const Center(child: CircularProgressIndicator())
              : const SigninButton(),
      persistentFooterButtons:
          session != null
              ? [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 4,
                      child: Row(
                        children: [
                          const Icon(Symbols.sort, size: 22),
                          const SizedBox(width: 4),
                          Ink(
                            width: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: deckList$.sortBy,
                              isExpanded: true,
                              iconSize: 0,
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                constraints: BoxConstraints(maxHeight: 40),
                                focusColor: Colors.transparent,
                              ),
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              onChanged: (String? value) {
                                ref.read(deckListNotifierProvider.notifier).updateSort(sortBy: value);
                              },
                              items: [
                                for (var i = 0; i < _sortingOptions.length; i++)
                                  DropdownMenuItem<String>(
                                    value: _sortingOptions[i].value,
                                    child: Text(
                                      _sortingOptions[i].label,
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 1,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 2),
                          SizedBox(
                            height: 32,
                            child: IconButton(
                              onPressed: () {
                                ref
                                    .read(deckListNotifierProvider.notifier)
                                    .updateSort(isSortAscending: !deckList$.isSortAscending);
                              },
                              iconSize: 20.0,
                              padding: const EdgeInsets.only(bottom: 1, left: 6, right: 6),
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              icon:
                                  deckList$.isSortAscending
                                      ? const Icon(Symbols.arrow_upward)
                                      : const Icon(Symbols.arrow_downward),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
              : null,
      floatingActionButton:
          session != null
              ? FloatingActionButton(
                onPressed: () => _validateDeckCount(deckList$.decks),
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Symbols.add, color: Theme.of(context).colorScheme.onPrimary),
              )
              : null,
    );
  }
}
