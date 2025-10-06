import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

import 'package:rift/main.dart';

import 'package:rift/themes/theme-extension.dart';

import 'package:rift/helpers/card.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
// import 'package:rift/helpers/revenuecat.helper.dart';
import 'package:rift/helpers/auth.helper.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/card-search.model.dart';
import 'package:rift/models/note.model.dart';
import 'package:rift/models/deck.model.dart';
import 'package:rift/models/vault.model.dart';
import 'package:rift/models/card-translation.model.dart';

import 'package:rift/providers/card-search.provider.dart';

import 'package:rift/widgets/misc/domain-icon.widget.dart';
import 'package:rift/widgets/cards/card-image.widget.dart';
import 'package:rift/widgets/cards/flippable-card.widget.dart';
import 'package:rift/widgets/cards/card-in-collection.widget.dart';
import 'package:rift/widgets/cards/card-price.widget.dart';
import 'package:rift/widgets/cards/card-rarity-badge.widget.dart';
import 'package:rift/widgets/cards/card-variant-stamp.widget.dart';
import 'package:rift/widgets/card-options/card-option-collection.widget.dart';
import 'package:rift/widgets/card-options/card-option-deck.widget.dart';
import 'package:rift/widgets/card-options/card-option-vault.widget.dart';
import 'package:rift/widgets/cards/card-where.widget.dart';
import 'package:rift/widgets/misc/titlecase.widget.dart';
import 'package:rift/widgets/notes/note-box.widget.dart';
// import 'package:rift/widgets/ads/ad-banner.widget.dart';
// import 'package:rift/widgets/ads/ad-mdrect-banner.widget.dart';
import 'package:rift/widgets/preferences/currency-dropdown.widget.dart';
import 'package:rift/widgets/misc/pro-badge.widget.dart';
import 'package:rift/widgets/misc/subheader.widget.dart';
import 'package:rift/widgets/preferences/card-translation-dropdown.widget.dart';

import 'package:rift/routes/config.dart';

class CardScreen extends ConsumerStatefulWidget {
  const CardScreen({
    super.key,
    this.id,
    this.name,
    this.cardId,
    this.image,
    this.cardSearch,
    this.searchScreen,
    this.showOptions = true,
    this.deck,
    this.vault,
  });

