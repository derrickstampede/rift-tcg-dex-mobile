import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:rift/themes/theme-extension.dart';

import 'package:rift/widgets/cards/card-add-remove.widget.dart';
import 'package:rift/widgets/cards/card-foil-wrapper.widget.dart';
import 'package:rift/widgets/cards/card-vault-sheet.widget.dart';
import 'package:rift/widgets/cards/card-image.widget.dart';
import 'package:rift/widgets/cards/card-select.widget.dart';
import 'package:rift/widgets/cards/card-label.widget.dart';
import 'package:rift/widgets/cards/card-variant-stamp.widget.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/deck.model.dart';
import 'package:rift/models/vault.model.dart';
import 'package:rift/models/card-search.model.dart';

import 'package:rift/providers/card-search.provider.dart';
import 'package:rift/providers/deck.provider.dart';
import 'package:rift/providers/vault.provider.dart';
import 'package:rift/providers/ad.provider.dart';

import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/review.helper.dart';
import 'package:rift/helpers/revenuecat.helper.dart';
import 'package:rift/helpers/cards-profiles.helper.dart';

import 'package:rift/globals.dart';

import 'package:rift/main.dart';

import 'package:rift/screens/cards/card.screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class CardGridItem extends ConsumerStatefulWidget {
  const CardGridItem({
    super.key,
    required this.card,
    required this.searchScreen,
    required this.cardSearch,
    this.showLabel = true,
    this.showTiled = true,
    this.showAddRemove = false,
    this.showVaultInfo = false,
    this.deck,
    this.vault,
    this.select,
  });

  final CardListItem card;
  final String searchScreen;
  final CardSearch cardSearch;
  final bool showLabel;
  final bool showTiled;
  final bool showAddRemove;
  final bool showVaultInfo;
  final Deck? deck;
  final Vault? vault;
  final Function({required CardListItem card})? select;

  @override
  ConsumerState<CardGridItem> createState() => _CardGridItemState();
}

