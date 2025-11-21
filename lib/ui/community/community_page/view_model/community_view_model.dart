import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';
import '/data/repositories/community_repository.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityRepository _repository;
  final String currentUserUid;

  CommunityViewModel({
    required CommunityRepository repository,
    required this.currentUserUid,
  }) : _repository = repository {
    _init();
  }

  Stream<List<CcViewSharingsUsersRow>>? sharingsListSupabaseStream;
  List<CcEventsRow> listEvents = [];
  List<CcEventsRow> listRealEventsUpcomming = [];
  List<CcEventsRow> listRealEventsRecorded = [];
  List<CcEventsRow> listRealEventsTab = [];

  List<CcGroupsRow> myGroups = [];
  List<CcGroupsRow> availableGroups = [];

  void _init() {
    sharingsListSupabaseStream = _repository.getSharingsStream();
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
    if (index == 1) {
      await refreshGroupsList();
    } else if (index == 2) {
      await fetchEvents('tab');
    }
  }
}