  final String? id;
  final String? name;
  final String? cardId;
  final String? image;
  final CardSearch? cardSearch;
  final String? searchScreen;
  final bool showOptions;
  final Deck? deck;
  final Vault? vault;

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen> {
  Session? session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  bool _isLoading = true;
  bool _hideImage = false;
  late String _id;
  late String _cardId;
  late String _previewImage;
  late CardItemView _card;
  late List<CardMarket> _markets;

  Note? _note;
  CardConversions _conversions = CardConversions(adjustedPrices: [], symbol: null);
  CardTranslation? _translation;
  String? _translationError;

  bool _isLoggedIn = false;
  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  final _key = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    super.initState();
    _id = widget.id!;
    _cardId = widget.cardId!;
    _previewImage = widget.image!;

    _isLoading = true;
    _findCard(_id);

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        session = data.session;
        if (session != null) {
          setState(() => _isLoggedIn = true);
        } else {
          setState(() => _isLoggedIn = false);
        }
      });
    });

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed) setState(() => _isPro = isSubscribed);
    // });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  void _findCard(String id) async {
    setState(() => _isLoading = true);

    final response = await findCard(id: id);
    response.fold(
      (l) {
        setState(() {
          _card = l['card'];
          _markets = l['markets'];
          _note = l['note'];
          _conversions = l['conversions'];
          _translation = l['translation'];
          _translationError = l['translationError'];

          _isLoading = false;
          _hideImage = false;
          _previewImage = _card.variants[0].thumbnail!;

          _cardId = _card.cardId;

          logEvent(name: 'card_view', parameters: {'id': _card.id, 'card_id': _card.cardId, 'name': _card.name});
        });
      },
      (r) {
        print(r);
        // TODO error handling
      },
    );
  }

  void _updateCardProfiles(List<CardsProfiles> cardProfiles) {
    setState(() {
      _card.cardsProfiles = cardProfiles;
    });
  }

  Future<void> _showCurrencyConverterDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(height: 32, width: double.infinity),
                CurrencyDropdown(
                  refreshOnChange: false,
                  onChange: (int? selectedCountry) {
                    _findCard(_id);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCardTranslationDialog() async {
    if (!_isLoggedIn) {
      showSignInModal(context, title: 'Change Card Language');
      return;
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(height: 32, width: double.infinity),
                CardTranslationDropdown(
                  onChange: () {
                    _findCard(_id);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CardSearchNotifier? searchNotifier$;
    int? nextCard;
    int? prevCard;

    if (widget.searchScreen != null && widget.cardSearch != null) {
      searchNotifier$ = ref.watch(
        cardSearchNotifierProvider(screen: widget.searchScreen!, cardSearch: widget.cardSearch!).notifier,
      );

      if (searchNotifier$ != null) {
        prevCard = searchNotifier$.prevCard(int.parse(_id));
        nextCard = searchNotifier$.nextCard(int.parse(_id));
      }
    }

    void goToPrev(String event) {
      if (prevCard != null) {
        _id = prevCard.toString();
        setState(() {
          _hideImage = true;
        });
        _findCard(_id);

        logEvent(name: event);
      }
    }

    void goToNext(String event) {
      if (nextCard != null) {
        _id = nextCard.toString();
        setState(() {
          _hideImage = true;
        });
        _findCard(_id);

        logEvent(name: event);
      }
    }

    //* ScaffoldMessenger is used to prevent snackbar error
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: Text(!_hideImage ? _cardId : ''),
          actions: [IconButton(onPressed: () => _showCardTranslationDialog(), icon: const Icon(Symbols.translate))],
        ),
        backgroundColor: Colors.transparent,
        body: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ListView(
            children: [
              _isLoading
                  ? Column(
                    children: [
                      if (!_hideImage)
                        Container(
                          height: 480,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: CardImage(imageUrl: _previewImage),
                        ),
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                    ],
                  )
                  : Column(
                    children: [
                      if (!_hideImage)
                        CarouselSlider(
                          options: CarouselOptions(height: 480.0, enableInfiniteScroll: false),
                          items:
                              _card.variants.map((v) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Stack(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width,
                                            height: 480.0,
                                            child: FlippableCard(
                                              frontImageUrl: v.image!,
                                              backImageUrl: v.backImage,
                                              width: MediaQuery.of(context).size.width,
                                              height: 480.0,
                                              onTapWithSide: (isShowingFront, currentImageUrl) {
                                                final fullImageUrl =
                                                    isShowingFront ? v.image! : (v.backImage ?? v.image!);
                                                final encodedImage = Uri.encodeComponent(fullImageUrl);
                                                final route = '/card/full?image=$encodedImage';
                                                Config.router.navigateTo(context, route);
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 100,
                                            child: Container(
                                              color: Colors.black87,
                                              width: 40,
                                              height: 40,
                                              padding: const EdgeInsets.all(5),
                                              child: CardVariantStamp(language: v.language!),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 60,
                                            child: Container(
                                              color: Colors.black87,
                                              padding: const EdgeInsets.all(8),
                                              child: const Icon(Symbols.zoom_out_map, color: Colors.white),
                                            ),
                                          ),
                                          if (v.backThumbnail != null)
                                            Positioned(
                                              left: 0,
                                              top: 0,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.black87,
                                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Symbols.flip, color: Colors.white, size: 20),
                                                    const SizedBox(width: 4),
                                                    const Text(
                                                      'Double tap to flip',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
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
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      //   child: Text(
                      //     _card.id.toString(),
                      //     textAlign: TextAlign.center,
                      //   ),
                      // ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onHorizontalDragEnd: (DragEndDetails details) {
                            if (details.primaryVelocity == null) return;
                            if (details.primaryVelocity! > 0) {
                              goToPrev('card_prev_swipe');
                            } else if (details.primaryVelocity! < 0) {
                              goToNext('card_next_swipe');
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                if (_translationError != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: context.warningColor.colorContainer,
                                      ),
                                      width: double.infinity,
                                      child: Text(
                                        _translationError ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          height: 1,
                                          color: context.warningColor.onColorContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: SizedBox(
                                        width: 36,
                                        child:
                                            searchNotifier$ != null && prevCard != null
                                                ? RawMaterialButton(
                                                  onPressed: () => goToPrev('card_prev'),
                                                  elevation: 2.0,
                                                  shape: const CircleBorder(),
                                                  child: const Icon(Symbols.chevron_backward, size: 32.0),
                                                )
                                                : null,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          if (_card.isParallel)
                                            const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(
                                                "(Parallel)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 14, height: 1, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Text(
                                              _translation?.name ?? _card.name.toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 6),
                                                child: CardRarityBadge(rarity: _card.rarity!),
                                              ),
                                              Text(
                                                _card.cardId.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  height: 1,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 6),
                                                child: DomainIcon(domain: _card.domain!),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: SizedBox(
                                        width: 36,
                                        child:
                                            searchNotifier$ != null && nextCard != null
                                                ? RawMaterialButton(
                                                  onPressed: () => goToNext('card_next'),
                                                  elevation: 2.0,
                                                  shape: const CircleBorder(),
                                                  child: const Icon(Symbols.chevron_forward, size: 32.0),
                                                )
                                                : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // if (!_isPro) const AdMdRectBanner(),
                                if (_markets.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            for (var market in _markets)
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        width: 86,
                                                        height: 42,
                                                        child: FancyShimmerImage(
                                                          imageUrl: market.logo,
                                                          boxFit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      market.isPro && !_isPro
                                                          ? GestureDetector(
                                                            onTap: () {
                                                              if (!_isLoggedIn) return;
                                                              // showSubscribeDialog(
                                                              //   context: context,
                                                              //   source: 'cardmarket',
                                                              // );
                                                            },
                                                            child: const ProBadge(),
                                                          )
                                                          : Column(
                                                            children: [
                                                              if (_isPro &&
                                                                  _conversions.adjustedPrices
                                                                      .where((c) => c.market == market.slug)
                                                                      .isNotEmpty &&
                                                                  _conversions.adjustedPrices
                                                                          .firstWhere((c) => c.market == market.slug)
                                                                          .price !=
                                                                      null)
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 12.0,
                                                                    vertical: 0,
                                                                  ),
                                                                  child: CardPrice(
                                                                    price:
                                                                        _conversions.adjustedPrices
                                                                            .firstWhere((c) => c.market == market.slug)
                                                                            .price,
                                                                    currency: market.currency,
                                                                    fontSize: 18,
                                                                    replaceSymbol: _conversions.symbol,
                                                                    color: context.proColor.color,
                                                                  ),
                                                                ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(
                                                                  horizontal: 12.0,
                                                                  vertical: 0,
                                                                ),
                                                                child: CardPrice(
                                                                  price: market.price,
                                                                  currency: market.currency,
                                                                  format: market.format,
                                                                  fontSize:
                                                                      _isPro &&
                                                                              _conversions.adjustedPrices
                                                                                  .where((c) => c.market == market.slug)
                                                                                  .isNotEmpty &&
                                                                              _conversions.adjustedPrices
                                                                                      .firstWhere(
                                                                                        (c) => c.market == market.slug,
                                                                                      )
                                                                                      .price !=
                                                                                  null
                                                                          ? 14
                                                                          : 18,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton.icon(
                                                icon: const Icon(Symbols.trending_up, size: 20),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                ),
                                                onPressed: () {
                                                  Config.router.navigateTo(
                                                    context,
                                                    '/card/stock',
                                                    routeSettings: RouteSettings(
                                                      arguments: {
                                                        "card": _card,
                                                        "conversions": _conversions,
                                                        "markets": _markets,
                                                      },
                                                    ),
                                                  );
                                                },
                                                label: const Text('Trends'),
                                              ),
                                              if (session != null)
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(width: 4),
                                                    ElevatedButton.icon(
                                                      icon: const Icon(Symbols.currency_exchange, size: 20),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: context.proColor.colorContainer,
                                                        foregroundColor: context.proColor.onColorContainer,
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 0,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        if (!_isPro) {
                                                          // showSubscribeDialog(context: context, source: 'card-view');
                                                          return;
                                                        }
                                                        _showCurrencyConverterDialog();
                                                      },
                                                      label: const Text('Change Currency'),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_card.cardsProfiles.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Subheader(text: 'In Collection'),
                                        RichText(
                                          text: TextSpan(
                                            text: '',
                                            children: [
                                              ..._card.cardsProfiles
                                                  .map(
                                                    (c) => WidgetSpan(
                                                      child: CardInCollection(card: _card, cardProfile: c),
                                                    ),
                                                  )
                                                  .toList(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_card.ability != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Subheader(text: 'ability'),
                                        _card.ability != null
                                            ? Text(
                                              _translation?.ability ?? _card.ability!,
                                              style: const TextStyle(fontSize: 16),
                                            )
                                            : const Text('-'),
                                      ],
                                    ),
                                  ),
                                if (session != null)
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: NoteBox(
                                      note: _note,
                                      type: 'card',
                                      typeId: _id,
                                      searchScreen: widget.searchScreen,
                                      cardSearch: widget.cardSearch,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: 'Energy'),
                                            Text(
                                              _card.energy != null ? _card.energy.toString() : '-',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: 'Might'),
                                            Text(
                                              _card.might != null ? _card.might.toString() : '-',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: 'Power'),
                                            Text(
                                              _card.power != null ? _card.power.toString() : '-',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: 'Type'),
                                            Text(
                                              _translation?.type ??
                                                  '${_card.type![0].toUpperCase()}${_card.type!.substring(1)}',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: 'Tags'),
                                            Text(
                                              _card.tags != null ? _translation?.tags ?? _card.tags! : '-',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: 'Print'),
                                            _card.print != null
                                                ? TitleCase(text: _card.print!, style: const TextStyle(fontSize: 16))
                                                : const Text('-', style: TextStyle(fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                      if (_card.originalId != null)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Subheader(text: 'Reprint'),
                                              Text('Yes', style: const TextStyle(fontSize: 16)),
                                            ],
                                          ),
                                        ),
                                      Expanded(
                                        flex: _card.originalId == null ? 2 : 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Subheader(text: 'Set'),
                                            _card.setName != null
                                                ? Text(_card.setName!, style: const TextStyle(fontSize: 16))
                                                : const Text('-'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: 'Text'),
                                            _card.flavorText != null
                                                ? TitleCase(text: _card.flavorText!, style: const TextStyle(fontSize: 16))
                                                : const Text('-', style: TextStyle(fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // if (!_isPro) const AdBanner(),
                                if (session != null) CardWhere(id: _id),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
            ],
          ),
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton:
            !_isLoading && widget.showOptions
                ? ExpandableFab(
                  key: _key,
                  distance: 82,
                  openButtonBuilder: RotateFloatingActionButtonBuilder(
                    child: const Icon(Symbols.menu),
                    fabSize: ExpandableFabSize.regular,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: const CircleBorder(),
                  ),
                  closeButtonBuilder: DefaultFloatingActionButtonBuilder(
                    child: const Icon(Symbols.close),
                    fabSize: ExpandableFabSize.regular,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: const CircleBorder(),
                  ),
                  children:
                      !_isLoading
                          ? [
                            CardOptionCollection(
                              fabKey: _key,
                              ref: ref,
                              card: _card,
                              searchScreen: widget.searchScreen,
                              cardSearch: widget.cardSearch,
                              updateCardProfiles: _updateCardProfiles,
                              deck: widget.deck,
                              vault: widget.vault,
                            ),
                            CardOptionVault(
                              fabKey: _key,
                              ref: ref,
                              card: _card,
                              searchScreen: widget.searchScreen,
                              cardSearch: widget.cardSearch,
                            ),
                            CardOptionDeck(
                              fabKey: _key,
                              ref: ref,
                              card: _card,
                              searchScreen: widget.searchScreen,
                              cardSearch: widget.cardSearch,
                            ),
                          ]
                          : [],
                )
                : null,
      ),
    );
  }
}
