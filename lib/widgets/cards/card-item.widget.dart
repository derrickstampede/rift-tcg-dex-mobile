import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rift/screens/cards/card.screen.dart';

import 'package:rift/widgets/cards/card-image.widget.dart';

import 'package:rift/models/card.model.dart';

import 'package:rift/helpers/util.helper.dart';

import 'package:rift/globals.dart';

import 'package:rift/routes/config.dart';

class CardItem extends ConsumerStatefulWidget {
  const CardItem({
    super.key,
    required this.card,
    this.showLabel = true,
    this.showTiled = true,
  });

  final CardListItem card;
  final bool showLabel;
  final bool showTiled;

  @override
  ConsumerState<CardItem> createState() => _CardItemState();
}

class _CardItemState extends ConsumerState<CardItem> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final encodedName = Uri.encodeComponent(widget.card.name);
    final encodedImage = Uri.encodeComponent(widget.card.thumbnail);
    final route = '/card?id=${widget.card.id}&name=$encodedName&cardId=${widget.card.cardId}&image=$encodedImage';
    final cardThumbnail = GestureDetector(
        onTap: () async {
          snackbarKey.currentState?.hideCurrentSnackBar();
          await Navigator.of(context).push(
            TransparentRoute(
                builder: (BuildContext context) => CardScreen(
                      id: widget.card.id.toString(),
                      name: widget.card.name,
                      cardId: widget.card.cardId,
                      image: widget.card.thumbnail,
                      showOptions: false,
                    )),
          );
          // askReview();
        },
        child: CardImage(
          imageUrl: widget.card.thumbnail,
        ));

    return widget.showTiled
        ? GridTile(
            footer: GestureDetector(
              onTap: () {
                Config.router.navigateTo(context, route);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                  color: Colors.black87,
                ),
                child: Column(
                  children: [
                    // Center(
                    //     child: Text(
                    //   widget.card.id.toString(),
                    //   style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    // )),
                    Center(
                        child: FittedBox(
                      child: Text(
                        widget.card.cardId,
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            child: cardThumbnail)
        : cardThumbnail;
  }
}
