import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/helpers/cards-profiles.helper.dart';
import 'package:rift/helpers/vault.helper.dart';
import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/vault.model.dart';

import 'package:rift/widgets/card-options/card-vault-list.widget.dart';
import 'package:rift/widgets/cards/card-variant-stamp.widget.dart';
import 'package:rift/widgets/cards/card-vault-button.widget.dart';
import 'package:rift/widgets/ads/ad-banner.widget.dart';

class CardSingleAddToVault extends ConsumerStatefulWidget {
  const CardSingleAddToVault({super.key, required this.card});

  final CardItemView card;

  @override
  ConsumerState<CardSingleAddToVault> createState() => _CardSingleAddToVaultState();
}

class _CardSingleAddToVaultState extends ConsumerState<CardSingleAddToVault> {
  String _header = 'ADD TO VAULT';
  bool _isSelectingVault = true;

  bool _isLoadingVaults = true;
  List<CardsProfiles> _cardProfiles = [];

  late String? _selectedVaultSlug;
  Vault? _vault;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    super.initState();

    loadCardsProfiles();

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final isSubscribed = checkIfSubscribed(customerInfo);
      if (isSubscribed) setState(() => _isPro = isSubscribed);
    });
  }

  void selectVault(String slug) {
    _selectedVaultSlug = slug;
    fetchVault();

    setState(() {
      _header = 'ADD TO VAULT';
      _isSelectingVault = false;
    });
  }

  Future<void> loadCardsProfiles() async {
    final response = await searchCardsProfiles(widget.card.id);
    response.fold((l) {
      setState(() {
        _isLoadingVaults = false;
        _cardProfiles = l['cardProfiles'];
      });
    }, (r) {
      setState(() => _isLoadingVaults = false);
      // TODO error handling
    });
  }

  Future<void> fetchVault() async {
    final response = await findVault(_selectedVaultSlug!);
    response.fold((l) {
      setState(() {
        _vault = l['vault'];
      });
    }, (r) {
      // TODO error handling
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        snap: true,
        initialChildSize: 0.4,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) {
          return SingleChildScrollView(
            controller: controller,
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
                      Text(
                        _header,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
                if (!_isPro) const AdBanner(),
                !_isLoadingVaults
                    ? _cardProfiles.isNotEmpty
                        ? _isSelectingVault
                            ? CardVaultList(
                                card: widget.card,
                                selectVault: selectVault,
                              )
                            : Column(
                                children: [
                                  for (int i = 0; i < _cardProfiles.length; i++)
                                    ListTile(
                                      title: RichText(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
                                          TextSpan(
                                            text: '${_cardProfiles[i].count.toString()}x ${widget.card.cardId}',
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
                                                      language: _cardProfiles[i].variant!.language!,
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
                                      trailing: _vault != null
                                          ? CardVaultButton(
                                              cardProfile: _cardProfiles[i],
                                              vault: _vault!,
                                            )
                                          : const CircularProgressIndicator(),
                                      dense: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                    ),
                                ],
                              )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'Add this card to your collection first before adding to a vault',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
              ],
            ),
          );
        });
  }
}