class _CardGridItemState extends ConsumerState<CardGridItem> {
  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  Session? session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  int _currentCarouselIndex = 0;
  Timer? _debounceTimer;

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
      if (mounted) {
        setState(() {
          session = data.session;
        });
      }
    });

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final isSubscribed = checkIfSubscribed(customerInfo);
      if (isSubscribed) setState(() => _isPro = isSubscribed);
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  int _countOwned() {
    int count = 0;
    if (widget.card.cardsProfiles == null) return count;

    for (var i = 0; i < widget.card.cardsProfiles!.length; i++) {
      count += widget.card.cardsProfiles![i].count;
    }
    return count;
  }

  Future<void> _viewCard(CardSearchNotifier searchNotifier$) async {
    snackbarKey.currentState?.hideCurrentSnackBar();
    await Navigator.of(context).push(
      TransparentRoute(
        builder:
            (BuildContext context) => CardScreen(
              id: widget.card.id.toString(),
              name: widget.card.name,
              cardId: widget.card.cardId,
              image: widget.card.thumbnail,
              cardSearch: widget.cardSearch,
              searchScreen: widget.searchScreen,
              deck: widget.deck,
              vault: widget.vault,
            ),
      ),
    );

    if (!_isPro) ref.watch(adNotifierProvider.notifier).showInterstitialAd();
    askReview();
  }

  int _variantOwnedCount(String language) {
    int count = 0;
    if (widget.card.cardsProfiles == null) return count;

    final int index =
        widget.card.cardsProfiles != null
            ? widget.card.cardsProfiles!.indexWhere((v) => v.variant!.language == language)
            : -1;
    if (index < 0) return count;

    final cardProfile = widget.card.cardsProfiles![index];
    return cardProfile.count;
  }

  int _findCardsProfilesIndex(String language) {
    final int index =
        widget.card.cardsProfiles != null
            ? widget.card.cardsProfiles!.indexWhere((v) => v.variant!.language == language)
            : -1;

    return index;
  }

  void _updateCardsProfiles() {
    final search$ = ref.read(cardSearchNotifierProvider(screen: widget.searchScreen, cardSearch: widget.cardSearch));
    if (!search$.status.addToDeck || search$.status.addToDeckSelect) {
      print('addToDeckSelect');
      _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
        final searchNotifier$ = ref.read(
          cardSearchNotifierProvider(screen: widget.searchScreen, cardSearch: widget.cardSearch).notifier,
        );
        searchNotifier$.updateCardsProfiles(widget.card.id, widget.card.cardsProfiles!);

        storeCardsProfiles(widget.card.cardsProfiles!);
      });
    } else {
      print('addToDeck');
      _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
        final deckNotifier$ = ref.read(deckBuildNotifierProvider(widget.deck!.slug).notifier);
        deckNotifier$.updateCardsProfiles(widget.card.id, widget.card.cardsProfiles!);

        storeCardsProfiles(widget.card.cardsProfiles!);
      });
    }
  }

  void _addToCollection(String language) {
    final index = _findCardsProfilesIndex(language);
    setState(() {
      if (index < 0) {
        widget.card.cardsProfiles!.add(
          CardsProfiles(
            cardId: widget.card.id,
            variantId: widget.card.variants.firstWhere((v) => v.language == language).id,
            variant: widget.card.variants.firstWhere((v) => v.language == language),
            count: 1,
            vaultId: 0,
          ),
        );
      } else {
        if (_countOwned() < 99) {
          widget.card.cardsProfiles![index].count++;
        }
      }
    });

    _updateCardsProfiles();
  }

  void _removeFromCollection(String language) {
    final index = _findCardsProfilesIndex(language);
    setState(() {
      if (index < 0) {
        widget.card.cardsProfiles!.removeAt(index);
      } else {
        if (_countOwned() > 0) {
          widget.card.cardsProfiles![index].count--;
        }
      }
    });

    _updateCardsProfiles();
  }

  @override
  Widget build(BuildContext context) {
    final search$ = ref.read(cardSearchNotifierProvider(screen: widget.searchScreen, cardSearch: widget.cardSearch));
    final searchNotifier$ = ref.read(
      cardSearchNotifierProvider(screen: widget.searchScreen, cardSearch: widget.cardSearch).notifier,
    );

    Widget cardThumbnail = CardFoilWrapper(print: widget.card.print!, child: CardImage(imageUrl: widget.card.thumbnail));
    if (searchNotifier$.showOwned() && _countOwned() == 0) {
      cardThumbnail = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: cardThumbnail,
      );
    }

    final card = GestureDetector(
      onTap: () => _viewCard(searchNotifier$),
      child: Stack(
        children: [
          cardThumbnail,
          if (search$.status.selectLeader && widget.select != null)
            Positioned(
              bottom: searchNotifier$.showOwned() ? 70 : 46,
              left: 0,
              right: 0,
              child: CardSelect(card: widget.card, select: widget.select!),
            ),
          if (search$.status.addToDeck)
            Positioned(
              bottom: searchNotifier$.showOwned() ? 70 : 46,
              left: 0,
              right: 0,
              child: CardAddRemove(card: widget.card, deck: widget.deck!, screen: widget.searchScreen),
            ),
          if (widget.vault != null) ...[
            Positioned(
              bottom: searchNotifier$.showOwned() ? 70 : 46,
              left: 0,
              right: 0,
              child: CardVaultSheet(
                card: widget.card,
                vault: widget.vault!,
                showVaultInfo: widget.showVaultInfo,
                add:
                    ref.watch(vaultBuildNotifierProvider(widget.vault!.slug).notifier).isCardInVault(widget.card)
                        ? false
                        : true,
                searchScreen: widget.searchScreen,
                cardSearch: widget.cardSearch,
              ),
            ),
          ],
        ],
      ),
    );

    return widget.showTiled
        ? GridTile(
          footer: GestureDetector(
            onTap: () => _viewCard(searchNotifier$),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                color: Colors.black87,
              ),
              child: Column(
                children: [
                  // Center(
                  //   child: Text(
                  //     widget.card.id.toString(),
                  //     style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  //   ),
                  // ),
                  const SizedBox(height: 4),
                  if (!searchNotifier$.showOwned())
                    Center(
                      child: FittedBox(
                        child: RichText(
                          text: TextSpan(
                            text: '',
                            children: [
                              if (widget.card.note != null && widget.card.note!.note != '')
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 2),
                                    child: Icon(Symbols.edit_note, size: 16, color: context.successColor.color),
                                  ),
                                ),
                              TextSpan(
                                text: widget.card.cardId,
                                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (!searchNotifier$.showOwned() && widget.showLabel)
                    CardLabel(card: widget.card, label: searchNotifier$.view(), symbol: searchNotifier$.symbol()),
                  if (searchNotifier$.showOwned())
                    Text(
                      '${_countOwned().toString()} Owned',
                      style: TextStyle(
                        color: _countOwned() >= 4 ? Colors.green[400] : Colors.yellow[300],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (searchNotifier$.showOwned() && widget.card.variants.isNotEmpty && session != null)
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 30.0,
                        viewportFraction: 1,
                        autoPlay: false,
                        enableInfiniteScroll: false,
                        scrollPhysics: const ClampingScrollPhysics(),
                        pageSnapping: true,
                        disableCenter: true,
                        padEnds: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentCarouselIndex = index;
                          });
                        },
                      ),
                      items:
                          widget.card.variants.map((v) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 28,
                                        child: RawMaterialButton(
                                          onPressed: () => _removeFromCollection(v.language!),
                                          elevation: 2.0,
                                          fillColor: Theme.of(context).colorScheme.primary,
                                          padding: const EdgeInsets.all(1.0),
                                          shape: const CircleBorder(),
                                          child: Icon(
                                            Symbols.remove,
                                            size: 16.0,
                                            color: Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CardVariantStamp(language: v.language!),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _variantOwnedCount(v.language!).toString(),
                                              style: const TextStyle(fontSize: 16.0, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 28,
                                        child: RawMaterialButton(
                                          onPressed: () => _addToCollection(v.language!),
                                          elevation: 2.0,
                                          fillColor: Theme.of(context).colorScheme.primary,
                                          padding: const EdgeInsets.all(1.0),
                                          shape: const CircleBorder(),
                                          child: Icon(
                                            Symbols.add,
                                            size: 16.0,
                                            color: Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }).toList(),
                    ),
                  if (searchNotifier$.showOwned() && session != null)
                    Container(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            widget.card.variants.asMap().entries.map((entry) {
                              return Container(
                                width: 4.0,
                                height: 4.0,
                                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _currentCarouselIndex == entry.key ? Colors.white : Colors.white.withOpacity(0.4),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
          ),
          child: card,
        )
        : card;
  }
}
