import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:rift/main.dart';

import 'package:rift/routes/config.dart';

import 'package:rift/models/deck.model.dart';
import 'package:rift/models/vault.model.dart';

import 'package:rift/helpers/card.helper.dart';

import 'package:rift/widgets/cards/card-image.widget.dart';
import 'package:rift/widgets/misc/domain-icon.widget.dart';
import 'package:rift/widgets/misc/color-circle.widget.dart';
import 'package:rift/widgets/misc/titlecase.widget.dart';
import 'package:rift/widgets/misc/subheader.widget.dart';

class CardWhere extends StatefulWidget {
  const CardWhere({super.key, required this.id});

  final String id;

  @override
  State<CardWhere> createState() => _CardWhereState();
}

class _CardWhereState extends State<CardWhere> {
  Session? session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  bool _isLoading = true;
  List<Deck> _decks = [];
  List<Vault> _vaults = [];

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        session = data.session;
        _findWhere();
      });
    });
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

  Future<void> _findWhere() async {
    if (session == null) return;

    setState(() => _isLoading = true);

    final response = await findCardWhere(widget.id);
    response.fold(
      (l) {
        setState(() {
          _decks = l['decks'];
          _vaults = l['vaults'];
          _isLoading = false;
        });
      },
      (r) {
        // TODO error handling
        print(r);
      },
    );
  }

  void _goToDeck(Deck deck) async {
    final encodedColor = Uri.encodeComponent(deck.legend.color!);
    await Config.router.navigateTo(context, '/decks/edit?slug=${deck.slug}&name=${deck.name}&color=$encodedColor');
  }

  void _goToVault(Vault vault) async {
    Config.router.navigateTo(context, '/vaults/view?slug=${vault.slug}&name=${vault.name}&color=${vault.color}');
  }

  @override
  Widget build(BuildContext context) {
    if (session == null) return const SizedBox();
    if (_isLoading) {
      return const Padding(padding: EdgeInsets.only(top: 16.0), child: CircularProgressIndicator());
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Subheader(text: 'Decks')),
                if (_decks.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('-', style: TextStyle(fontSize: 16)),
                  ),
                ..._decks.map((d) {
                  final visibility = d.isPublic ? 'Public' : 'Private';
                  final visibilityIcon = d.isPublic ? Symbols.public : Symbols.lock;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    dense: true,
                    leading: SizedBox(width: 42, child: CardImage(imageUrl: d.legend.thumbnail)),
                    title: Text(
                      d.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: '',
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(text: '${d.cardCount} cards \u2981 '),
                          for (var domain in d.legend.color!.split('/'))
                            WidgetSpan(alignment: PlaceholderAlignment.middle, child: DomainIcon(domain: domain)),
                          TextSpan(text: ' \u2981 '),
                          WidgetSpan(alignment: PlaceholderAlignment.middle, child: Icon(visibilityIcon, size: 16)),
                          TextSpan(text: ' $visibility'),
                        ],
                      ),
                    ),
                    onTap: () => _goToDeck(d)
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Subheader(text: 'Vaults')),
                if (_vaults.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('-', style: TextStyle(fontSize: 16)),
                  ),
                ..._vaults.map(
                  (v) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    dense: true,
                    leading:
                        v.photo != null
                            ? SizedBox(
                              width: 42,
                              height: 42,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: Container(
                                  color: Colors.grey,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: FancyShimmerImage(imageUrl: v.photo!, boxFit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            )
                            : null,
                    title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    subtitle: TitleCase(text: v.type),
                    trailing: ColorCircle(size: 24, colors: '', color: Color(int.parse(v.color!))),
                    onTap: () => _goToVault(v),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
