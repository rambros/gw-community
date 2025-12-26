import 'package:flutter/material.dart';
import '/data/repositories/support_repository.dart';
import '/data/services/supabase/supabase.dart';

enum SupportFilter { all, open, resolved }

class SupportViewModel extends ChangeNotifier {
  final SupportRepository _repository;

  SupportViewModel({
    required SupportRepository repository,
  }) : _repository = repository {
    _init();
  }

  Stream<List<CcSupportRequestsRow>>? requestsStream;
  SupportFilter _currentFilter = SupportFilter.all;
  bool _isLoading = false;
  String? _errorMessage;

  SupportFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _init() {
    requestsStream = _repository.watchMyRequests();
  }

  void setFilter(SupportFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  List<CcSupportRequestsRow> filterRequests(List<CcSupportRequestsRow> requests) {
    switch (_currentFilter) {
      case SupportFilter.all:
        return requests;
      case SupportFilter.open:
        return requests.where((r) => r.status != 'resolved').toList();
      case SupportFilter.resolved:
        return requests.where((r) => r.status == 'resolved').toList();
    }
  }

  Future<bool> deleteRequest(int requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.deleteRequest(requestId);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete request: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void refresh() {
    requestsStream = _repository.watchMyRequests();
    notifyListeners();
  }
}
