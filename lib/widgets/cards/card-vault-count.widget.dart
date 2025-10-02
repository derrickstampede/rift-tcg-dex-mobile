import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/vault.model.dart';

import 'package:rift/providers/vault.provider.dart';

class CardVaultCount extends ConsumerWidget {
  const CardVaultCount({
    super.key,
    required this.vault,
    required this.card,
    required this.foregroundColor,
  });

  final Vault vault;
  final CardListItem card;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vault$ = ref.watch(vaultBuildNotifierProvider(vault.slug));
    if (vault$ == null) {
      return const SizedBox();
    }

    return Text(
      card.count.toString(),
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
