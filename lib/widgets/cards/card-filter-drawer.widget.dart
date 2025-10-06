import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:rift/main.dart';

import 'package:rift/providers/set.provider.dart';
import 'package:rift/providers/filter.provider.dart';
import 'package:rift/providers/card-search.provider.dart';

import 'package:rift/models/filter.model.dart';
import 'package:rift/models/card-search.model.dart';

import 'package:rift/widgets/auth/signin-button.widget.dart';
import 'package:rift/widgets/misc/subheader.widget.dart';

import 'package:rift/helpers/analytics.helper.dart';

class CardFilterDrawer extends ConsumerStatefulWidget {
  const CardFilterDrawer({super.key, required this.searchScreen, required this.cardSearch});

  final String searchScreen;
  final CardSearch cardSearch;

  @override
  ConsumerState<CardFilterDrawer> createState() => _CardFilterDrawerState();
}

class _CardFilterDrawerState extends ConsumerState<CardFilterDrawer> {
  Session? session = supabase.auth.currentSession;
  late final StreamSubscription<AuthState> _authStateSubscription;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        session = data.session;
      });
    });
  }

  void _applyFilters(WidgetRef ref) {
    ref
        .watch(cardSearchNotifierProvider(screen: widget.searchScreen, cardSearch: widget.cardSearch).notifier)
        .search(refresh: true);

    logEvent(name: 'card_search');
    Scaffold.of(context).closeEndDrawer();
  }

  void _clearFilters(WidgetRef ref) {
    ref
        .watch(cardSearchNotifierProvider(screen: widget.searchScreen, cardSearch: widget.cardSearch).notifier)
        .clearFilters();
    _nameController.clear();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sets$ = ref.read(setsProvider);
    final filters$ = ref.read(filtersProvider);
    final searchNotifier$ = ref.watch(
      cardSearchNotifierProvider(screen: widget.searchScreen, cardSearch: widget.cardSearch).notifier,
    );

    if (searchNotifier$.name() != null) {
      _nameController.text = searchNotifier$.name()!;
    }

    Iterable<List<Filter>> rarityChunks = [];
    Iterable<List<Filter>> languageChunks = [];
    Iterable<List<Filter>> colorChunks = [];
    Iterable<List<Filter>> domainChunks = [];
    Iterable<List<Filter>> typeChunks = [];
    Iterable<List<Filter>> artChunks = [];
    List<Filter> energyOptions = [];
    List<Filter> mightOptions = [];
    List<Filter> powerOptions = [];
    List<Filter> tagOptions = [];
    Iterable<List<Filter>> effectChunks = [];

    if (filters$.value != null) {
      rarityChunks = filters$.value!.rarity.slices(2);
      languageChunks = filters$.value!.language.slices(2);
      colorChunks = filters$.value!.color.slices(2);
      domainChunks = filters$.value!.domain.slices(2);
      typeChunks = filters$.value!.type.slices(2);
      artChunks = filters$.value!.art.slices(2);
      energyOptions = filters$.value!.energy;
      powerOptions = filters$.value!.power;
      mightOptions = filters$.value!.might;
      tagOptions = filters$.value!.tag;
      effectChunks = filters$.value!.effect.slices(1);
    }

    return Drawer(
      child: SafeArea(
        child:
            sets$.value != null && filters$.value != null
                ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Column(
                                      children: [
                                        if (session != null)
                                          Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4, right: 4),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                        searchNotifier$.collection()
                                                            ? Theme.of(context).colorScheme.primary
                                                            : Theme.of(context).colorScheme.outline,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(24),
                                                  color:
                                                      searchNotifier$.collection()
                                                          ? Theme.of(context).colorScheme.primaryContainer
                                                          : Colors.transparent,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Show Collection",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 16,
                                                        color:
                                                            searchNotifier$.collection()
                                                                ? Theme.of(context).colorScheme.primary
                                                                : Theme.of(context).colorScheme.outline,
                                                      ),
                                                    ),
                                                    Switch(
                                                      value: searchNotifier$.collection(),
                                                      onChanged: (value) {
                                                        if (searchNotifier$.showCollectionDisabled()) return;
                                                        searchNotifier$.updateCollection(value);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (searchNotifier$.showCollectionDisabled())
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 2),
                                                  child: Text(
                                                    "Switching collection is disabled",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context).colorScheme.error,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 16),
                                            ],
                                          ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: "Card ID / Name / Keyword"),
                                            const SizedBox(height: 6),
                                            TextFormField(
                                              // initialValue: searchNotifier$.name(),
                                              controller: _nameController,
                                              keyboardType: TextInputType.visiblePassword,
                                              decoration: InputDecoration(
                                                hintText: 'Card ID/Name/Keyword',
                                                suffixIcon: IconButton(
                                                  onPressed: () {
                                                    searchNotifier$.updateName(null);
                                                    _nameController.clear();
                                                  },
                                                  icon: const Icon(Symbols.clear),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Theme.of(context).colorScheme.outline,
                                                    width: 1,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Theme.of(context).colorScheme.outline,
                                                    width: 1,
                                                  ),
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(
                                                  vertical: 8.0,
                                                  horizontal: 10.0,
                                                ),
                                              ),
                                              onChanged: (newValue) => searchNotifier$.updateName(newValue),
                                              onSaved: (value) {},
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: "Set"),
                                            const SizedBox(height: 6),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4.0),
                                                border: Border.all(
                                                  color: Theme.of(context).colorScheme.outline,
                                                  style: BorderStyle.solid,
                                                  width: 1,
                                                ),
                                              ),
                                              child: DropdownButtonFormField<String>(
                                                value: searchNotifier$.setId(),
                                                isExpanded: true,
                                                decoration: const InputDecoration(border: InputBorder.none),
                                                onChanged: (String? value) => searchNotifier$.updateSetId(value),
                                                onSaved: (value) {},
                                                items: [
                                                  const DropdownMenuItem<String>(value: null, child: Text("All Sets")),
                                                  for (var i = 0; i < sets$.value!.length; i++)
                                                    DropdownMenuItem<String>(
                                                      value: sets$.value![i].id.toString(),
                                                      child: Text(
                                                        sets$.value![i].name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: "Rarity"),
                                            const SizedBox(height: 6),
                                            for (var chunk in rarityChunks)
                                              Row(
                                                children: [
                                                  for (var i = 0; i < chunk.length; i++)
                                                    Expanded(
                                                      child: ListTileTheme(
                                                        horizontalTitleGap: 4,
                                                        child: CheckboxListTile(
                                                          visualDensity: const VisualDensity(
                                                            horizontal: 0,
                                                            vertical: -4,
                                                          ),
                                                          contentPadding: EdgeInsets.zero,
                                                          controlAffinity: ListTileControlAffinity.leading,
                                                          title: Text(chunk[i].label),
                                                          value: searchNotifier$.hasFilter('rarity', chunk[i].value),
                                                          onChanged:
                                                              (!searchNotifier$.isDisabled('rarity', chunk[i].value)
                                                                  ? (bool? newValue) =>
                                                                      searchNotifier$.updateRarity(chunk[i].value)
                                                                  : null),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: "Language"),
                                            const SizedBox(height: 6),
                                            for (var chunk in languageChunks)
                                              Row(
                                                children: [
                                                  for (var i = 0; i < chunk.length; i++)
                                                    Expanded(
                                                      flex: 1,
                                                      child:
                                                          chunk[i].value != '-'
                                                              ? ListTileTheme(
                                                                horizontalTitleGap: 4,
                                                                child: CheckboxListTile(
                                                                  visualDensity: const VisualDensity(
                                                                    horizontal: 0,
                                                                    vertical: -4,
                                                                  ),
                                                                  contentPadding: EdgeInsets.zero,
                                                                  controlAffinity: ListTileControlAffinity.leading,
                                                                  title: Text(chunk[i].label),
                                                                  value: searchNotifier$.hasFilter(
                                                                    'language',
                                                                    chunk[i].value,
                                                                  ),
                                                                  onChanged:
                                                                      (!searchNotifier$.isDisabled(
                                                                            'language',
                                                                            chunk[i].value,
                                                                          )
                                                                          ? (bool? newValue) => searchNotifier$
                                                                              .updateLanguage(chunk[i].value)
                                                                          : null),
                                                                ),
                                                              )
                                                              : const SizedBox(height: 0),
                                                    ),
                                                ],
                                              ),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: "Color"),
                                            if (searchNotifier$.showColorRequired())
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2),
                                                child: Text(
                                                  "Leave one color checked",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context).colorScheme.error,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 6),
                                            for (var chunk in colorChunks)
                                              Row(
                                                children: [
                                                  for (var i = 0; i < chunk.length; i++)
                                                    Expanded(
                                                      child: ListTileTheme(
                                                        horizontalTitleGap: 4,
                                                        child: CheckboxListTile(
                                                          visualDensity: const VisualDensity(
                                                            horizontal: 0,
                                                            vertical: -4,
                                                          ),
                                                          contentPadding: EdgeInsets.zero,
                                                          controlAffinity: ListTileControlAffinity.leading,
                                                          title: Text(chunk[i].label),
                                                          value: searchNotifier$.hasFilter('color', chunk[i].value),
                                                          onChanged:
                                                              !searchNotifier$.isDisabled('color', chunk[i].value)
                                                                  ? (bool? newValue) =>
                                                                      searchNotifier$.updateColor(chunk[i].value)
                                                                  : null,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: "Type"),
                                            if (searchNotifier$.showTypeRequired())
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2),
                                                child: Text(
                                                  "Leave one type checked",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context).colorScheme.error,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 6),
                                            for (var chunk in typeChunks)
                                              Row(
                                                children: [
                                                  for (var i = 0; i < chunk.length; i++)
                                                    Expanded(
                                                      child: ListTileTheme(
                                                        horizontalTitleGap: 4,
                                                        child: CheckboxListTile(
                                                          visualDensity: const VisualDensity(
                                                            horizontal: 0,
                                                            vertical: -4,
                                                          ),
                                                          contentPadding: EdgeInsets.zero,
                                                          controlAffinity: ListTileControlAffinity.leading,
                                                          title: Text(chunk[i].label),
                                                          value: searchNotifier$.hasFilter('type', chunk[i].value),
                                                          onChanged:
                                                              !searchNotifier$.isDisabled('type', chunk[i].value)
                                                                  ? (bool? newValue) =>
                                                                      searchNotifier$.updateType(chunk[i].value)
                                                                  : null,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Subheader(text: "Art"),
                                            const SizedBox(height: 6),
                                            for (var chunk in artChunks)
                                              Row(
                                                children: [
                                                  for (var i = 0; i < chunk.length; i++)
                                                    Expanded(
                                                      child: ListTileTheme(
                                                        horizontalTitleGap: 4,
                                                        child: CheckboxListTile(
                                                          visualDensity: const VisualDensity(
                                                            horizontal: 0,
                                                            vertical: -4,
                                                          ),
                                                          contentPadding: EdgeInsets.zero,
                                                          controlAffinity: ListTileControlAffinity.leading,
                                                          title: Text(chunk[i].label),
                                                          value: searchNotifier$.hasFilter('art', chunk[i].value),
                                                          onChanged:
                                                              (!searchNotifier$.isDisabled('art', chunk[i].value)
                                                                  ? (bool? newValue) =>
                                                                      searchNotifier$.updateArt(chunk[i].value)
                                                                  : null),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Column(
                                          children: [
                                            Column(
                                              children: [
                                                const SizedBox(height: 16),
                                                Text(
                                                  'More Filters'.toUpperCase(),
                                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                                ),
                                                const SizedBox(height: 12),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    text: 'Energy ('.toUpperCase(),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                      color: Theme.of(context).colorScheme.secondary,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: NumberFormat(
                                                          '#,###,###',
                                                        ).format(searchNotifier$.energy()[0]),
                                                      ),
                                                      if (searchNotifier$.energy()[0] != searchNotifier$.energy()[1])
                                                        TextSpan(
                                                          text:
                                                              " - ${NumberFormat('#,###,###').format(searchNotifier$.energy()[1])}",
                                                        ),
                                                      const TextSpan(text: ")"),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                SfRangeSlider(
                                                  min: int.parse(energyOptions.first.value),
                                                  max: int.parse(energyOptions.last.value),
                                                  interval: 1,
                                                  stepSize: 1,
                                                  showTicks: true,
                                                  showLabels: true,
                                                  enableTooltip: true,
                                                  values: SfRangeValues(
                                                    searchNotifier$.energy()[0],
                                                    searchNotifier$.energy()[1],
                                                  ),
                                                  onChanged: (SfRangeValues value) => searchNotifier$.updateEnergy(value),
                                                ),
                                                const SizedBox(height: 16),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    text: 'Might ('.toUpperCase(),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                      color: Theme.of(context).colorScheme.secondary,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: NumberFormat(
                                                          '#######',
                                                        ).format(searchNotifier$.might()[0]),
                                                      ),
                                                      if (searchNotifier$.might()[0] !=
                                                          searchNotifier$.might()[1])
                                                        TextSpan(
                                                          text:
                                                              " - ${NumberFormat('#######').format(searchNotifier$.might()[1])}",
                                                        ),
                                                      const TextSpan(text: ")"),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                SfRangeSlider(
                                                  min: int.parse(mightOptions.first.value),
                                                  max: int.parse(mightOptions.last.value),
                                                  interval: 5000,
                                                  stepSize: 5000,
                                                  showTicks: true,
                                                  showLabels: true,
                                                  enableTooltip: true,
                                                  values: SfRangeValues(
                                                    searchNotifier$.might()[0],
                                                    searchNotifier$.might()[1],
                                                  ),
                                                  onChanged:
                                                      (SfRangeValues value) => searchNotifier$.updateMight(value),
                                                ),
                                                const SizedBox(height: 16),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    text: 'Power ('.toUpperCase(),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                      color: Theme.of(context).colorScheme.secondary,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: NumberFormat(
                                                          '#######',
                                                        ).format(searchNotifier$.power()[0]),
                                                      ),
                                                      if (searchNotifier$.power()[0] != searchNotifier$.power()[1])
                                                        TextSpan(
                                                          text:
                                                              " - ${NumberFormat('#######').format(searchNotifier$.power()[1])}",
                                                        ),
                                                      const TextSpan(text: ")"),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                SfRangeSlider(
                                                  min: int.parse(powerOptions.first.value),
                                                  max: int.parse(powerOptions.last.value),
                                                  interval: 55000,
                                                  stepSize: 5000,
                                                  showTicks: true,
                                                  showLabels: true,
                                                  enableTooltip: true,
                                                  values: SfRangeValues(
                                                    searchNotifier$.power()[0],
                                                    searchNotifier$.power()[1],
                                                  ),
                                                  onChanged:
                                                      (SfRangeValues value) => searchNotifier$.updatePower(value),
                                                ),
                                                const SizedBox(height: 16),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Subheader(text: "Tag"),
                                                const SizedBox(height: 6),
                                                Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(4.0),
                                                    border: Border.all(
                                                      color: Theme.of(context).colorScheme.outline,
                                                      style: BorderStyle.solid,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: DropdownButtonFormField<String>(
                                                    value: searchNotifier$.tag(),
                                                    isExpanded: true,
                                                    decoration: const InputDecoration(border: InputBorder.none),
                                                    onChanged:
                                                        (String? value) => searchNotifier$.updateTag(value),
                                                    onSaved: (value) {},
                                                    items: [
                                                      const DropdownMenuItem<String>(
                                                        value: null,
                                                        child: Text("All Attributes"),
                                                      ),
                                                      for (var i = 0; i < tagOptions.length; i++)
                                                        DropdownMenuItem<String>(
                                                          value: tagOptions[i].value,
                                                          child: Text(tagOptions[i].label),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Subheader(text: "Effect"),
                                                const SizedBox(height: 6),
                                                for (var chunk in effectChunks)
                                                  Row(
                                                    children: [
                                                      for (var i = 0; i < chunk.length; i++)
                                                        Expanded(
                                                          child: ListTileTheme(
                                                            horizontalTitleGap: 4,
                                                            child: CheckboxListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: 0,
                                                                vertical: -4,
                                                              ),
                                                              contentPadding: EdgeInsets.zero,
                                                              controlAffinity: ListTileControlAffinity.leading,
                                                              title: Text(chunk[i].label),
                                                              value: searchNotifier$.hasFilter(
                                                                'effect',
                                                                chunk[i].value,
                                                              ),
                                                              onChanged:
                                                                  (!searchNotifier$.isDisabled('effect', chunk[i].value)
                                                                      ? (bool? newValue) {
                                                                        searchNotifier$.updateEffect(chunk[i].value);
                                                                      }
                                                                      : null),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                const SizedBox(height: 6),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (session == null)
                                        Positioned.fill(top: 0, left: 0, child: Container(color: Colors.black54)),
                                      if (session == null)
                                        const Positioned.fill(top: 0, left: 0, child: SigninButton()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: TextButton.icon(
                                      onPressed: () => _clearFilters(ref),
                                      icon: Icon(
                                        Symbols.refresh,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      label: Text(
                                        'Reset',
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: ElevatedButton.icon(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
                                      ),
                                      onPressed: () => _applyFilters(ref),
                                      icon: Icon(
                                        Symbols.search,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                      label: Text(
                                        'Search',
                                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
