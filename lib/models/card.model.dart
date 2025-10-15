import 'package:flutter/material.dart';

import 'package:rift/models/note.model.dart';

class CardItemView with ChangeNotifier {
  final int id;
  final String cardId;
  final String name;
  final String slug;
  final bool isParallel;
  final bool isSpecialParallel;
  final bool isSigned;
  final int? setId;
  final String? setName;
  final String? rarity;
  final String? color;
  final String? domain;
  final String? type;
  final int? energy;
  final int? might;
  final int? power;
  final String? ability;
  final String? flavorText;
  final String? tags;
  final String image;
  final String thumbnail;
  final String? backImage;
  final String? backThumbnail;
  final String? print;
  final String? orientation;
  final int? originalId;
  final int? maxDeckCards;
  final List<CardVariant> variants;
  List<CardsProfiles> cardsProfiles;
  final num? yytJp;
  final num? tcgpEn;
  final num? cmEn;
  final num? cmJp;

  CardItemView({
    required this.id,
    required this.cardId,
    required this.name,
    required this.slug,
    required this.isParallel,
    required this.isSpecialParallel,
    required this.isSigned,
    required this.setId,
    required this.setName,
    required this.rarity,
    required this.color,
    required this.domain,
    required this.type,
    required this.energy,
    required this.might,
    required this.power,
    required this.ability,
    required this.flavorText,
    required this.tags,
    required this.image,
    required this.thumbnail,
    required this.backImage,
    required this.backThumbnail,
    required this.orientation,
    required this.print,
    required this.originalId,
    required this.maxDeckCards,
    required this.variants,
    required this.cardsProfiles,
    required this.yytJp,
    required this.tcgpEn,
    required this.cmEn,
    required this.cmJp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'cardId': cardId,
    'name': name,
    'slug': slug,
    'is_parallel': isParallel,
    'is_special_parallel': isSpecialParallel,
    'is_signed': isSigned,
    'setId': setId,
    'setName': setName,
    'rarity': rarity,
    'color': color,
    'domain': domain,
    'type': type,
    'energy': energy,
    'might': might,
    'power': power,
    'ability': ability,
    'flavor_text': flavorText,
    'tags': tags,
    'image': image,
    'thumbnail': thumbnail,
    'back_image': backImage,
    'back_thumbnail': backThumbnail,
    'orientation': orientation,
    'print': print,
    'original_id': originalId,
    'max_deck_cards': maxDeckCards,
    'variants': variants.map((c) => c.toJson()).toList(),
    'cardsProfiles': cardsProfiles.map((c) => c.toJson()).toList(),
    'yyt_jp': yytJp,
    'tcgp_en': tcgpEn,
    'cm_en': cmEn,
    'cm_jp': cmJp,
  };

  factory CardItemView.fromMap(Map<String, dynamic> map) => CardItemView(
    id: map['id'],
    cardId: map['card_id'],
    name: map['name'],
    slug: map['slug'],
    isParallel: map['is_parallel'],
    isSpecialParallel: map['is_special_parallel'],
    isSigned: map['is_signed'],
    setId: map['set_id'],
    setName: map['set'] != null ? map['set']['name'] : null,
    rarity: map['rarity'],
    color: map['color'],
    domain: map['domain'],
    type: map['type'],
    energy: map['energy'],
    might: map['might'],
    power: map['power'],
    ability: map['ability'],
    flavorText: map['flavor_text'],
    tags: map['tags'],
    image: map['image'],
    thumbnail: map['thumbnail'],
    backImage: map['back_image'],
    backThumbnail: map['back_thumbnail'],
    orientation: map['orientation'],
    print: map['print'],
    originalId: map['original_id'],
    maxDeckCards: map['max_deck_cards'],
    variants: map['variants'] != null ? map['variants'].map<CardVariant>((t) => CardVariant.fromMap(t)).toList() : [],
    cardsProfiles:
        map['cardsProfiles'] != null
            ? map['cardsProfiles'].map<CardsProfiles>((t) => CardsProfiles.fromMap(t)).toList()
            : [],
    yytJp: map['yyt_jp'],
    tcgpEn: map['tcgp_en'],
    cmEn: map['cm_en'],
    cmJp: map['cm_jp'],
  );
}

class CardListItem with ChangeNotifier {
  final int id;
  final String cardId;
  final String name;
  final String slug;
  final CardSet? set;
  String thumbnail;
  final String? backThumbnail;
  final String? rarity;
  final String? color;
  final String? domain;
  final String? type;
  final int? energy;
  final int? might;
  final int? power;
  final String? print;
  final String? orientation;
  final String? variant;
  final List<CardVariant> variants;
  List<CardsProfiles>? cardsProfiles;
  List<CardListItemConversions>? conversions;
  Note? note;
  int? maxDeckCards;
  int count;
  final num? yytJp;
  final num? tcgpEn;
  final num? cmEn;
  final num? cmJp;
  final String? legend;

