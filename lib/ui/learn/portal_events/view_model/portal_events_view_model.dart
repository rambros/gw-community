import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/learn_repository.dart';
import 'package:gw_community/data/repositories/portal_event_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/app_localizations.dart';
import 'package:gw_community/l10n/l10n_format.dart';
import 'package:gw_community/ui/learn/widgets/portal_list_sort.dart';

class PortalEventsViewModel extends ChangeNotifier {
  PortalEventsViewModel({
    required this.dashboardGroupId,
    PortalEventRepository? repository,
    LearnRepository? learnRepository,
  })  : _repository = repository ?? PortalEventRepository(),
        _learnRepository = learnRepository ?? LearnRepository();

  final int dashboardGroupId;
  final PortalEventRepository _repository;
  final LearnRepository _learnRepository;

  final _sortedEvents = PortalSortedList<ViewEventsRow>(
    titleOf: (item) => item.eventName ?? '',
    dateOf: (item) => item.start,
  );
  List<ViewEventsRow> get events => _sortedEvents.items;
  PortalListSort get sort => _sortedEvents.sort;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  bool _isFilterActive = false;
  bool get isFilterActive => _isFilterActive;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _filterByYear = '';
  String get filterByYear => _filterByYear;

  int _filterByLocationId = 0;
  int get filterByLocationId => _filterByLocationId;

  int _filterByEventTypeId = 0;
  int get filterByEventTypeId => _filterByEventTypeId;

  void setSort(PortalListSort sort) {
    if (!_sortedEvents.setSort(sort)) return;
    notifyListeners();
  }

  List<YearsWithContentRow> _years = [];
  List<YearsWithContentRow> get years => _years;

  List<LocalWithEventRow> _locations = [];
  List<LocalWithEventRow> get locations => _locations;

  List<EventTypeRow> _eventTypes = [];
  List<EventTypeRow> get eventTypes => _eventTypes
      .where((type) => type.dashboardGroupId == null || type.dashboardGroupId == dashboardGroupId)
      .toList();

  Future<void> init() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadEvents(),
        _loadYears(),
        _loadLocations(),
        _loadEventTypes(),
      ]);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadEvents() async {
    _sortedEvents.replace(await _repository.getAll(dashboardGroupId: dashboardGroupId));
  }

  Future<void> _loadYears() async {
    try {
      _years = await _learnRepository.getYears();
    } catch (e) {
      debugPrint('Error loading years: $e');
    }
  }

  Future<void> _loadLocations() async {
    try {
      _locations = await _learnRepository.getLocations();
    } catch (e) {
      debugPrint('Error loading locations: $e');
    }
  }

  Future<void> _loadEventTypes() async {
    try {
      _eventTypes = await _learnRepository.getEventTypes();
    } catch (e) {
      debugPrint('Error loading event types: $e');
    }
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
    _sortedEvents.setSort(PortalListSort.relevance);

    try {
      _sortedEvents.replace(
        await _repository.search(
          searchString: query,
          dashboardGroupId: dashboardGroupId,
        ),
      );
    } catch (e) {
      debugPrint('Error searching portal events: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> applyFilters({
    String? year,
    int? locationId,
    int? eventTypeId,
  }) async {
    _setLoading(true);
    if (year != null) _filterByYear = year;
    if (locationId != null) _filterByLocationId = locationId;
    if (eventTypeId != null) _filterByEventTypeId = eventTypeId;

    _isFilterActive =
        _filterByYear.trim().isNotEmpty || _filterByLocationId != 0 || _filterByEventTypeId != 0;
    _isSearchActive = false;
    _searchQuery = '';
    if (_sortedEvents.sort.isRelevance) {
      _sortedEvents.setSort(PortalListSort.dateNewest);
    }

    try {
      if (_isFilterActive) {
        _sortedEvents.replace(
          await _repository.filter(
            dashboardGroupId: dashboardGroupId,
            year: _filterByYear,
            locationId: _filterByLocationId,
            eventTypeId: _filterByEventTypeId,
          ),
        );
      } else {
        await _loadEvents();
      }
    } catch (e) {
      debugPrint('Error filtering portal events: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearchActive = false;
    if (_sortedEvents.sort.isRelevance) {
      _sortedEvents.setSort(PortalListSort.dateNewest);
    }
    if (_isFilterActive) {
      applyFilters();
    } else {
      _reload();
    }
  }

  void clearFilters() {
    _filterByYear = '';
    _filterByLocationId = 0;
    _filterByEventTypeId = 0;
    _isFilterActive = false;
    if (_isSearchActive) {
      search(_searchQuery);
    } else {
      _reload();
    }
  }

  Future<void> _reload() async {
    _setLoading(true);
    try {
      await _loadEvents();
    } finally {
      _setLoading(false);
    }
  }

  String localizedFilterDescription(AppLocalizations l10n) {
    if (_isSearchActive && _searchQuery.isNotEmpty) {
      return l10n.filteredBySearch(_searchQuery);
    }
    return libraryActiveFiltersDescription(
      l10n: l10n,
      year: _filterByYear.trim().isEmpty ? null : _filterByYear,
      location: _filterByLocationId == 0
          ? null
          : _locations.where((item) => item.id == _filterByLocationId).firstOrNull?.local,
      eventType: _filterByEventTypeId == 0
          ? null
          : eventTypes.where((item) => item.id == _filterByEventTypeId).firstOrNull?.name,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
