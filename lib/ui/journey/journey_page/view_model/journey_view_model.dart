import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

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

  List<CcJourneyStepsRow> _journeySteps = [];
  List<CcJourneyStepsRow> get journeySteps => _journeySteps;

  bool get isJourneyStarted => _userJourney != null || _startedJourneys.contains(journeyId);

  // ========== COMMANDS ==========

  Future<void> loadJourneyData() async {
    _setLoading(true);
    _clearError();

    try {
      // Always load base journey info (static content like title, description)
      _journey = await _repository.getJourneyById(journeyId);

      // Always check if user has started this journey (from database, not just app state)
      _userJourney = await _repository.getUserJourney(currentUserUid, journeyId);

      if (_userJourney != null) {
        // Journey has been started - load user steps
        final steps = await _repository.getUserSteps(currentUserUid, journeyId);

        // Remove duplicates based on journey_step_id using a Map
        // Keep the most recent user_step for each journey_step
        final stepsMap = <int, CcViewUserStepsRow>{};
        for (final step in steps) {
          final journeyStepId = step.journeyStepId;
          if (journeyStepId != null) {
            final existing = stepsMap[journeyStepId];
            // Keep the most recent step (higher id means more recent)
            if (existing == null || (step.id != null && existing.id != null && step.id! > existing.id!)) {
              stepsMap[journeyStepId] = step;
            }
          }
        }
        _userSteps = stepsMap.values.toList()..sort((a, b) => (a.stepNumber ?? 0).compareTo(b.stepNumber ?? 0));

        // Sync app state if needed
        if (!_startedJourneys.contains(journeyId)) {
          _startedJourneys = [..._startedJourneys, journeyId];
        }
      } else {
        // Journey hasn't been started - load generic journey steps
        _journeySteps = await _repository.getJourneySteps(journeyId);

        // Clean up app state if needed
        if (_startedJourneys.contains(journeyId)) {
          _startedJourneys = _startedJourneys.where((id) => id != journeyId).toList();
        }
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
      // Check if journey is already started (from database)
      final existingUserJourney = await _repository.getUserJourney(currentUserUid, journeyId);

      if (existingUserJourney != null) {
        // Journey already started, just reload data and sync state
        await loadJourneyData();

        if (!_startedJourneys.contains(journeyId)) {
          _startedJourneys = [..._startedJourneys, journeyId];
          await _repository.updateUserStartedJourneys(currentUserUid, _startedJourneys);
          onUpdateStartedJourneys(_startedJourneys);
        }
        return;
      }

      // Start the journey
      await _repository.startJourney(currentUserUid, journeyId);

      _startedJourneys = [..._startedJourneys, journeyId];
      await _repository.updateUserStartedJourneys(currentUserUid, _startedJourneys);
      onUpdateStartedJourneys(_startedJourneys);
      notifyListeners();

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

  Future<void> resetJourneyCommand(
    BuildContext context,
    Function(List<int>) onUpdateStartedJourneys,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      // Resetar journey no repositório
      await _repository.resetJourney(currentUserUid, journeyId);

      // Atualizar lista de journeys iniciadas
      final updatedList = _startedJourneys.where((id) => id != journeyId).toList();
      _startedJourneys = updatedList;

      // Atualizar no banco de dados
      await _repository.updateUserStartedJourneys(currentUserUid, updatedList);

      // Notificar caller para atualizar app state
      onUpdateStartedJourneys(updatedList);

      notifyListeners();
    } catch (e) {
      _setError('Error resetting journey: $e');
      rethrow;
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
      return step.dateStarted != null && DateTime.now().difference(step.dateStarted!).inDays >= daysToWait;
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
