import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:rift/routes/config.dart';

import 'package:rift/models/vault.model.dart';
import 'package:rift/models/card.model.dart';
import 'package:rift/models/card-search.model.dart';

import 'package:rift/providers/vault.provider.dart';
import 'package:rift/providers/vaults.provider.dart';
import 'package:rift/providers/card-search.provider.dart';

import 'package:rift/helpers/vault.helper.dart';
import 'package:rift/helpers/util.helper.dart';
import 'package:rift/helpers/analytics.helper.dart';
import 'package:rift/helpers/revenuecat.helper.dart';
import 'package:rift/helpers/card.helper.dart';

import 'package:rift/widgets/vaults/vault-drawer.widget.dart';
import 'package:rift/widgets/cards/card-grid.widget.dart';
import 'package:rift/widgets/cards/card-sort-header.widget.dart';
import 'package:rift/widgets/misc/titlecase.widget.dart';
import 'package:rift/widgets/ads/ad-banner.widget.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key, required this.slug, required this.name, required this.color});

  final String slug;
  final String name;
  final String color;

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isEditingName = false;

  final _searchScreen = 'vault-view';
  final CardSearch _cardSearch = CardSearch(
    cards: [],
    cardBatches: [],
    status: CardSearchStatus(
      isInitializing: false,
      isLoading: false,
      hasReachedLimit: true,
      showOwned: false,
      view: 'name',
      orderBy: 'set',
      isAscending: false,
      showCollectionDisabled: false,
      showTypeRequired: false,
      showColorRequired: false,
      selectLeader: false,
      addToDeck: false,
      addToDeckSelect: false,
      addToVault: true,
    ),
    filters: CardSearchFilters(
      collection: false,
      name: null,
      setId: null,
      rarity: [],
      language: [],
      type: [],
      color: [],
      domain: [],
      art: [],
      energy: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_ENERGY_RESET']!)),
      might: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_MIGHT_RESET']!)),
      power: List<int>.from(json.decode(dotenv.env['CARD_SEARCH_POWER_RESET']!)),
      tag: null,
      effect: [],
      asc: null,
      desc: null,
    ),
    config: CardSearchConfig(
      disableCollection: false,
      disableRarity: const [],
      disableType: const [],
      disableColor: const [],
      initialResetColor: const [],
      initialResetType: const [],
      initialResetRarity: const [],
      requireOneType: false,
      requireOneColor: false,
    ),
    symbol: null,
  );

  bool _isUploadingPhoto = false;

  bool _isPro = bool.parse(dotenv.env['IS_PRO']!);

  @override
  void initState() {
    _scrollController.addListener(() {
      _loadMore(ref);
    });

    _nameController.text = widget.name;

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final isSubscribed = checkIfSubscribed(customerInfo);
      if (isSubscribed) setState(() => _isPro = isSubscribed);
    });

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleNameForm() {
    setState(() {
      _isEditingName = !_isEditingName;
    });
  }

  void _updateName(WidgetRef ref) {
    _formKey.currentState!.save();
    if (_nameController.text == '') {
      return;
    }

    ref.read(vaultBuildNotifierProvider(widget.slug).notifier).updateName(_nameController.text);
    ref.read(vaultListNotifierProvider.notifier).patchName(widget.slug, _nameController.text);
    ref.read(vaultListNotifierProvider.notifier).updateUpdatedAt(widget.slug);

    _toggleNameForm();
  }

  void _goToVaultForm(WidgetRef ref, String slug) async {
    Config.router.navigateTo(context, '/vaults/form?slug=$slug');
  }

  Future<void> _showDeleteDialog(Vault vault, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const SingleChildScrollView(
            child: ListBody(children: <Widget>[Text('You are about to delete this vault.')]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () {
                _deleteVault(vault, ref);
              },
            ),
          ],
        );
      },
    );
  }

  void _pickPhoto(Vault vault, WidgetRef ref) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Take a Photo'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Select from Gallery'),
            ),
          ],
        );
      },
    );

    if (source == null) {
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source, imageQuality: 85, maxHeight: 300, maxWidth: 300);

    if (file != null) {
      setState(() => _isUploadingPhoto = true);
      final String filetype = file.path.split('.').last;
      final imageFile = File(file.path);
      List<int> imageBytes = imageFile.readAsBytesSync();
      String base64 = base64Encode(imageBytes);

      final response = await updatePhoto(vault.slug, base64, filetype);
      response.fold(
        (l) {
          ref.read(vaultBuildNotifierProvider(widget.slug).notifier).updatePhoto(l['photo']);
          ref.read(vaultListNotifierProvider.notifier).updatePhoto(widget.slug, l['photo']);

          setState(() => _isUploadingPhoto = false);
          logEvent(name: 'vault_upload_photo');
        },
        (r) {
          // TODO error handling
          setState(() => _isUploadingPhoto = false);
        },
      );
    }
  }

  void _deleteVault(Vault vault, WidgetRef ref) async {
    ref.read(vaultListNotifierProvider.notifier).remove(vault.slug);
    logEvent(name: 'vault_delete', parameters: {'method': 'popmenu button'});
    showSnackbar('${vault.name} deleted');

    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _goToAddCards(Vault vault) async {
    await Config.router.navigateTo(context, '/vaults/add-cards?slug=${vault.slug}');
  }

  void _loadMore(WidgetRef ref) {
    final screenffset = _scrollController.position.maxScrollExtent - _scrollController.position.pixels;
    final vault$ = ref.watch(vaultBuildNotifierProvider(widget.slug));
    if (screenffset < 100 && vault$ != null) {
      ref
          .watch(vaultBuildNotifierProvider(widget.slug).notifier)
          .searchCards(refresh: false, offset: vault$.cards.length, limit: 24);
    }
  }

  void _sortBy({required String? by}) {
    if (by == null) return;

    ref.read(vaultBuildNotifierProvider(widget.slug).notifier).updateSortBy(by);
    _updateSorting();
  }

  void _sortOrder({required bool isAscending}) {
    ref.read(vaultBuildNotifierProvider(widget.slug).notifier).updateIsAscending(isAscending);
    _updateSorting();
  }

  Future<void> _updateSorting() async {
    ref.watch(vaultBuildNotifierProvider(widget.slug).notifier).updateIsInitializing(true);

    final vault = ref.watch(vaultBuildNotifierProvider(widget.slug))!;
    final response = await updateSortingVault(vault.sortBy!, vault.isSortAscending!, widget.slug);
    response.fold((l) {
      logEvent(
        name: 'deck_cards_sort',
        parameters: {'sort': vault.sortBy!, 'by': vault.isSortAscending! ? 'asc' : 'desc'},
      );
      ref.watch(vaultBuildNotifierProvider(widget.slug).notifier).searchCards(refresh: true);
    }, (r) {});
  }

  @override
  Widget build(BuildContext context) {
    final vault$ = ref.watch(vaultBuildNotifierProvider(widget.slug));

    Color backgroundColor = Theme.of(context).colorScheme.primary;
    Color foregroundColor = Theme.of(context).colorScheme.onPrimary;
    backgroundColor = Color(int.parse(widget.color));
    foregroundColor = backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    if (vault$ == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_nameController.text),
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          elevation: 1,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _cardSearch.symbol = vault$.symbol;
    ref.watch(cardSearchNotifierProvider(screen: _searchScreen, cardSearch: _cardSearch));
    final cardBatches = createCardBatches(vault$.cards);

    _nameController.text = vault$.name;
    backgroundColor = Color(int.parse(vault$.color!));
    foregroundColor = backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title:
            !_isEditingName
                ? GestureDetector(onTap: _toggleNameForm, child: Text(vault$.name))
                : Form(
                  key: _formKey,
                  child: TextFormField(
                    autofocus: true,
                    controller: _nameController,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_ ]"))],
                    style: TextStyle(color: foregroundColor),
                    decoration: InputDecoration(
                      hintText: 'Name',
                      counterText: '',
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: foregroundColor, width: 1)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: foregroundColor, width: 1)),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    ),
                    maxLength: 32,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                    onSaved: (value) {},
                  ),
                ),
        elevation: 1,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        actions: [
          if (_isEditingName)
            TextButton(
              onPressed: () {
                _updateName(ref);
              },
              child: Text("Save", style: TextStyle(color: foregroundColor)),
            ),
          if (!_isEditingName)
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Symbols.attach_money),
                  onPressed: () {
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              },
            ),
          if (!_isEditingName)
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(Symbols.edit_square, size: 18, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        const Text('Edit Vault'),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(Symbols.delete, size: 18, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        const Text('Delete Vault'),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  _goToVaultForm(ref, vault$.slug);
                }
                if (value == 1) {
                  _showDeleteDialog(vault$, ref);
                }
              },
            ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) {
            return;
          }
          if (context.mounted) {
            Navigator.pop(context, {'type': 'update', 'name': vault$.name, 'color': vault$.color});
          }
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            MultiSliver(
              children: [
                if (!vault$.isInitializing) ...[
                  ListTile(
                    leading: Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _pickPhoto(vault$, ref),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.grey[400]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child:
                                  vault$.photo != null
                                      ? Container(
                                        color: Colors.grey,
                                        child: FittedBox(fit: BoxFit.cover, child: Image.network(vault$.photo!)),
                                      )
                                      : const Center(child: Icon(Symbols.image, color: Colors.white)),
                            ),
                          ),
                        ),
                        if (_isUploadingPhoto) const Positioned.fill(child: CircularProgressIndicator()),
                      ],
                    ),
                    title: TitleCase(
                      text: vault$.type == 'other' && vault$.other != null ? vault$.other! : vault$.type,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${ref.read(vaultBuildNotifierProvider(widget.slug).notifier).totalCards()} Cards, ${vault$.cards.length} Unique',
                    ),
                  ),
                  for (int i = 0; i < cardBatches.length; i++) ...[
                    CardGrid(
                      cards: cardBatches[i],
                      searchScreen: _searchScreen,
                      cardSearch: _cardSearch,
                      showVaultInfo: true,
                      columns: 3,
                      vault: vault$,
                    ),
                    if (!_isPro &&
                        (i == 0 || cardBatches[i].length >= int.parse(dotenv.env['AD_BANNER_CARDS_PER_AD']!)))
                      const Padding(padding: EdgeInsets.symmetric(vertical: 2), child: Center(child: AdBanner())),
                  ],
                  if (!vault$.hasReachedLimit && vault$.cards.isNotEmpty)
                    const SliverPadding(
                      padding: EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                    ),
                  if (vault$.cards.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: const Text('No cards yet', style: TextStyle(fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                if (vault$.isInitializing) const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              ],
            ),
          ],
        ),
      ),
      endDrawer: VaultDrawer(slug: widget.slug),
      persistentFooterButtons: [
        CardSortHeader(
          searchScreen: _searchScreen,
          cardSearch: _cardSearch,
          showSortDropdown: true,
          showOwnedDropdown: false,
          sortedBy: vault$.sortBy!,
          sortBy: _sortBy,
          isAscending: vault$.isSortAscending!,
          sortOrder: _sortOrder,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _goToAddCards(vault$);
        },
        backgroundColor: backgroundColor,
        child: Icon(Symbols.add, color: foregroundColor),
      ),
    );
  }
}
