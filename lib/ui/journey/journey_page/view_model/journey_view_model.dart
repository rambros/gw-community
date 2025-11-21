import 'package:flutter/material.dart';
import '/data/repositories/journeys_repository.dart';
import '/data/services/supabase/supabase.dart';

class JourneyViewModel extends ChangeNotifier {
  final JourneysRepository _repository;
  final String currentUserUid;
  final int journeyId;
  final List<int> startedJourneys;

  JourneyViewModel({
    required JourneysRepository repository,
    required this.currentUserUid,
    required this.journeyId,
    required this.startedJourneys,
  }) : _repository = repository {
    loadJourneyData();
  }

  // ========== STATE ==========

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CcJourneysRow? _journey;
  CcJourneysRow? get journey => _journey;

  CcViewUserJourneysRow? _userJourney;
  CcViewUserJourneysRow? get userJourney => _userJourney;

  List<CcViewUserStepsRow> _userSteps = [];
  List<CcViewUserStepsRow> get userSteps => _userSteps;

  bool get isJourneyStarted => startedJourneys.contains(journeyId);

  // ========== COMMANDS ==========

  Future<void> loadJourneyData() async {
    _setLoading(true);
    _clearError();

    try {
      if (isJourneyStarted) {
        // Load user journey and steps
        final results = await Future.wait([
          _repository.getUserJourney(currentUserUid, journeyId),
          _repository.getUserSteps(currentUserUid, journeyId),
        ]);

        _userJourney = results[0] as CcViewUserJourneysRow?;
        _userSteps = results[1] as List<CcViewUserStepsRow>;
      } else {
        // Load journey info
        _journey = await _repository.getJourneyById(journeyId);
      }

      notifyListeners();
    } catch (e) {
      _setError('Error loading journey: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startJourneyCommand(
    BuildContext context,
    Function(List<int>) onUpdateStartedJourneys,
  ) async {
    try {
      await _repository.startJourney(currentUserUid, journeyId);

      if (!startedJourneys.contains(journeyId)) {
        final updatedList = [...startedJourneys, journeyId];
        await _repository.updateUserStartedJourneys(currentUserUid, updatedList);
        onUpdateStartedJourneys(updatedList);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journey started'),
            duration: Duration(milliseconds: 4000),
          ),
        );
      }

      // Reload data to show started journey
      await loadJourneyData();
    } catch (e) {
      _setError('Error starting journey: $e');
    }
  }

  bool canNavigateToStep(CcViewUserStepsRow step, int stepIndex) {
    if (step.stepStatus == 'open') {
      // First step or step that started more than 1 day ago
      return step.stepNumber == 1 ||
          (step.dateStarted != null && DateTime.now().difference(step.dateStarted!).inDays >= 1);
    } else if (step.stepStatus == 'completed') {
      return true;
    }
    return false;
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
