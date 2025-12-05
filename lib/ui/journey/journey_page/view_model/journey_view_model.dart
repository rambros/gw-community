import 'package:flutter/material.dart';
import '/data/repositories/journeys_repository.dart';
import '/data/services/supabase/supabase.dart';

class JourneyViewModel extends ChangeNotifier {
  final JourneysRepository _repository;
  final String currentUserUid;
  final int journeyId;
  List<int> _startedJourneys;

  JourneyViewModel({
    required JourneysRepository repository,
    required this.currentUserUid,
    required this.journeyId,
    required List<int> startedJourneys,
  })  : _repository = repository,
        _startedJourneys = List<int>.from(startedJourneys) {
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

  bool get isJourneyStarted => _startedJourneys.contains(journeyId);

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
        final steps = results[1] as List<CcViewUserStepsRow>;
        
        // Remove duplicates based on step ID using a Map
        final stepsMap = <int, CcViewUserStepsRow>{};
        for (final step in steps) {
          final stepId = step.id;
          if (stepId != null && !stepsMap.containsKey(stepId)) {
            stepsMap[stepId] = step;
          }
        }
        _userSteps = stepsMap.values.toList()
          ..sort((a, b) => (a.stepNumber ?? 0).compareTo(b.stepNumber ?? 0));
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
    _setLoading(true);
    try {
      await _repository.startJourney(currentUserUid, journeyId);

      if (!_startedJourneys.contains(journeyId)) {
        _startedJourneys = [..._startedJourneys, journeyId];
        await _repository.updateUserStartedJourneys(currentUserUid, _startedJourneys);
        onUpdateStartedJourneys(_startedJourneys);
        notifyListeners();
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
    } finally {
      _setLoading(false);
    }
  }

  bool canNavigateToStep(CcViewUserStepsRow step, int stepIndex) {
    if (step.stepStatus == 'completed') {
      return true;
    }

    if (step.stepStatus == 'open') {
      // Encontra o índice do primeiro step 'open' (step atual)
      final currentStepIndex = _userSteps.indexWhere((s) => s.stepStatus == 'open');

      // Só o step atual (primeiro open) pode ser acessado
      if (stepIndex != currentStepIndex) return false;

      // First step is always accessible
      if (step.stepNumber == 1) return true;

      // Get configuration from user journey (comes from cc_journeys via VIEW)
      final enableDateControl = _userJourney?.enableDateControl ?? true;
      final daysToWait = _userJourney?.daysToWaitBetweenSteps ?? 1;

      // If date control is disabled, current open step is accessible
      if (!enableDateControl) return true;

      // If date control is enabled, check if enough days have passed
      return step.dateStarted != null &&
             DateTime.now().difference(step.dateStarted!).inDays >= daysToWait;
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
