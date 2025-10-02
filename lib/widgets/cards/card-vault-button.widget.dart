import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rift/models/card.model.dart';
import 'package:rift/models/vault.model.dart';

import 'package:rift/providers/vault.provider.dart';

import 'package:rift/helpers/cards-profiles.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/providers/vaults.provider.dart';

class CardVaultButton extends ConsumerStatefulWidget {
  const CardVaultButton({
    super.key,
    required this.cardProfile,
    required this.vault,
    // this.searchScreen,
    // this.cardSearch,
  });

  final CardsProfiles cardProfile;
  final Vault vault;
  // final String? searchScreen;
  // final CardSearch? cardSearch;

  @override
  ConsumerState<CardVaultButton> createState() => _CardVaultButtonState();
}

class _CardVaultButtonState extends ConsumerState<CardVaultButton> {
  bool _isInVault = false;
  bool _isUpdating = false;
  bool _isFromAnotherVault = false;

  @override
  void initState() {
    super.initState();

    if (widget.cardProfile.vaultId == widget.vault.id) {
      setState(() => _isInVault = true);
    }
    if (widget.cardProfile.vaultId != null && widget.cardProfile.vaultId != widget.vault.id) {
      setState(() => _isFromAnotherVault = true);
    }
  }

  Future<void> _add(WidgetRef ref) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    final response = await addToVault(widget.cardProfile, widget.vault);
    response.fold((l) {
      if (l['is_added']) {
        setState(() {
          _isInVault = true;
          _isUpdating = false;
          _isFromAnotherVault = false;
        });

        ref.read(vaultBuildNotifierProvider(widget.vault.slug).notifier).addCard(l['card']);
        ref.read(vaultListNotifierProvider.notifier).updateUpdatedAt(widget.vault.slug);
      }
    }, (r) {
      setState(() => _isUpdating = false);
      showSnackbar('Unable to add cards to vault', subtitle: r['message']);
    });
  }

  Future<void> _remove(WidgetRef ref) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    final response = await removeFromVault(widget.cardProfile, widget.vault);
    response.fold((l) {
      if (l['is_removed']) {
        setState(() {
          _isInVault = false;
          _isUpdating = false;
        });

        ref
            .read(vaultBuildNotifierProvider(widget.vault.slug).notifier)
            .removeCard(widget.cardProfile.cardId!, widget.cardProfile.variant!.language!);
        ref.read(vaultListNotifierProvider.notifier).updateUpdatedAt(widget.vault.slug);
      }
    }, (r) {
      setState(() => _isUpdating = false);
      showSnackbar('Unable to remove cards from vault', subtitle: r['message']);
    });
  }

  Future<void> _showMoveDialog(WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                text: '',
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: "You are about to transfer this card from ",
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.outline),
                  ),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: Color(int.parse(widget.cardProfile.vault!.color!)),
                        ),
                      )),
                  TextSpan(
                    text: " ${widget.cardProfile.vault!.name} ",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.outline),
                  ),
                  TextSpan(
                    text: "to ",
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.outline),
                  ),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: Color(int.parse(widget.vault.color!)),
                        ),
                      )),
                  TextSpan(
                    text: " ${widget.vault.name}",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),
            ),
            // Text('You are about to transfer this card from ${widget.cardProfile.vault!.name} to ${widget.vault.name}'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Transfer',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                _add(ref);
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
    return !_isUpdating
        ? SizedBox(
            width: 90,
            child: !_isInVault
                ? ElevatedButton(
                    onPressed: !_isFromAnotherVault ? () => _add(ref) : () => _showMoveDialog(ref),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 3)),
                    child: Text(
                      !_isFromAnotherVault ? 'Add' : 'Transfer',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  )
                : TextButton(
                    onPressed: () => _remove(ref),
                    child: Text(
                      'Remove',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    )),
          )
        : const Padding(
            padding: EdgeInsets.symmetric(horizontal: 33.0),
            child: SizedBox(width: 24, height: 24, child: Center(child: CircularProgressIndicator())),
          );
  }
}
