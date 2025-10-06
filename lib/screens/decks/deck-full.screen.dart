import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

import 'package:rift/models/card.model.dart';

import 'package:rift/widgets/cards/card-image.widget.dart';

class DeckFullScreen extends StatelessWidget {
  const DeckFullScreen(
      {super.key,
      required this.name,
      required this.cards,
      required this.foregroundColor,
      required this.backgroundColor});

  final String name;
  final List<CardListItem> cards;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: Text(name),
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: cards.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          itemBuilder: (context, index) => RepaintBoundary(
            child: badges.Badge(
              badgeContent: Text(
                cards[index].type == "leader" ? "L" : cards[index].count.toString(),
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: foregroundColor),
              ),
              badgeStyle: badges.BadgeStyle(
                badgeColor: backgroundColor,
                padding: const EdgeInsets.all(8),
                elevation: 4,
              ),
              position: badges.BadgePosition.topEnd(top: -10, end: -4),
              child: CardImage(
                imageUrl: cards[index].thumbnail,
              ),
            ),
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, mainAxisSpacing: 5, crossAxisSpacing: 5, childAspectRatio: 300 / 420),
        ),
      ),
      persistentFooterButtons: [
        Container(
          height: 18,
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              children: [
              const TextSpan(
                text: 'Built with ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              const TextSpan(
                text: 'RIFT TCG Dex ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              WidgetSpan(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      height: 20,
                      width: 20,
                      child: Image.asset('assets/images/app-store.png')),
                  alignment: PlaceholderAlignment.middle),
              WidgetSpan(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      height: 20,
                      width: 20,
                      child: Image.asset('assets/images/google-play.png')),
                  alignment: PlaceholderAlignment.middle),
            ]),
          ),
        )
      ],
    );
  }
}
