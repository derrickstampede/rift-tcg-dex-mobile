import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rift/models/deck.model.dart';
import 'package:rift/models/note.model.dart';

import 'package:rift/repositories/decks.repository.dart';

import 'package:rift/repositories/decks-repository.provider.dart';

part 'decks.provider.g.dart';

@riverpod
class DeckListNotifier extends _$DeckListNotifier {
  late final DecksRepository decksRepository;

  bool _isFetchedInitially = false;

  @override
  DeckList build() {
    print('build deck list');
    decksRepository = ref.watch(decksRepositoryProvider);
    return DeckList(decks: [], sortBy: 'date_created', isSortAscending: true, isLoading: true);
  }

  Future<void> search({required bool force}) async {
    try {
      if (_isFetchedInitially && !force) return;

      final response = await decksRepository.search();
      _isFetchedInitially = true;
      final DeckList deckList = DeckList(
        decks: response['decks'],
        sortBy: response['sortBy'],
        isSortAscending: response['isSortAscending'],
        isLoading: false,
      );
      update(deckList);

      sort();
    } catch (e) {
      // TODO error handling
      print(e);
    }
  }

  void update(DeckList value) => state = value;

  void sort() {
    List<Deck> decks = state.decks;

    if (state.sortBy == 'name') {
      decks.sort(
        (a, b) =>
            state.isSortAscending
                ? a.name.toUpperCase().compareTo(b.name.toUpperCase())
                : b.name.toUpperCase().compareTo(a.name.toUpperCase()),
      );
    }
    if (state.sortBy == 'legend') {
      decks.sort(
        (a, b) =>
            state.isSortAscending
                ? a.legend.name.toUpperCase().compareTo(b.legend.name.toUpperCase())
                : b.legend.name.toUpperCase().compareTo(a.legend.name.toUpperCase()),
      );
    }
    if (state.sortBy == 'color') {
      decks.sort((a, b) => a.name.compareTo(b.name));
      final red = decks.where((d) => d.legend.color!.split('/')[0] == 'Red');
      final green = decks.where((d) => d.legend.color!.split('/')[0] == 'Green');
      final blue = decks.where((d) => d.legend.color!.split('/')[0] == 'Blue');
      final orange = decks.where((d) => d.legend.color!.split('/')[0] == 'Orange');
      final purple = decks.where((d) => d.legend.color!.split('/')[0] == 'Purple');
      final yellow = decks.where((d) => d.legend.color!.split('/')[0] == 'Yellow');
      if (state.isSortAscending) {
        decks = [...red, ...blue, ...green, ...orange, ...yellow, ...purple];
      } else {
        decks = [...purple, ...yellow, ...orange, ...green, ...blue, ...red];
      }
    }
    if (state.sortBy == 'date_created') {
      decks.sort(
        (a, b) => state.isSortAscending ? a.createdAt.compareTo(b.createdAt) : b.createdAt.compareTo(a.createdAt),
      );
    }
    if (state.sortBy == 'date_updated') {
      decks.sort(
        (a, b) => state.isSortAscending ? a.updatedAt.compareTo(b.updatedAt) : b.updatedAt.compareTo(a.updatedAt),
      );
    }

    final DeckList deckList = DeckList(
      decks: decks,
      sortBy: state.sortBy,
      isSortAscending: state.isSortAscending,
      isLoading: state.isLoading,
    );
    update(deckList);
  }

  void updateSort({String? sortBy, bool? isSortAscending}) {
    String newSortBy = state.sortBy;
    bool newIsSortAscending = state.isSortAscending;

    if (sortBy != null) {
      newSortBy = sortBy;
    }
    if (isSortAscending != null) {
      newIsSortAscending = isSortAscending;
    }

    decksRepository.updateDeckSorting(newSortBy, newIsSortAscending);

    final DeckList deckList = DeckList(
      decks: state.decks,
      sortBy: newSortBy,
      isSortAscending: newIsSortAscending,
      isLoading: state.isLoading,
    );
    update(deckList);

    sort();
  }

  void add(Deck deck) {
    try {
      final decks = state.decks;
      decks.insert(0, deck);

      final DeckList deckList = DeckList(
        decks: decks,
        sortBy: state.sortBy,
        isSortAscending: state.isSortAscending,
        isLoading: state.isLoading,
      );
      update(deckList);

      sort();
    } catch (e) {
      // TODO error handling
      print(e);
    }
  }

  Future<void> patch(String slug, String name) async {
    try {
      final decks = state.decks;
      final index = decks.indexWhere((d) => d.slug == slug);
      decks[index].name = name;

      final DeckList deckList = DeckList(
        decks: decks,
        sortBy: state.sortBy,
        isSortAscending: state.isSortAscending,
        isLoading: state.isLoading,
      );
      update(deckList);

      sort();
    } catch (e) {
      // TODO error handling
      print(e);
    }
  }

  void updateNote(int id, Note? note) {
    final decks = state.decks;
    final index = decks.indexWhere((d) => d.id == id);
    decks[index].note = note;

    final DeckList deckList = DeckList(
      decks: decks,
      sortBy: state.sortBy,
      isSortAscending: state.isSortAscending,
      isLoading: state.isLoading,
    );
    update(deckList);

    sort();
  }

  void updateLeader(String slug, String thumbnail) {
    final decks = state.decks;
    final index = decks.indexWhere((d) => d.slug == slug);
    decks[index].legend.thumbnail = thumbnail;

    final DeckList deckList = DeckList(
      decks: decks,
      sortBy: state.sortBy,
      isSortAscending: state.isSortAscending,
      isLoading: state.isLoading,
    );
    update(deckList);
  }

  void updatePublic(int id, bool isPublic) {
    final decks = state.decks;
    final index = decks.indexWhere((d) => d.id == id);
    decks[index].isPublic = isPublic;

    final DeckList deckList = DeckList(
      decks: decks,
      sortBy: state.sortBy,
      isSortAscending: state.isSortAscending,
      isLoading: state.isLoading,
    );
    update(deckList);

    sort();
  }

  void updateCount(String slug, num count) {
    final decks = state.decks;
    final index = decks.indexWhere((d) => d.slug == slug);
    decks[index].cardCount = count;

    final DeckList deckList = DeckList(
      decks: decks,
      sortBy: state.sortBy,
      isSortAscending: state.isSortAscending,
      isLoading: state.isLoading,
    );
    update(deckList);

    sort();
  }

  void updateUpdatedAt(String slug) {
    final decks = state.decks;
    final index = decks.indexWhere((d) => d.slug == slug);
    decks[index].updatedAt = DateTime.now();

    sort();
  }

  Future<void> remove(String slug) async {
    try {
      final decks = state.decks;
      final index = decks.indexWhere((d) => d.slug == slug);
      decks.removeAt(index);

      final deckList = DeckList(
        decks: decks,
        isLoading: state.isLoading,
        sortBy: state.sortBy,
        isSortAscending: state.isSortAscending,
      );
      update(deckList);

      await decksRepository.delete(slug);
    } catch (e) {
      // TODO error handling
      print(e);
    }
  }

  void reset() {
    final DeckList vaultList = DeckList(
      decks: [],
      sortBy: state.sortBy,
      isSortAscending: state.isSortAscending,
      isLoading: true,
    );
    update(vaultList);
  }
}