  CardListItem({
    required this.id,
    required this.cardId,
    required this.name,
    required this.slug,
    required this.set,
    required this.thumbnail,
    required this.backThumbnail,
    required this.rarity,
    required this.color,
    required this.domain,
    required this.type,
    required this.energy,
    required this.might,
    required this.power,
    required this.print,
    required this.orientation,
    required this.variant,
    required this.variants,
    required this.cardsProfiles,
    required this.conversions,
    required this.note,
    required this.maxDeckCards,
    required this.count,
    required this.yytJp,
    required this.tcgpEn,
    required this.cmEn,
    required this.cmJp,
    this.legend,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'card_id': cardId,
    'name': name,
    'slug': slug,
    'set': set?.toJson(),
    'thumbnail': thumbnail,
    'back_thumbnail': backThumbnail,
    'rarity': rarity,
    'color': color,
    'domain': domain,
    'type': type,
    'energy': energy,
    'might': might,
    'power': power,
    'print': print,
    'orientation': orientation,
    'variant': variant,
    'variants': variants.map((c) => c.toJson()).toList(),
    'cardsProfiles': cardsProfiles != null ? cardsProfiles!.map((c) => c.toJson()).toList() : [],
    'conversions': conversions != null ? conversions!.map((c) => c.toJson()).toList() : [],
    'note': note?.toJson(),
    'max_deck_cards': maxDeckCards,
    'count': count,
    'yyt_jp': yytJp,
    'tcgp_en': tcgpEn,
    'cm_en': cmEn,
    'cm_jp': cmJp,
    'legend': legend,
  };

  factory CardListItem.fromMap(Map<String, dynamic> map) => CardListItem(
    id: map['id'],
    cardId: map['card_id'],
    name: map['name'],
    slug: map['slug'],
    set: map['set'] != null ? CardSet.fromMap(map['set']) : null,
    thumbnail: map['thumbnail'],
    backThumbnail: map['back_thumbnail'],
    rarity: map['rarity'],
    color: map['color'],
    domain: map['domain'],
    type: map['type'],
    energy: map['energy'],
    might: map['might'],
    power: map['power'],
    print: map['print'],
    orientation: map['orientation'],
    variant: map['variant'],
    variants: map['variants'] != null ? map['variants'].map<CardVariant>((t) => CardVariant.fromMap(t)).toList() : [],
    cardsProfiles:
        map['cardsProfiles'] != null
            ? map['cardsProfiles'].map<CardsProfiles>((t) => CardsProfiles.fromMap(t)).toList()
            : [],
    conversions:
        map['conversions'] != null
            ? map['conversions'].map<CardListItemConversions>((t) => CardListItemConversions.fromMap(t)).toList()
            : [],
    note: map['note'] != null ? Note.fromMap(map['note']) : null,
    maxDeckCards: map['max_deck_cards'],
    count: map['count'] ?? 0,
    yytJp: map['yyt_jp'],
    tcgpEn: map['tcgp_en'],
    cmEn: map['cm_en'],
    cmJp: map['cm_jp'],
    legend: map['legend'],
  );
}

class CardSet with ChangeNotifier {
  final int id;
  final String name;
  final String slug;

