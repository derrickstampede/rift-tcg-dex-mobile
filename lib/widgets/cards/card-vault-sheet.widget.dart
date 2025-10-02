import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/vault.model.dart';
import 'package:rift/models/card-search.model.dart';

import 'package:rift/helpers/cards-profiles.helper.dart';

import 'package:rift/providers/vault.provider.dart';

import 'package:rift/widgets/cards/card-variant-stamp.widget.dart';
import 'package:rift/widgets/cards/card-vault-button.widget.dart';
import 'package:rift/widgets/cards/card-vault-count.widget.dart';

class CardVaultSheet extends ConsumerStatefulWidget {
  const CardVaultSheet({
    super.key,
    required this.card,
    required this.vault,
    required this.add,
    required this.searchScreen,
    required this.cardSearch,
    this.showVaultInfo = false,
  });

  final CardListItem card;
  final Vault vault;
  final bool add;
  final String searchScreen;
  final CardSearch cardSearch;
  final bool showVaultInfo;

  @override
  ConsumerState<CardVaultSheet> createState() => _CardVaultSheetState();
}

class _CardVaultSheetState extends ConsumerState<CardVaultSheet> {
  bool _isLoading = false;

  Future<void> _loadCardsProfiles() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final response = await searchCardsProfiles(widget.card.id);
    response.fold((l) {
      setState(() {
        _showOwnedCards(l['cardProfiles']);
        _isLoading = false;
      });
    }, (r) {
      setState(() => _isLoading = false);
      // TODO error handling
    });
  }

  Future<void> _showOwnedCards(List<CardsProfiles> cardProfiles) async {
    await showModalBottomSheet(
        context: context,
        useSafeArea: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    height: 18,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'ADD TO VAULT',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  if (cardProfiles.isEmpty)
                    const SizedBox(
                      height: 60,
                      child: Center(child: Text('Add the card to collection first before adding to a vault')),
                    ),
                  for (int i = 0; i < cardProfiles.length; i++)
                    ListTile(
                      title: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
                          TextSpan(
                            text: '${cardProfiles[i].count.toString()}x ${widget.card.cardId}',
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
                                      language: cardProfiles[i].variant!.language!,
                                    )),
                              ))
                        ]),
                      ),
                      subtitle: Text(
                        widget.card.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: CardVaultButton(
                        cardProfile: cardProfiles[i],
                        vault: widget.vault,
                      ),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Close",
                                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final vault$ = ref.watch(vaultBuildNotifierProvider(widget.vault.slug));
    if (vault$ == null) {
      return const SizedBox();
    }

    Color backgroundColor = Color(int.parse(widget.vault.color!));
    Color foregroundColor = backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showVaultInfo)
            SizedBox(
              width: 32,
              child: RawMaterialButton(
                onPressed: null,
                elevation: 2.0,
                fillColor: Colors.black87,
                padding: const EdgeInsets.all(2),
                shape: const CircleBorder(),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CardVariantStamp(
                    language: widget.card.variant,
                  ),
                ),
              ),
            ),
          SizedBox(
            width: 42,
            child: RawMaterialButton(
              onPressed: _loadCardsProfiles,
              elevation: 2.0,
              fillColor: backgroundColor,
              padding: const EdgeInsets.all(8.0),
              shape: const CircleBorder(),
              child: Icon(
                widget.add ? Symbols.add : Symbols.remove,
                size: 24.0,
                color: foregroundColor,
              ),
            ),
          ),
          if (widget.showVaultInfo)
            SizedBox(
              width: 32,
              child: RawMaterialButton(
                onPressed: null,
                elevation: 2.0,
                fillColor: Colors.black87,
                padding: const EdgeInsets.all(2),
                shape: const CircleBorder(),
                child: CardVaultCount(
                  card: widget.card,
                  vault: widget.vault,
                  foregroundColor: foregroundColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
