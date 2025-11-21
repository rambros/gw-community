import 'package:flutter/material.dart';
import '/data/repositories/step_activities_repository.dart';
import '/data/services/supabase/supabase.dart';

class StepDetailsViewModel extends ChangeNotifier {
  final StepActivitiesRepository _repository;
  final String currentUserUid;
  final CcViewUserStepsRow userStepRow;

  StepDetailsViewModel({
    required StepActivitiesRepository repository,
    required this.currentUserUid,
    required this.userStepRow,
  }) : _repository = repository {
    loadActivities();
  }

  // ========== STATE ==========

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CcViewUserActivitiesRow> _activities = [];
  List<CcViewUserActivitiesRow> get activities => _activities;

  // ========== COMMANDS ==========

  Future<void> loadActivities() async {
    _setLoading(true);
    _clearError();

    try {
      _activities = await _repository.getUserActivities(
        currentUserUid,
        userStepRow.id!,
      );
      notifyListeners();
    } catch (e) {
      _setError('Error loading activities: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> handleActivityTap(
    BuildContext context,
    CcViewUserActivitiesRow activity,
    Function(String, Map<String, dynamic>) navigateToActivity,
  ) async {
    if (activity.activityStatus != 'completed') {
      try {
        // Complete the activity
        await _repository.completeActivity(activity.id!);

        // Check if all activities are completed
        final openActivities = await _repository.getOpenActivities(
          currentUserUid,
          activity.userStepId!,
        );

        if (openActivities.isEmpty) {
          // Complete the step
          await _repository.completeUserStep(activity.userStepId!);

          // Get closed steps
          final closedSteps = await _repository.getClosedSteps(
            currentUserUid,
            userStepRow.userJourneyId!,
          );

          if (closedSteps.isNotEmpty) {
            // Open next step
            await _repository.openNextStep(closedSteps.first.id!);

            // Update journey progress
            final completedSteps = await _repository.getCompletedSteps(
              currentUserUid,
              userStepRow.userJourneyId!,
            );

            await _repository.updateUserJourney(
              userStepRow.userJourneyId!,
              completedSteps.length,
            );
          } else {
            // Complete the journey
            await _repository.completeUserJourney(userStepRow.userJourneyId!);
          }
        }

        // Reload activities to reflect changes
        await loadActivities();
      } catch (e) {
        _setError('Error completing activity: $e');
      }
    }

    // Navigate based on activity type
    _navigateToActivityPage(activity, navigateToActivity);
  }

  void _navigateToActivityPage(
    CcViewUserActivitiesRow activity,
    Function(String, Map<String, dynamic>) navigateToActivity,
  ) {
    if (activity.activityType == 'audio') {
      navigateToActivity('stepAudioPlayerPage', {
        'stepAudioUrl': activity.audioUrl,
        'audioTitle': activity.activityPrompt,
        'typeAnimation': 'IN',
        'audioArt':
            'https://firebasestorage.googleapis.com/v0/b/good-wishes-project.appspot.com/o/images%2Fic_goodwishes.png?alt=media&token=e441f239-c823-468b-bff7-c16be921c7be',
        'typeStep': activity.activityLabel,
      });
    } else if (activity.activityType == 'text') {
      navigateToActivity('stepTextViewPage', {
        'stepTextTitle': activity.activityPrompt,
        'stepTextContent': activity.text,
      });
    } else {
      navigateToActivity('stepJournalPage', {
        'activityRow': activity,
      });
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
