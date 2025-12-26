import 'package:flutter/material.dart';

import '/data/repositories/community_repository.dart';
import '/data/services/supabase/supabase.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityRepository _repository;
  final String currentUserUid;

  CommunityViewModel({
    required CommunityRepository repository,
    required this.currentUserUid,
  }) : _repository = repository {
    _init();
  }

  /// Stream de experiências aprovadas visíveis para todos
  Stream<List<CcViewSharingsUsersRow>>? sharingsListSupabaseStream;

  /// Stream das experiências do próprio usuário (inclui pending, changes_requested)
  Stream<List<CcViewSharingsUsersRow>>? myExperiencesStream;

  List<CcEventsRow> listEvents = [];
  List<CcEventsRow> listRealEventsUpcomming = [];
  List<CcEventsRow> listRealEventsRecorded = [];
  List<CcEventsRow> listRealEventsTab = [];

  List<CcGroupsRow> myGroups = [];
  List<CcGroupsRow> availableGroups = [];

  void _init() {
    _refreshStreams();
  }

  /// Recria os streams para forçar atualização dos dados
  /// Útil quando navegando de volta para a página após edições
  void _refreshStreams() {
    sharingsListSupabaseStream = _repository.getSharingsStream(currentUserId: currentUserUid);
    myExperiencesStream = _repository.getMyExperiencesStream(currentUserUid);
  }

  /// Força refresh dos sharings (recria o stream)
  void refreshSharings() {
    _refreshStreams();
    notifyListeners();
  }

  Future<void> fetchEvents(String type) async {
    if (type == 'upcomming') {
      listRealEventsUpcomming = await _repository.getEvents(currentUserUid);
      listEvents = listRealEventsUpcomming;
    } else if (type == 'recorded') {
      listRealEventsRecorded = await _repository.getEvents(currentUserUid);
      listEvents = listRealEventsRecorded;
    } else {
      listRealEventsTab = await _repository.getEvents(currentUserUid);
      listEvents = listRealEventsTab;
    }
    notifyListeners();
  }

  Future<void> refreshGroupsList() async {
    await Future.wait([
      Future(() async {
        availableGroups = await _repository.getAvailableGroups(currentUserUid);
      }),
      Future(() async {
        myGroups = await _repository.getMyGroups(currentUserUid);
      }),
    ]);
    notifyListeners();
  }

  Future<void> deleteSharing(BuildContext context, int? id) async {
    if (id == null) return;
    await _repository.deleteSharing(id);
    // Notify UI or show snackbar here if needed, but ideally UI logic should be in View
    // For now, we just perform the action.
  }

  Future<void> onTabChanged(int index) async {
    if (index == 0) {
      // Refresh sharings when returning to Experiences tab
      refreshSharings();
    } else if (index == 1) {
      await refreshGroupsList();
    } else if (index == 2) {
      await fetchEvents('tab');
    }
  }
}
