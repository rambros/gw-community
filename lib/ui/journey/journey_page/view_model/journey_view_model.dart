import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/data/repositories/step_activities_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/models/journey_step_group.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';

class JourneyViewModel extends ChangeNotifier {
  final JourneysRepository _repository;
  final StepActivitiesRepository _stepActivitiesRepository;
  final String currentUserUid;
  final int journeyId;
  List<int> _startedJourneys;

  JourneyViewModel({
    required JourneysRepository repository,
    StepActivitiesRepository? stepActivitiesRepository,
    required this.currentUserUid,
    required this.journeyId,
    required List<int> startedJourneys,
  })  : _repository = repository,
        _stepActivitiesRepository =
            stepActivitiesRepository ?? StepActivitiesRepository(),
        _startedJourneys = List<int>.from(startedJourneys) {
    loadJourneyData();
  }

  // ========== STATE ==========

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDisposed = false;

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

  List<CcJourneySectionsRow> _sections = [];
  List<CcJourneySectionsRow> get sections => _sections;

  bool get hasSectionHeaders => _sections.isNotEmpty;

  List<({int id, String title, int sectionOrder})> get _sectionTuples =>
      _sections
          .map(
            (s) => (
              id: s.id,
              title: s.title,
              sectionOrder: s.sectionOrder,
            ),
          )
          .toList();

  List<JourneyStepGroup<CcViewUserStepsRow>> get groupedUserSteps =>
      groupJourneySteps<CcViewUserStepsRow>(
        steps: _userSteps,
        sections: _sectionTuples,
        sectionIdOf: (step) => step.sectionId,
        stepNumberOf: (step) => step.stepNumber ?? 0,
      );

  List<JourneyStepGroup<CcJourneyStepsRow>> get groupedJourneySteps =>
      groupJourneySteps<CcJourneyStepsRow>(
        steps: _journeySteps,
        sections: _sectionTuples,
        sectionIdOf: (step) => step.sectionId,
        stepNumberOf: (step) => step.stepNumber,
      );

  bool get isJourneyStarted =>
      _userJourney != null || _startedJourneys.contains(journeyId);

  String? get fixedLanguage => _journey?.fixedLanguage;

  // ========== COMMANDS ==========

  Future<void> loadJourneyData({bool skipStepAdvance = false}) async {
    _setLoading(true);
    _clearError();

    try {
      final journeyFuture = _repository.getJourneyById(journeyId);
      final sectionsFuture = _repository.getJourneySections(journeyId);
      final userJourneyFuture =
          _repository.getUserJourney(currentUserUid, journeyId);

      _journey = await journeyFuture;
      _sections = await sectionsFuture;
      _userJourney = await userJourneyFuture;

      if (_userJourney != null) {
        // Journey has been started - load user steps
        var steps = await _repository.getUserSteps(currentUserUid, journeyId);
        if (!skipStepAdvance) {
          final advanced = await _stepActivitiesRepository
              .advanceOpenStepsWhenRequiredActivitiesDone(
            userId: currentUserUid,
            journeyId: journeyId,
          );
          if (advanced) {
            steps = await _repository.getUserSteps(currentUserUid, journeyId);
          }
        }

        // Remove duplicates based on journey_step_id using a Map
        // Keep the most recent user_step for each journey_step
        final stepsMap = <int, CcViewUserStepsRow>{};
        for (final step in steps) {
          final journeyStepId = step.journeyStepId;
          if (journeyStepId != null) {
            final existing = stepsMap[journeyStepId];
            // Keep the most recent step (higher id means more recent)
            if (existing == null ||
                (step.id != null &&
                    existing.id != null &&
                    step.id! > existing.id!)) {
              stepsMap[journeyStepId] = step;
            }
          }
        }
        _userSteps = stepsMap.values.toList()
          ..sort((a, b) => (a.stepNumber ?? 0).compareTo(b.stepNumber ?? 0));

        // Sync app state if needed
        if (!_startedJourneys.contains(journeyId)) {
          _startedJourneys = [..._startedJourneys, journeyId];
        }
      } else {
        // Journey hasn't been started - load generic journey steps
        _journeySteps = await _repository.getJourneySteps(journeyId);

        // Clean up app state if needed
        if (_startedJourneys.contains(journeyId)) {
          _startedJourneys =
              _startedJourneys.where((id) => id != journeyId).toList();
        }
      }

      _notify();
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
    if (viewAsBlocksWrite()) return;
    _setLoading(true);
    try {
      final created = await _repository.startJourney(currentUserUid, journeyId);

      if (!_startedJourneys.contains(journeyId)) {
        _startedJourneys = [..._startedJourneys, journeyId];
      }
      onUpdateStartedJourneys(_startedJourneys);

      await Future.wait([
        _repository.updateUserStartedJourneys(currentUserUid, _startedJourneys),
        loadJourneyData(skipStepAdvance: created),
      ]);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journey started'),
            duration: Duration(milliseconds: 4000),
          ),
        );
      }
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
    if (viewAsBlocksWrite()) return;
    _setLoading(true);
    _clearError();

    try {
      // Resetar journey no repositório
      await _repository.resetJourney(currentUserUid, journeyId);

      // Atualizar lista de journeys iniciadas
      final updatedList =
          _startedJourneys.where((id) => id != journeyId).toList();
      _startedJourneys = updatedList;

      // Atualizar no banco de dados
      await _repository.updateUserStartedJourneys(currentUserUid, updatedList);

      // Notificar caller para atualizar app state
      onUpdateStartedJourneys(updatedList);

      _notify();
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
      final currentStepIndex =
          _userSteps.indexWhere((s) => s.stepStatus == 'open');

      // Só o step atual (primeiro open) pode ser acessado
      if (stepIndex != currentStepIndex) return false;

      // First step in journey order is always accessible
      if (stepIndex == 0) return true;

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

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isDisposed) return;
    _isLoading = value;
    _notify();
  }

  void _setError(String message) {
    if (_isDisposed) return;
    _errorMessage = message;
    _notify();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
