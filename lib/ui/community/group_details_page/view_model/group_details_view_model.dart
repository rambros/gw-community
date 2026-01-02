import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/event_repository.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/repositories/notification_repository.dart';
import 'package:gw_community/data/repositories/sharing_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class GroupDetailsViewModel extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final SharingRepository _sharingRepository;
  final EventRepository _eventRepository;
  final NotificationRepository _notificationRepository;
  final CcGroupsRow group;
  final String? currentUserId;

  GroupDetailsViewModel(
    this._groupRepository,
    this._sharingRepository,
    this._eventRepository,
    this._notificationRepository,
    this.group, {
    this.currentUserId,
  });

  TabController? tabController;
  TickerProvider? _vsync;
  bool _isMember = false;
  bool get isMember => _isMember;
  bool _isJoining = false;
  bool get isJoining => _isJoining;
  bool _isCheckingMembership = true;
  bool get isCheckingMembership => _isCheckingMembership;

  // Streams
  Stream<List<CcViewSharingsUsersRow>>? _sharingsStream;
  Stream<List<CcEventsRow>>? _eventsStream;
  Stream<List<CcViewNotificationsUsersRow>>? _notificationsStream;

  // Data for About tab
  List<CcMembersRow> _members = [];
  List<CcMembersRow> get members => _members;
  bool _isLoadingMembers = false;
  bool get isLoadingMembers => _isLoadingMembers;

  Stream<List<CcViewSharingsUsersRow>> get sharingsStream {
    _sharingsStream ??= _sharingRepository.getSharingsStream(group.id, currentUserId: currentUserId);
    return _sharingsStream!;
  }

  Stream<List<CcEventsRow>> get eventsStream {
    _eventsStream ??= _eventRepository.getEventsStream(group.id);
    return _eventsStream!;
  }

  Stream<List<CcViewNotificationsUsersRow>> get notificationsStream {
    _notificationsStream ??= _notificationRepository.getNotificationsStream(group.id);
    return _notificationsStream!;
  }

  void init(TickerProvider vsync) {
    _vsync = vsync;
    // Inicialização síncrona obrigatória antes do check async
    _updateTabController();
    _checkMembership();
    _fetchMembers();
  }

  Future<void> _checkMembership() async {
    if (currentUserId == null || currentUserId!.isEmpty) {
      _isMember = false;
      _isCheckingMembership = false;
      _updateTabController();
      notifyListeners();
      return;
    }

    try {
      _isMember = await _groupRepository.isUserMemberOfGroup(group.id, currentUserId!);
    } finally {
      _isCheckingMembership = false;
      _updateTabController();
      notifyListeners();
    }
  }

  void _updateTabController() {
    if (_vsync == null) return;

    final int targetLength = shouldShowOnlyAbout ? 1 : 4;

    // Se o controller já existe e o tamanho é o mesmo, não faz nada
    if (tabController != null && tabController!.length == targetLength) return;

    final oldIndex = tabController != null ? tabController!.index : 0;

    final oldController = tabController;

    tabController = TabController(
      length: targetLength,
      vsync: _vsync!,
      initialIndex: shouldShowOnlyAbout ? 0 : (oldIndex < targetLength ? oldIndex : 0),
    );

    oldController?.removeListener(_onTabChanged);
    oldController?.dispose();

    tabController?.addListener(_onTabChanged);
  }

  // Define se deve mostrar apenas a aba About
  bool get shouldShowOnlyAbout => group.groupPrivacy == 'Public' && !_isMember;

  Future<void> joinGroup() async {
    if (currentUserId == null) return;

    _isJoining = true;
    notifyListeners();

    try {
      await _groupRepository.joinGroup(group.id, currentUserId!);
      _isMember = true;
      _updateTabController();
      _fetchMembers(); // Refresh members list
      notifyListeners();
    } catch (e) {
      debugPrint('Error joining group: $e');
    } finally {
      _isJoining = false;
      notifyListeners();
    }
  }

  void _onTabChanged() {
    notifyListeners();
  }

  Future<void> _fetchMembers() async {
    _isLoadingMembers = true;
    notifyListeners();
    try {
      _members = await _groupRepository.getGroupMembersAsUsers(group.id);
    } catch (e) {
      debugPrint('Error fetching members: $e');
    } finally {
      _isLoadingMembers = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    tabController?.removeListener(_onTabChanged);
    tabController?.dispose();
    super.dispose();
  }

  Future<void> deleteSharing(int id) async {
    await _sharingRepository.deleteSharing(id);
  }

  Future<void> deleteEvent(int id) async {
    await _eventRepository.deleteEvent(id);
  }

  Future<void> deleteNotification(int id) async {
    await _notificationRepository.deleteNotification(id);
  }
}
