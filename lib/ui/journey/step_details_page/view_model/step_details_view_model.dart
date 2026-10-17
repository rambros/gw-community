import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/step_activities_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';

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

  bool _isNavigating = false;
  bool get isNavigating => _isNavigating;

  List<CcViewUserActivitiesRow> _activities = [];
  List<CcViewUserActivitiesRow> get activities => _activities;

  // ========== COMMANDS ==========

  Future<void> loadActivities({bool showLoading = true}) async {
    if (showLoading) _setLoading(true);
    _clearError();

    try {
      if (userStepRow.id == null) {
        _setError('Invalid step ID');
        _setLoading(false);
        return;
      }

      // Sync missing activities (for activities added after journey started)
      if (!viewAsBlocksWrite() && userStepRow.journeyStepId != null) {
        await _repository.syncMissingActivities(
          currentUserUid,
          userStepRow.id!,
          userStepRow.journeyStepId!,
        );
      }

      final activities = await _repository.getUserActivities(
        currentUserUid,
        userStepRow.id!,
      );

      // Remove duplicates based on activity ID using a Map
      final activitiesMap = <int, CcViewUserActivitiesRow>{};
      for (final activity in activities) {
        final activityId = activity.id;
        if (activityId != null && !activitiesMap.containsKey(activityId)) {
          activitiesMap[activityId] = activity;
        }
      }
      _activities = activitiesMap.values.toList()
        ..sort((a, b) {
          final order = (a.orderInStep ?? 0).compareTo(b.orderInStep ?? 0);
          if (order != 0) return order;
          return (a.stepActivityId ?? a.id ?? 0)
              .compareTo(b.stepActivityId ?? b.id ?? 0);
        });

      final userJourneyId = userStepRow.userJourneyId;
      if (!viewAsBlocksWrite() &&
          userStepRow.id != null &&
          userJourneyId != null) {
        await _repository.advanceStepIfRequiredActivitiesDone(
          userId: currentUserUid,
          userStepId: userStepRow.id!,
          userJourneyId: userJourneyId,
        );
      }

      notifyListeners();
    } catch (e, stackTrace) {
      _setError('Error loading activities: $e\n$stackTrace');
    } finally {
      if (showLoading) _setLoading(false);
    }
  }

  Future<void> handleActivityTap(
    BuildContext context,
    CcViewUserActivitiesRow activity,
    Function(String, Map<String, dynamic>) navigateToActivity,
  ) async {
    if (_isNavigating) return;
    _isNavigating = true;
    notifyListeners();

    // Abre a atividade na hora. A conclusão segue sem segurar a transição.
    _navigateToActivityPage(activity, navigateToActivity);

    if (!viewAsBlocksWrite() && activity.activityStatus != 'completed') {
      try {
        await _repository.completeActivity(activity.id!);
        // Reload also advances the step when every required activity is done.
        await loadActivities(showLoading: false);
      } catch (e) {
        _setError('Error completing activity: $e');
      }
    }

    _isNavigating = false;
    notifyListeners();
  }

  void _navigateToActivityPage(
    CcViewUserActivitiesRow activity,
    Function(String, Map<String, dynamic>) navigateToActivity,
  ) {
    if (activity.activityType == 'audio') {
      navigateToActivity('stepAudioPlayerPage', {
        'stepAudioUrl': activity.audioUrl,
        'audioTitle': activity.activityPrompt,
        'audioArt':
            'https://firebasestorage.googleapis.com/v0/b/good-wishes-project.appspot.com/o/images%2Fic_goodwishes.png?alt=media&token=e441f239-c823-468b-bff7-c16be921c7be',
        'typeStep': activity.activityLabel,
        'activityId': activity.stepActivityId,
        if (activity.transcript != null && activity.transcript!.isNotEmpty)
          'transcript': activity.transcript,
        'animationUrl': activity.animationUrl,
        'animationMediaType': activity.animationMediaType,
      });
    } else if (activity.activityType == 'text') {
      navigateToActivity('stepTextViewPage', {
        'stepTextTitle': activity.activityPrompt,
        'stepTextContent': activity.text,
        'activityId': activity.stepActivityId,
        'activityLabel': activity.activityLabel,
      });
    } else if (activity.activityType == 'image') {
      navigateToActivity('stepImagePage', {
        'activityRow': activity,
      });
    } else if (activity.activityType == 'pdf') {
      navigateToActivity('stepPdfPage', {
        'activityRow': activity,
      });
    } else if (activity.activityType == 'video') {
      navigateToActivity('stepVideoPlayerPage', {
        'videoUrl': activity.videoUrl,
        'videoTitle': activity.activityPrompt,
        'typeStep': activity.activityLabel,
        'activityId': activity.stepActivityId,
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
