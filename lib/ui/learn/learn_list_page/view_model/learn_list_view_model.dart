import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '/data/services/supabase/supabase.dart';
import '/data/repositories/learn_repository.dart';

class LearnListViewModel extends ChangeNotifier {
  final LearnRepository _repository = LearnRepository();

  List<ViewContentRow> _contentList = [];
  List<ViewContentRow> get contentList => _contentList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  bool _isFilterActive = false;
  bool get isFilterActive => _isFilterActive;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Filters
  int _filterByAuthorId = 0;
  int get filterByAuthorId => _filterByAuthorId;

  String _filterByYear = '';
  String get filterByYear => _filterByYear;

  int _filterByEventId = 0;
  int get filterByEventId => _filterByEventId;

  List<String> _filterByTopics = [];
  List<String> get filterByTopics => _filterByTopics;

  int _filterByJourneyId = 0;
  int get filterByJourneyId => _filterByJourneyId;

  int _filterByGroupId = 0;
  int get filterByGroupId => _filterByGroupId;

  String _filterDescription = 'No filter';
  String get filterDescription => _filterDescription;

  // Filter Options
  List<AuthorWithContentRow> _authors = [];
  List<AuthorWithContentRow> get authors => _authors;

  List<ViewEventsRow> _events = [];
  List<ViewEventsRow> get events => _events;

  List<YearsWithContentRow> _years = [];
  List<YearsWithContentRow> get years => _years;

  List<CcJourneysRow> _journeys = [];
  List<CcJourneysRow> get journeys => _journeys;

  List<CcGroupsRow> _groups = [];
  List<CcGroupsRow> get groups => _groups;

  List<TopicsWithContentRow> _topics = [];
  List<TopicsWithContentRow> get topics => _topics;

  // Pagination
  int _page = 0;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadInitialData() async {
    _setLoading(true);
    _page = 0;
    _hasMore = true;
    _contentList = []; // Clear list on initial load

    // 1. Start fetching filters in the background
    final filtersFuture = Future.wait([
      _loadAuthors(),
      _loadEvents(),
      _loadYears(),
      _loadJourneys(),
      _loadGroups(),
      _loadTopics(),
    ]);

    try {
      // 2. Fetch first page of content
      final newContent = await _repository.getAllContent(
        limit: _pageSize,
        offset: 0,
      );
      _contentList = newContent;
      _hasMore = newContent.length >= _pageSize;
    } catch (e) {
      debugPrint('Error loading content: $e');
    } finally {
      _setLoading(false);
    }

    // 4. Wait for filters to finish
    try {
      await filtersFuture;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading filters: $e');
    }
  }

  Future<void> loadMoreContent() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _page++;
      final offset = _page * _pageSize;

      List<ViewContentRow> newContent;

      if (_isSearchActive) {
        newContent = await _repository.searchContent(
          _searchQuery,
          limit: _pageSize,
          offset: offset,
        );
      } else if (_isFilterActive) {
        newContent = await _repository.filterContent(
          filterByAuthorId: _filterByAuthorId,
          filterByYear: _filterByYear,
          filterByEventId: _filterByEventId,
          filterByTopics: _filterByTopics,
          filterByJourneyId: _filterByJourneyId,
          filterByGroupId: _filterByGroupId,
          limit: _pageSize,
          offset: offset,
        );
      } else {
        newContent = await _repository.getAllContent(
          limit: _pageSize,
          offset: offset,
        );
      }

