import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/learn_repository.dart';
import 'package:gw_community/data/repositories/portal_meditation_repository.dart';
import 'package:gw_community/data/repositories/portal_message_repository.dart';
import 'package:gw_community/data/services/portal/portal_hybrid_search.dart';
import 'package:gw_community/data/services/portal/portal_year_filter.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/app_localizations.dart';
import 'package:gw_community/l10n/l10n_format.dart';
import 'package:gw_community/ui/learn/portal_catalog/portal_catalog_kind.dart';
import 'package:gw_community/ui/learn/utils/portal_content_mapper.dart';
import 'package:gw_community/ui/learn/widgets/portal_list_sort.dart';

class PortalCatalogViewModel extends ChangeNotifier {
  PortalCatalogViewModel({
    required PortalCatalogKind kind,
    PortalMessageRepository? messageRepository,
    PortalMeditationRepository? meditationRepository,
    LearnRepository? learnRepository,
  })  : _kind = kind,
        _messageRepository = messageRepository ?? PortalMessageRepository(),
        _meditationRepository = meditationRepository ?? PortalMeditationRepository(),
        _learnRepository = learnRepository ?? LearnRepository();

  final PortalCatalogKind _kind;
  final PortalMessageRepository _messageRepository;
  final PortalMeditationRepository _meditationRepository;
  final LearnRepository _learnRepository;

  List<ViewContentRow> _allItems = [];
  final _sortedItems = PortalSortedList<ViewContentRow>(
    titleOf: (item) => item.title ?? '',
    dateOf: (item) => item.datePublished,
  );
  List<ViewContentRow> get items => _sortedItems.items;
  PortalListSort get sort => _sortedItems.sort;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  bool _isFilterActive = false;
  bool get isFilterActive => _isFilterActive;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int _filterByAuthorId = 0;
  String _filterByYear = '';

  List<AuthorWithContentRow> _authors = [];
  List<AuthorWithContentRow> get authors => _authors;

  List<YearsWithContentRow> get years {
    final unique = <int>{};
    for (final item in _allItems) {
      final year = item.yearPublished?.toInt() ?? item.datePublished?.year;
      if (year != null) unique.add(year);
    }
    final sorted = unique.toList()..sort((a, b) => b.compareTo(a));
    return [for (final year in sorted) YearsWithContentRow({'year': year.toDouble()})];
  }

  int get filterByAuthorId => _filterByAuthorId;
  String get filterByYear => _filterByYear;

  void setSort(PortalListSort sort) {
    if (!_sortedItems.setSort(sort)) return;
    notifyListeners();
  }

  Future<void> init() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadAuthors(),
        _loadItems(),
      ]);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadAuthors() async {
    try {
      _authors = await _learnRepository.getAuthors();
    } catch (e) {
      debugPrint('Error loading authors: $e');
    }
  }

  Future<void> _loadItems() async {
    switch (_kind) {
      case PortalCatalogKind.messages:
        _allItems = (await _messageRepository.getAll()).map(viewContentFromMessages).toList();
      case PortalCatalogKind.meditations:
        _allItems = (await _meditationRepository.getAll()).map(viewContentFromMeditations).toList();
      case PortalCatalogKind.dadiJanki:
        _allItems = await _learnRepository.getByAuthorId(LearnRepository.dadiJankiAuthorId);
    }
    _applyLocalFilters();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _setLoading(true);
    _searchQuery = query;
    _isSearchActive = true;
    _isFilterActive = false;
    _sortedItems.setSort(PortalListSort.relevance);

    try {
      switch (_kind) {
        case PortalCatalogKind.messages:
          final hybrid = await PortalHybridSearch.search(
            query: query,
            contentTypeIds: const [3, 4, 5],
          );
          if (hybrid.isNotEmpty) {
            _sortedItems.replace(hybrid.map((r) => r.toViewContentRow()).toList());
          } else {
            _sortedItems.replace(
              (await _messageRepository.textSearch(query)).map(viewContentFromMessages).toList(),
            );
          }
        case PortalCatalogKind.meditations:
          final hybrid = await PortalHybridSearch.search(
            query: query,
            contentTypeIds: const [6, 9],
          );
          if (hybrid.isNotEmpty) {
            _sortedItems.replace(hybrid.map((r) => r.toViewContentRow()).toList());
          } else {
            _sortedItems.replace(
              (await _meditationRepository.textSearch(query)).map(viewContentFromMeditations).toList(),
            );
          }
        case PortalCatalogKind.dadiJanki:
          final hybrid = await PortalHybridSearch.search(
            query: query,
            authorIds: const [LearnRepository.dadiJankiAuthorId],
          );
          if (hybrid.isNotEmpty) {
            _sortedItems.replace(hybrid.map((r) => r.toViewContentRow()).toList());
          } else {
            _sortedItems.replace(
              await _learnRepository.searchContent(
                query,
                filterByAuthorId: LearnRepository.dadiJankiAuthorId,
                useHybridSearch: false,
              ),
            );
          }
      }
    } catch (e) {
      debugPrint('Error searching catalog: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> applyFilters({int? authorId, String? year}) async {
    if (authorId != null) _filterByAuthorId = authorId;
    if (year != null) _filterByYear = year;
    _isFilterActive = _filterByAuthorId != 0 || _filterByYear.trim().isNotEmpty;
    _isSearchActive = false;
    _searchQuery = '';
    if (_sortedItems.sort.isRelevance) {
      _sortedItems.setSort(PortalListSort.dateNewest);
    }

    if (_allItems.isEmpty) {
      _setLoading(true);
      try {
        await _loadItems();
      } finally {
        _setLoading(false);
      }
      return;
    }

    _applyLocalFilters();
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearchActive = false;
    if (_sortedItems.sort.isRelevance) {
      _sortedItems.setSort(PortalListSort.dateNewest);
    }
    _applyLocalFilters();
  }

  void clearFilters() {
    _filterByAuthorId = 0;
    _filterByYear = '';
    _isFilterActive = false;
    if (_isSearchActive) {
      search(_searchQuery);
    } else {
      _applyLocalFilters();
    }
  }

  void _applyLocalFilters() {
    _sortedItems.replace(
      _isFilterActive ? _allItems.where(_matchesFilters).toList() : List.of(_allItems),
    );
    notifyListeners();
  }

  bool _matchesFilters(ViewContentRow item) {
    if (_filterByAuthorId != 0 && !item.authors.contains(_filterByAuthorId)) {
      return false;
    }
    return matchesPublishedYear(
      year: _filterByYear,
      datePublished: item.datePublished,
      yearPublished: item.yearPublished,
    );
  }

  String localizedFilterDescription(AppLocalizations l10n) {
    if (_isSearchActive && _searchQuery.isNotEmpty) {
      return l10n.filteredBySearch(_searchQuery);
    }
    return libraryActiveFiltersDescription(
      l10n: l10n,
      author: _filterByAuthorId == 0
          ? null
          : _authors.where((a) => a.id == _filterByAuthorId).firstOrNull?.name ?? '$_filterByAuthorId',
      year: _filterByYear.trim().isEmpty ? null : _filterByYear,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