  CardSet({required this.id, required this.name, required this.slug});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};

  factory CardSet.fromMap(Map<String, dynamic> map) => CardSet(id: map['id'], name: map['name'], slug: map['slug']);
}

class CardSorted with ChangeNotifier {
  String? direction;
  String? attribute;

  CardSorted({required this.direction, required this.attribute});

  void update({String? dir, String? att}) {
    direction = dir;
    direction = att;
  }
}

class CardVariant with ChangeNotifier {
  int id;
  String? language;
  String? image;
  String? thumbnail;
  String? backImage;
  String? backThumbnail;
  int? order;
  int? count;

  CardVariant({
    required this.id,
    required this.language,
    this.image,
    this.thumbnail,
    this.backImage,
    this.backThumbnail,
    this.order,
    this.count,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'language': language,
    'image': image,
    'thumbnail': thumbnail,
    'back_image': backImage,
    'back_thumbnail': backThumbnail,
    'order': order,
    'count': count,
  };

  factory CardVariant.fromJson(Map<String, dynamic> json) => CardVariant(
    id: json['id'],
    language: json['language'],
    image: json['image'],
    thumbnail: json['thumbnail'],
    backImage: json['back_image'],
    backThumbnail: json['back_thumbnail'],
    order: json['order'],
    count: json['count'],
  );

  factory CardVariant.fromMap(Map<String, dynamic> map) => CardVariant(
    id: map['id'],
    language: map['language'],
    image: map['image'],
    thumbnail: map['thumbnail'],
    backImage: map['back_image'],
    backThumbnail: map['back_thumbnail'],
    order: map['order'],
    count: map['count'],
  );
}

class CardMarket with ChangeNotifier {
  String name;
  String slug;
  bool isPro;
  String language;
  String currency;
  String logo;
  String squareLogo;
  String? format;
  num? price;

  CardMarket({
    required this.name,
    required this.slug,
    required this.isPro,
    required this.language,
    required this.currency,
    required this.logo,
    required this.squareLogo,
    required this.format,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'slug': slug,
    'is_pro': isPro,
    'language': language,
    'currency': currency,
    'logo': logo,
    'square_logo': squareLogo,
    'format': format,
    'price': price,
  };

  factory CardMarket.fromJson(Map<String, dynamic> json) => CardMarket(
    name: json['name'],
    slug: json['slug'],
    isPro: json['is_pro'],
    language: json['language'],
    currency: json['currency'],
    logo: json['logo'],
    squareLogo: json['square_logo'],
    format: json['format'],
    price: json['price'],
  );

  factory CardMarket.fromMap(Map<String, dynamic> map) => CardMarket(
    name: map['name'],
    slug: map['slug'],
    isPro: map['is_pro'],
    language: map['language'],
    currency: map['currency'],
    logo: map['logo'],
    squareLogo: map['square_logo'],
    format: map['format'],
    price: map['price'],
  );
}

class CardVault with ChangeNotifier {
  int id;
  String? name;
  String? color;

  CardVault({required this.id, required this.name, this.color});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color};

  factory CardVault.fromJson(Map<String, dynamic> json) =>
      CardVault(id: json['id'], name: json['name'], color: json['color']);

  factory CardVault.fromMap(Map<String, dynamic> map) =>
      CardVault(id: map['id'], name: map['name'], color: map['color']);
}

class CardVaultCard with ChangeNotifier {
  int id;
  String cardId;
  String name;
  String thumbnail;
  num? price;
  num? tcgpPrice;

  CardVaultCard({
    required this.id,
    required this.cardId,
    required this.name,
    required this.thumbnail,
    required this.price,
    required this.tcgpPrice,
  });