      if (newContent.isNotEmpty) {
        _contentList.addAll(newContent);
        _hasMore = newContent.length >= _pageSize;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('Error loading more content: $e');
      _page--; // Revert page increment on error
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> _loadAuthors() async {
    try {
      _authors = await _repository.getAuthors();
    } catch (e) {
      debugPrint('Error loading authors: $e');
    }
  }

  Future<void> _loadEvents() async {
    try {
      _events = await _repository.getEvents();
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  Future<void> _loadYears() async {
    try {
      _years = await _repository.getYears();
    } catch (e) {
      debugPrint('Error loading years: $e');
    }
  }

  Future<void> _loadJourneys() async {
    try {
      _journeys = await _repository.getJourneys();
    } catch (e) {
      debugPrint('Error loading journeys: $e');
    }
  }

  Future<void> _loadGroups() async {
    try {
      _groups = await _repository.getGroups();
    } catch (e) {
      debugPrint('Error loading groups: $e');
    }
  }

  Future<void> _loadTopics() async {
    try {
      _topics = await _repository.getTopics();
    } catch (e) {
      debugPrint('Error loading topics: $e');
    }
  }

  Future<void> searchContent(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    _setLoading(true);
    _searchQuery = query;
    _isSearchActive = true;
    _isFilterActive = false; // Search overrides filter display logic in original code
    _filterDescription = 'Filtered by Search Field -> $query';

    // Reset pagination
    _page = 0;
    _hasMore = true;

    try {
      final newContent = await _repository.searchContent(
        query,
        limit: _pageSize,
        offset: 0,
      );
      _contentList = newContent;
      _hasMore = newContent.length >= _pageSize;
    } catch (e) {
      debugPrint('Error searching content: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> applyFilters({
    int? authorId,
    String? year,
    int? eventId,
    List<String>? topics,
    int? journeyId,
    int? groupId,
  }) async {
    _setLoading(true);

    if (authorId != null) _filterByAuthorId = authorId;
    if (year != null) _filterByYear = year;
    if (eventId != null) _filterByEventId = eventId;
    if (topics != null) _filterByTopics = topics;
    if (journeyId != null) _filterByJourneyId = journeyId;
    if (groupId != null) _filterByGroupId = groupId;

    _isSearchActive = false;
    _updateFilterDescription();

    // Reset pagination
    _page = 0;
    _hasMore = true;

    try {
      final newContent = await _repository.filterContent(
        filterByAuthorId: _filterByAuthorId,
        filterByYear: _filterByYear,
        filterByEventId: _filterByEventId,
        filterByTopics: _filterByTopics,
        filterByJourneyId: _filterByJourneyId,
        filterByGroupId: _filterByGroupId,
        limit: _pageSize,
        offset: 0,
      );
      _contentList = newContent;
      _hasMore = newContent.length >= _pageSize;
    } catch (e) {
      debugPrint('Error filtering content: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearchActive = false;
    if (_isFilterActive) {
      // If filter was active, re-apply it? Or just clear everything?
      // Original code: _model.searchOn = false;
      // If we clear search, we might want to go back to full list or filtered list.
      // Let's assume we go back to full list if no filter, or re-apply filter.
      if (_isFilterActive) {
        applyFilters();
      } else {
        loadInitialData();
      }
    } else {
      loadInitialData();
    }
  }

  void clearFilters() {
    _filterByAuthorId = 0;
    _filterByYear = '';
    _filterByEventId = 0;
    _filterByTopics = [];
    _filterByJourneyId = 0;
    _filterByGroupId = 0;
    _isFilterActive = false;
    _filterDescription = 'No filter';

    if (_isSearchActive) {
      searchContent(_searchQuery);
    } else {
      loadInitialData();
    }
  }

  void _updateFilterDescription() {
    final activeFilters = <String>[];

    if (_filterByAuthorId != 0) {
      final authorName = _authors.firstWhereOrNull((author) => author.id == _filterByAuthorId)?.name;
      activeFilters.add('Author: ${authorName ?? _filterByAuthorId}');
    }
    if (_filterByEventId != 0) {
      final eventName = _events.firstWhereOrNull((event) => event.eventId == _filterByEventId)?.eventName;
      activeFilters.add('Event: ${eventName ?? _filterByEventId}');
    }
    if (_filterByYear.trim().isNotEmpty) {
      activeFilters.add('Year: $_filterByYear');
    }
    if (_filterByJourneyId != 0) {
      final journeyTitle = _journeys.firstWhereOrNull((journey) => journey.id == _filterByJourneyId)?.title;
      activeFilters.add('Journey: ${journeyTitle ?? _filterByJourneyId}');
    }
    if (_filterByGroupId != 0) {
      final groupName = _groups.firstWhereOrNull((group) => group.id == _filterByGroupId)?.name;
      activeFilters.add('Group: ${groupName ?? _filterByGroupId}');
    }
    if (_filterByTopics.isNotEmpty) {
      activeFilters.add('Topics: ${_filterByTopics.join(', ')}');
    }

    if (activeFilters.isEmpty) {
      _filterDescription = 'No filter';
      _isFilterActive = false;
    } else {
      _filterDescription = 'Filters \u2192 ${activeFilters.join(' | ')}';
      _isFilterActive = true;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
