import 'package:flutter/material.dart';
import '/data/repositories/journeys_repository.dart';
import '/backend/supabase/supabase.dart';

class JourneysListViewModel extends ChangeNotifier {
  final JourneysRepository _repository;
  final String currentUserUid;

  JourneysListViewModel({
    required JourneysRepository repository,
    required this.currentUserUid,
  }) : _repository = repository {
    loadData();
  }

  // ========== STATE ==========

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CcViewUserJourneysRow> _userJourneys = [];
  List<CcViewUserJourneysRow> get userJourneys => _userJourneys;

  List<CcViewAvailJourneysRow> _availableJourneys = [];
  List<CcViewAvailJourneysRow> get availableJourneys => _availableJourneys;

  // ========== COMMANDS ==========

  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      // Load both lists in parallel
      final results = await Future.wait([
        _repository.getUserJourneys(currentUserUid),
        _repository.getAvailableJourneys(currentUserUid),
      ]);

      _userJourneys = results[0] as List<CcViewUserJourneysRow>;
      _availableJourneys = results[1] as List<CcViewAvailJourneysRow>;

      notifyListeners();
    } catch (e) {
      _setError('Error loading journeys: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== HELPER METHODS ==========

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
