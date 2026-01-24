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

  List<CcJourneysRow> myJourneys = [];
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
        myJourneys = await _repository.getMyJourneys(currentUserUid);
        // Get progress data for my journeys
        myJourneysProgress = await CcViewUserJourneysTable().queryRows(
          queryFn: (q) => q.eq('user_id', currentUserUid),
        );
      }),
      Future(() async {
        availableJourneys = await _repository.getAvailableJourneysForList(currentUserUid);
      }),
    ]);
    notifyListeners();
  }

  /// Get steps completed for a journey
  int? getStepsCompleted(int journeyId) {
    try {
      final progress = myJourneysProgress.firstWhere(
        (p) => p.journeyId == journeyId,
      );
      return progress.stepsCompleted;
    } catch (e) {
      return null;
    }
  }

  /// Get journey status
  String? getJourneyStatus(int journeyId) {
    try {
      final progress = myJourneysProgress.firstWhere(
        (p) => p.journeyId == journeyId,
      );
      return progress.journeyStatus;
    } catch (e) {
      return null;
    }
  }
}
