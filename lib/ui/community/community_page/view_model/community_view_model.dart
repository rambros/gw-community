import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/community_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityRepository _repository;
  final String currentUserUid;
  String? _memberId;

  CommunityViewModel({
    required CommunityRepository repository,
    required this.currentUserUid,
  }) : _repository = repository {
    _init();
  }

  /// Getter para o memberId (resolvido da cc_members)
  String? get memberId => _memberId;

  /// Stream de experiências aprovadas visíveis para todos
  Stream<List<CcViewSharingsUsersRow>>? sharingsListSupabaseStream;

  /// Stream das experiências do próprio usuário (inclui pending, changes_requested)
  Stream<List<CcViewSharingsUsersRow>>? myExperiencesStream;

  List<CcEventsRow> listEvents = [];
  List<CcEventsRow> listRealEventsUpcoming = [];
  List<CcEventsRow> listRealEventsRecorded = [];
  List<CcEventsRow> listRealEventsTab = [];

  List<CcGroupsRow> myGroups = [];
  List<CcGroupsRow> availableGroups = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    debugPrint('CommunityViewModel._init: starting resolution for $currentUserUid');
    // Primeiro resolvemos o memberId baseado no authUid
    _memberId = await _repository.getMemberIdByAuthUserId(currentUserUid);
    debugPrint('CommunityViewModel._init: memberId resolved to: $_memberId');

    _refreshStreams();

    // Load groups on initialization since Community page only shows Groups tab
    await refreshGroupsList();

    _isLoading = false;
    notifyListeners();
  }

  /// Recria os streams para forçar atualização dos dados
  /// Útil quando navegando de volta para a página após edições
  void _refreshStreams() {
    // Usamos o memberId se disponível, senão fallback para authUid (padrão legado)
    final idToUse = _memberId ?? currentUserUid;
    debugPrint('CommunityViewModel._refreshStreams: using ID: $idToUse');
    sharingsListSupabaseStream = _repository.getSharingsStream(currentUserId: idToUse);
    myExperiencesStream = _repository.getMyExperiencesStream(idToUse);
  }

  /// Força refresh dos sharings (recria o stream)
  Future<void> refreshSharings() async {
    if (_memberId == null) {
      _memberId = await _repository.getMemberIdByAuthUserId(currentUserUid);
      debugPrint('CommunityViewModel.refreshSharings: resolved memberId to: $_memberId');
    }
    _refreshStreams();
    notifyListeners();
  }

  Future<void> fetchEvents(String type) async {
    // Use auth_user_id directly for events as well
    debugPrint('CommunityViewModel.fetchEvents: type=$type, id=$currentUserUid');

    if (type == 'upcoming') {
      listRealEventsUpcoming = await _repository.getEvents(currentUserUid);
      listEvents = listRealEventsUpcoming;
    } else if (type == 'recorded') {
      listRealEventsRecorded = await _repository.getEvents(currentUserUid);
      listEvents = listRealEventsRecorded;
    } else {
      listRealEventsTab = await _repository.getEvents(currentUserUid);
      listEvents = listRealEventsTab;
    }

    debugPrint('CommunityViewModel.fetchEvents: listEvents size=${listEvents.length}');
    notifyListeners();
  }

  Future<void> refreshGroupsList() async {
    // Use auth_user_id directly (cc_group_members.user_id stores auth_user_id, not member.id)
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
