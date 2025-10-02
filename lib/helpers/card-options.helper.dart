import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:rift/helpers/cards-profiles.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/deck.helper.dart';
import 'package:rift/helpers/review.helper.dart';

import 'package:rift/widgets/card-options/card-single-add-to-deck.widget.dart';
import 'package:rift/widgets/card-options/card-single-add-to-vault.widget.dart';
import 'package:rift/widgets/cards/card-image.widget.dart';
import 'package:rift/widgets/cards/card-variant-stamp.widget.dart';
// import 'package:rift/widgets/ads/ad-banner.widget.dart';
// import 'package:rift/widgets/ads/ad-mdrect-banner.widget.dart';

import 'package:rift/models/card.model.dart';

Future<List<CardsProfiles>?> addToCollectionModal(BuildContext context, CardItemView card, bool isPro) async {
  final List<CardsProfiles> cardsProfiles = [];

  for (var i = 0; i < card.variants.length; i++) {
    final index = card.cardsProfiles.indexWhere((cp) => cp.variantId == card.variants[i].id);
    if (index < 0) {
      cardsProfiles.add(CardsProfiles(
          cardId: card.id,
          variantId: card.variants[i].id,
          count: 0,
          vaultId: null,
          variant: CardVariant(id: card.variants[i].id, language: card.variants[i].language)));
    } else {
      cardsProfiles.add(CardsProfiles.fromJson(card.cardsProfiles[index].toJson()));
    }
  }

  final response = await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          setState(() => cardsProfiles);

          void increment(int index) {
            setState(() {
              if (cardsProfiles[index].count < 99) {
                cardsProfiles[index].count++;
              }
            });
          }

          void decrement(int index) {
            setState(() {
              if (cardsProfiles[index].count > 0) {
                cardsProfiles[index].count--;
              }
            });
          }

          void close() {
            Navigator.pop(context, cardsProfiles);
          }

          void save() async {
            close();

            await storeCardsProfiles(cardsProfiles);
            int count = cardsProfiles.fold(0, (sum, item) => sum + item.count);
            logEvent(
                name: 'collection_update',
                parameters: {'id': card.id, 'card_id': card.cardId, 'name': card.name, 'count': count});
            incrementReviewPreq('collection_update');
          }

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ADD TO COLLECTION',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        width: 44,
                        child: RawMaterialButton(
                          onPressed: () => Navigator.of(context).pop(),
                          elevation: 2.0,
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.close,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // if (!isPro) const AdBanner(),
                for (int i = 0; i < card.variants.length; i++)
                  ListTile(
                    title: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
                        TextSpan(
                          text: card.cardId,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CardVariantStamp(
                                    language: card.variants[i].language,
                                  )),
                            ))
                      ]),
                    ),
                    subtitle: Text(
                      card.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                              width: 40,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  decrement(i);
                                },
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(4),
                                    backgroundColor: Theme.of(context).colorScheme.onPrimary),
                                child: Icon(
                                  Symbols.remove,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )),
                          const SizedBox(
                            width: 6,
                          ),
                          SizedBox(
                            width: 28,
                            child: Text(
                              cardsProfiles[i].count.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          SizedBox(
                              width: 40,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  increment(i);
                                },
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(4),
                                    backgroundColor: Theme.of(context).colorScheme.onPrimary),
                                child: Icon(
                                  Symbols.add,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )),
                        ],
                      ),
                    ),
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(4), backgroundColor: Theme.of(context).colorScheme.primary),
                        onPressed: save,
                        child: Text(
                          "Save",
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
                        ))),
              ],
            ),
          );
        });
      });

  return response;
}

Future<String?> showDecksModal(BuildContext context, CardItemView card) async {
  final response = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return CardSingleAddToDeck(
          card: card,
        );
      });

  return response;
}

Future<String?> showVaultsModal(BuildContext context, CardItemView card) async {
  final response = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return CardSingleAddToVault(
          card: card,
        );
      });

  return response;
}

Future<String?> switchLeaderModal(BuildContext context, String deckSlug, int currentLeaderId,
    List<CardItemView> cards, Color backgroundColor, Color foregroundColor) async {
  int currentIndex = cards.indexWhere((card) => card.id == currentLeaderId);
  final response = await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          void save() async {
            if (cards[currentIndex].id == currentLeaderId) {
              Navigator.pop(context);
              return;
            }

            final response = await updateLeaderDeck(deckSlug, cards[currentIndex].id);
            return response.fold((l) {
              Navigator.pop(context, cards[currentIndex].thumbnail);
            }, (r) {
              Navigator.pop(context);
            });
          }

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SWITCH LEADER CARD',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        width: 44,
                        child: RawMaterialButton(
                          onPressed: () => Navigator.of(context).pop(),
                          elevation: 2.0,
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.close,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: 300 / 420,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            // Handle card selection
                          },
                          child: Stack(children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CardImage(
                                imageUrl: cards[index].thumbnail,
                              ),
                            ),
                            Positioned(
                              bottom: 46,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                width: 42,
                                child: RawMaterialButton(
                                  onPressed: () async {
                                    // _getLeaders(widget.card.cardId);
                                    // final cards = await _getLeaders(widget.card.cardId);
                                    // switchLeaderModal(context, cards);
                                    // switchLeaderModal(context, widget.card);
                                    setState(() {
                                      currentIndex = index;
                                    });
                                  },
                                  elevation: 2.0,
                                  fillColor: index == currentIndex
                                      ? backgroundColor.withOpacity(0.9)
                                      : foregroundColor.withOpacity(0.9),
                                  padding: const EdgeInsets.all(8.0),
                                  shape: const CircleBorder(),
                                  child: Icon(
                                    index == currentIndex ? Symbols.check : Symbols.loop,
                                    size: 24.0,
                                    color: index == currentIndex ? foregroundColor : backgroundColor,
                                  ),
                                ),
                              ),
                            ),
                          ]));
                    },
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(4), backgroundColor: Theme.of(context).colorScheme.primary),
                        onPressed: save,
                        child: Text(
                          "Save",
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
                        ))),
              ],
            ),
          );
        });
      });

  return response;
}
