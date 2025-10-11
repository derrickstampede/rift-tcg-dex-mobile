import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

// import 'package:rift/helpers/revenuecat.helper.dart';

import 'package:rift/widgets/card-options/card-deck-list.widget.dart';
import 'package:rift/widgets/card-options/card-deck-edit.widget.dart';
import 'package:rift/widgets/ads/ad-banner.widget.dart';

import 'package:rift/models/card.model.dart';

class CardSingleAddToDeck extends ConsumerStatefulWidget {
  const CardSingleAddToDeck({super.key, required this.card});

  final CardItemView card;

  @override
  ConsumerState<CardSingleAddToDeck> createState() => _CardSingleAddToDeckState();
}

class _CardSingleAddToDeckState extends ConsumerState<CardSingleAddToDeck> {
  String _header = 'ADD TO DECK';
  bool _isSelectingDeck = true;

  late String? _selectedDeckSlug;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    super.initState();

    // Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    //   final isSubscribed = checkIfSubscribed(customerInfo);
    //   if (isSubscribed) setState(() => _isPro = isSubscribed);
    // });
  }

  void selectDeck(String slug) {
    _selectedDeckSlug = slug;

    setState(() {
      _header = 'EDIT DECK';
      _isSelectingDeck = false;
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
                _isSelectingDeck
                    ? CardDeckList(
                        card: widget.card,
                        selectDeck: selectDeck,
                      )
                    : CardDeckEdit(card: widget.card, slug: _selectedDeckSlug!)
              ],
            ),
          );
        });
  }
}
