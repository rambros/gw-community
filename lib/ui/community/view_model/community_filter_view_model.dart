import 'package:flutter/material.dart';

/// ViewModel for managing community filter state.
///
/// Centralizes all filter-related state that was previously in FFAppState.
class CommunityFilterViewModel extends ChangeNotifier {
  String _typeSelectedEvent = 'upcomming';
  bool _filterOn = false;
  int _filterByAuthorId = 0;
  String _filterByYear = '';
  int _filterByLocalID = 0;
  String _filterLine = '';
  List<String> _filterByTopics = [];
  int _filterByEventId = 0;
  int _filterByJourneyId = 0;
  int _filterByGroupId = 0;
  // Getters
  String get typeSelectedEvent => _typeSelectedEvent;
  bool get filterOn => _filterOn;
  int get filterByAuthorId => _filterByAuthorId;
  String get filterByYear => _filterByYear;
  int get filterByLocalID => _filterByLocalID;
  String get filterLine => _filterLine;
  List<String> get filterByTopics => List.unmodifiable(_filterByTopics);
  int get filterByEventId => _filterByEventId;
  int get filterByJourneyId => _filterByJourneyId;
  int get filterByGroupId => _filterByGroupId;
  // Setters
  void setTypeSelectedEvent(String value) {
    _typeSelectedEvent = value;
    notifyListeners();
  }

  void setFilterOn(bool value) {
    _filterOn = value;
    notifyListeners();
  }

  void setFilterByAuthorId(int value) {
    _filterByAuthorId = value;
    notifyListeners();
  }

  void setFilterByYear(String value) {
    _filterByYear = value;
    notifyListeners();
  }

  void setFilterByLocalID(int value) {
    _filterByLocalID = value;
    notifyListeners();
  }

  void setFilterLine(String value) {
    _filterLine = value;
    notifyListeners();
  }

  void setFilterByEventId(int value) {
    _filterByEventId = value;
    notifyListeners();
  }

  void setFilterByJourneyId(int value) {
    _filterByJourneyId = value;
    notifyListeners();
  }

  void setFilterByGroupId(int value) {
    _filterByGroupId = value;
    notifyListeners();
  }

  // Topic list management
  void addToFilterByTopics(String value) {
    _filterByTopics.add(value);
    notifyListeners();
  }

  void removeFromFilterByTopics(String value) {
    _filterByTopics.remove(value);
    notifyListeners();
  }

  void removeAtIndexFromFilterByTopics(int index) {
    _filterByTopics.removeAt(index);
    notifyListeners();
  }

  void updateFilterByTopicsAtIndex(int index, String Function(String) updateFn) {
    _filterByTopics[index] = updateFn(_filterByTopics[index]);
    notifyListeners();
  }

  void insertAtIndexInFilterByTopics(int index, String value) {
    _filterByTopics.insert(index, value);
    notifyListeners();
  }

  /// Resets all filters to their default values.
  void resetFilters() {
    _typeSelectedEvent = 'upcomming';
    _filterOn = false;
    _filterByAuthorId = 0;
    _filterByYear = '';
    _filterByLocalID = 0;
    _filterLine = '';
    _filterByTopics = [];
    _filterByEventId = 0;
    _filterByJourneyId = 0;
    _filterByGroupId = 0;
    notifyListeners();
  }
}
