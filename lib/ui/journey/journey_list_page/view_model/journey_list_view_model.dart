import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class JourneyListViewModel extends ChangeNotifier {
  final JourneysRepository _repository;
  final String currentUserUid;

  JourneyListViewModel({
    required JourneysRepository repository,
    required this.currentUserUid,
  }) : _repository = repository {
    _init();
  }

  List<CcViewUserJourneysRow> myJourneysProgress = [];
  List<CcJourneysRow> availableJourneys = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    await refreshJourneysList();

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh both journey lists
  Future<void> refreshJourneysList() async {
    await Future.wait([
      Future(() async {
        // Get progress data for my journeys (includes all journey info + progress)
        // Filter by user ID only - we'll filter by journey publication status later

        // Get all user journeys from the view (no filter on journey_status)
        final allUserJourneys = await CcViewUserJourneysTable().queryRows(
          queryFn: (q) => q.eq('user_id', currentUserUid),
        );

        // Now filter on the client side: we need journeys where the actual journey is Published
        // Since the view doesn't expose cc_journeys.status, we'll query it separately
        final publishedJourneyIds = <int>{};
        if (allUserJourneys.isNotEmpty) {
          final journeyIds = allUserJourneys.map((j) => j.journeyId).where((id) => id != null).cast<int>().toList();
          if (journeyIds.isNotEmpty) {
            final publishedJourneys = await CcJourneysTable().queryRows(
              queryFn: (q) => q.inFilter('id', journeyIds).inFilter('status', ['published', 'Published']),
            );
            publishedJourneyIds.addAll(publishedJourneys.map((j) => j.id));
          }
        }

        // Filter to only include published journeys
        myJourneysProgress = allUserJourneys.where((j) => publishedJourneyIds.contains(j.journeyId)).toList();

        // Recalculate steps completed for each journey (removing duplicates)
        await _recalculateStepsCompleted();
      }),
      Future(() async {
        availableJourneys = await _repository.getAvailableJourneysForList(currentUserUid);
      }),
    ]);
    notifyListeners();
  }

  /// Recalculate steps completed for all journeys, removing duplicates
  /// Updates the stepsCompleted field directly on each progress object
  Future<void> _recalculateStepsCompleted() async {
    for (final progress in myJourneysProgress) {
      final journeyId = progress.journeyId;

      if (journeyId == null) {
        continue;
      }

      // Get ALL user steps first to check statuses
      final allUserSteps = await CcViewUserStepsTable().queryRows(
        queryFn: (q) => q.eq('user_id', currentUserUid).eq('journey_id', journeyId),
      );

      // Filter completed steps (case insensitive)
      final completedSteps = allUserSteps.where((step) {
        final status = step.stepStatus?.toLowerCase().trim();
        return status == 'completed';
      }).toList();

      // Remove duplicates by journey_step_id
      final uniqueSteps = <int>{};
      for (final step in completedSteps) {
        if (step.journeyStepId != null) {
          uniqueSteps.add(step.journeyStepId!);
        }
      }

      // Update the progress object directly
      progress.stepsCompleted = uniqueSteps.length;
    }
  }
}
