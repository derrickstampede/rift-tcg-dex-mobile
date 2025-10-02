import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:rift/models/card-search.model.dart';
import 'package:rift/models/filter.model.dart';

import 'package:rift/providers/card-search.provider.dart';

class CardSortHeader extends ConsumerStatefulWidget {
  const CardSortHeader({
    super.key,
    required this.searchScreen,
    required this.cardSearch,
    this.showSortDropdown = true,
    this.showLabelDropdown = true,
    this.showOwnedDropdown = true,
    this.sortedBy,
    this.sortBy,
    this.isAscending,
    this.sortOrder,
  });

  final String searchScreen;
  final CardSearch cardSearch;
  final bool showSortDropdown;
  final bool showLabelDropdown;
  final bool showOwnedDropdown;
  final String? sortedBy;
  final void Function({required String? by})? sortBy;
  final bool? isAscending;
  final void Function({required bool isAscending})? sortOrder;

  @override
  ConsumerState<CardSortHeader> createState() => _CardSortHeaderState();
}

class _CardSortHeaderState extends ConsumerState<CardSortHeader> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final searchNotifier$ =
            ref.read(cardSearchNotifierProvider(screen: widget.searchScreen, cardSearch: widget.cardSearch).notifier);

        List<Filter> sortingOptions = searchNotifier$.sortingOptions();
        if (widget.searchScreen == 'deck-edit') sortingOptions = searchNotifier$.sortingDeckOptions();
        if (widget.searchScreen == 'vault-view') sortingOptions = searchNotifier$.sortingVaultOptions();

        bool sortingOrder = searchNotifier$.isAscending();
        if ((widget.searchScreen == 'deck-edit' || widget.searchScreen == 'vault-view') && widget.isAscending != null) {
          sortingOrder = widget.isAscending!;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 4,
              child: widget.showSortDropdown
                  ? Row(
                      children: [
                        const Icon(
                          Symbols.sort,
                          size: 22,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Ink(
                          width: 80,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: const BorderRadius.all(Radius.circular(20))),
                          child: DropdownButtonFormField<String>(
                              value: (widget.searchScreen != 'deck-edit' && widget.searchScreen != 'vault-view')
                                  ? searchNotifier$.orderBy()
                                  : widget.sortedBy,
                              isExpanded: true,
                              iconSize: 0,
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  constraints: BoxConstraints(maxHeight: 40),
                                  focusColor: Colors.transparent),
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              onChanged: (String? value) {
                                if (widget.searchScreen != 'deck-edit' && widget.searchScreen != 'vault-view') {
                                  searchNotifier$.updateOrderBy(value);
                                } else {
                                  if (widget.sortBy != null) {
                                    widget.sortBy!(by: value);
                                  }
                                }
                              },
                              items: [
                                for (var i = 0; i < sortingOptions.length; i++)
                                  DropdownMenuItem<String>(
                                    value: sortingOptions[i].value,
                                    child: Text(
                                      sortingOptions[i].label,
                                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                                      maxLines: 1,
                                    ),
                                  )
                              ]),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        SizedBox(
                          height: 32,
                          child: IconButton(
                            onPressed: () {
                              if (widget.searchScreen != 'deck-edit' && widget.searchScreen != 'vault-view') {
                                searchNotifier$.updateIsAscending();
                              } else {
                                if (widget.sortOrder != null) {
                                  widget.sortOrder!(isAscending: widget.isAscending!);
                                }
                              }
                            },
                            iconSize: 20.0,
                            padding: const EdgeInsets.only(bottom: 1, left: 6, right: 6),
                            constraints: const BoxConstraints(),
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            ),
                            icon: sortingOrder
                                ? Icon(Symbols.arrow_upward, color: Theme.of(context).colorScheme.onSurface)
                                : Icon(Symbols.arrow_downward, color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      children: [],
                    ),
            ),
            if (widget.showLabelDropdown)
              Flexible(
                flex: 3,
                child: Row(
                  children: [
                    const Icon(
                      Symbols.remove_red_eye,
                      size: 22,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Ink(
                      width: 80,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.all(Radius.circular(20))),
                      child: DropdownButtonFormField<String>(
                          value: searchNotifier$.view(),
                          isExpanded: true,
                          iconSize: 0,
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              constraints: BoxConstraints(maxHeight: 32),
                              focusColor: Colors.transparent),
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          onChanged: (value) => searchNotifier$.updateView(value),
                          items: [
                            for (var i = 0; i < searchNotifier$.viewingOptions().length; i++)
                              DropdownMenuItem<String>(
                                value: searchNotifier$.viewingOptions()[i].value,
                                child: Text(searchNotifier$.viewingOptions()[i].label,
                                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                                    maxLines: 1),
                              )
                          ]),
                    ),
                  ],
                ),
              ),
            if (widget.showOwnedDropdown)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Symbols.star,
                    size: 22,
                  ),
                  SizedBox(
                    height: 24,
                    child: Switch(
                      value: searchNotifier$.showOwned(),
                      onChanged: searchNotifier$.updateShowOwned,
                    ),
                  )
                ],
              )
          ],
        );
      },
    );
  }
}