  factory CardVaultCard.fromMap(Map<String, dynamic> map) => CardVaultCard(
    id: map['id'],
    cardId: map['card_id'],
    name: map['name'],
    thumbnail: map['thumbnail'],
    price: map['price'],
    tcgpPrice: map['tcgp_price'],
  );
}

class CardsProfiles with ChangeNotifier {
  int? cardId;
  int? variantId;
  int? vaultId;
  CardVariant? variant;
  CardVault? vault;
  CardVaultCard? card;
  int count;

  CardsProfiles({
    required this.cardId,
    required this.variantId,
    required this.vaultId,
    required this.count,
    this.variant,
    this.vault,
    this.card,
  });

  Map<String, dynamic> toJson() => {
    'card_id': cardId,
    'variant_id': variantId,
    'vault_id': vaultId,
    'count': count,
    'variant': variant?.toJson(),
  };

  factory CardsProfiles.fromJson(Map<String, dynamic> json) => CardsProfiles(
    cardId: json['card_id'],
    variantId: json['variant_id'],
    vaultId: json['vault_id'],
    count: json['count'],
    variant: json['variant'] != null ? CardVariant.fromJson(json['variant']) : null,
  );

  factory CardsProfiles.fromMap(Map<String, dynamic> map) => CardsProfiles(
    cardId: map['card_id'],
    variantId: map['variant_id'],
    vaultId: map['vault_id'],
    variant: map['variant'] != null ? CardVariant.fromMap(map['variant']) : null,
    vault: map['vault'] != null ? CardVault.fromMap(map['vault']) : null,
    card: map['card'] != null ? CardVaultCard.fromMap(map['card']) : null,
    count: map['count'],
  );
}

class CardListItemConversions with ChangeNotifier {
  String market;
  final num? price;

  CardListItemConversions({required this.market, required this.price});

  Map<String, dynamic> toJson() => {'market': market, 'price': price};

  factory CardListItemConversions.fromJson(Map<String, dynamic> json) =>
      CardListItemConversions(market: json['market'], price: json['price']);

  factory CardListItemConversions.fromMap(Map<String, dynamic> map) =>
      CardListItemConversions(market: map['market'], price: map['price']);
}

class CardCheck with ChangeNotifier {
  final int id;
  final String cardId;
  final String name;
  List<CardsProfiles>? cardsProfiles;

  CardCheck({required this.id, required this.name, required this.cardId, required this.cardsProfiles});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'card_id': cardId,
    'cardsProfiles': cardsProfiles != null ? cardsProfiles!.map((c) => c.toJson()).toList() : [],
  };

  factory CardCheck.fromMap(Map<String, dynamic> map) => CardCheck(
    id: map['id'],
    name: map['name'],
    cardId: map['card_id'],
    cardsProfiles:
        map['cardsProfiles'] != null
            ? map['cardsProfiles'].map<CardsProfiles>((t) => CardsProfiles.fromMap(t)).toList()
            : [],
  );
}

class CardConversions with ChangeNotifier {
  final List<CardAdjustedPrices> adjustedPrices;
  final String? symbol;

  CardConversions({required this.adjustedPrices, required this.symbol});

  Map<String, dynamic> toJson() => {
    'adjusted_prices': adjustedPrices.map((c) => c.toJson()).toList(),
    'symbol': symbol,
  };

  factory CardConversions.fromMap(Map<String, dynamic> map) => CardConversions(
    adjustedPrices:
        map['adjusted_prices'] != null
            ? map['adjusted_prices'].map<CardAdjustedPrices>((c) => CardAdjustedPrices.fromMap(c)).toList()
            : [],
    symbol: map['symbol'],
  );
}

class CardAdjustedPrices with ChangeNotifier {
  final String market;
  final num? price;

  CardAdjustedPrices({required this.market, required this.price});

  Map<String, dynamic> toJson() => {'market': market, 'price': price};

  factory CardAdjustedPrices.fromMap(Map<String, dynamic> map) =>
      CardAdjustedPrices(market: map['market'], price: map['price']);
}
