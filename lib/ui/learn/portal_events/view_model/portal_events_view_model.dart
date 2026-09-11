import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/portal_event_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class PortalEventsViewModel extends ChangeNotifier {
  PortalEventsViewModel({
    required this.dashboardGroupId,
    PortalEventRepository? repository,
  }) : _repository = repository ?? PortalEventRepository();

  final int dashboardGroupId;
  final PortalEventRepository _repository;

  List<ViewEventsRow> _events = [];
  List<ViewEventsRow> get events => _events;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Future<void> init() async {
    _setLoading(true);
    try {
      _events = await _repository.getAll(dashboardGroupId: dashboardGroupId);
    } catch (e) {
      debugPrint('Error loading portal events: $e');
    } finally {
      _setLoading(false);
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

    try {
      _events = await _repository.search(
        searchString: query,
        dashboardGroupId: dashboardGroupId,
      );
    } catch (e) {
      debugPrint('Error searching portal events: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearchActive = false;
    init();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
