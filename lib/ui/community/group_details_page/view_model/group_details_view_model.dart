import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/event_repository.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/repositories/notification_repository.dart';
import 'package:gw_community/data/repositories/sharing_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/data/repositories/learn_repository.dart';

class GroupDetailsViewModel extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final SharingRepository _sharingRepository;
  final EventRepository _eventRepository;
  final NotificationRepository _notificationRepository;
  final JourneysRepository _journeysRepository;
  final LearnRepository _learnRepository;
  CcGroupsRow _group;
  CcGroupsRow get group => _group;
  final String? currentUserId;

  GroupDetailsViewModel(
    this._groupRepository,
    this._sharingRepository,
    this._eventRepository,
    this._notificationRepository,
    this._journeysRepository,
    this._learnRepository,
    CcGroupsRow group, {
    this.currentUserId,
  }) : _group = group;

  TabController? tabController;
  TickerProvider? _vsync;
  bool _isMember = false;
  bool get isMember => _isMember;
  bool _isJoining = false;
  bool get isJoining => _isJoining;
  bool _isCheckingMembership = true;
  bool get isCheckingMembership => _isCheckingMembership;

  // Data for About tab
  List<CcMembersRow> _members = [];
  List<CcMembersRow> get members => _members;
  bool _isLoadingMembers = false;
  bool get isLoadingMembers => _isLoadingMembers;

  Stream<List<CcViewSharingsUsersRow>> get sharingsStream {
    return _sharingRepository.getSharingsStream(group.id, currentUserId: currentUserId);
  }

  Stream<List<CcEventsRow>> get eventsStream {
    return _eventRepository.getEventsStream(group.id);
  }

  Stream<List<CcViewNotificationsUsersRow>> get notificationsStream {
    return _notificationRepository.getNotificationsStream(group.id);
  }

  // Contador de notificações não lidas
  int _unreadNotificationCount = 0;
  int get unreadNotificationCount => _unreadNotificationCount;

  // IDs de notificações lidas
  Set<int> _readNotificationIds = {};
  Set<int> get readNotificationIds => _readNotificationIds;

  Future<List<CcJourneysRow>> get groupJourneys => _journeysRepository.getJourneysForGroup(group.id);

  Future<List<ViewContentRow>> get groupLibrary => _learnRepository.filterContent(filterByGroupId: group.id);

  void init(TickerProvider vsync) {
    _vsync = vsync;
    // Inicialização síncrona obrigatória antes do check async
    _updateTabController();
    _checkMembership();
    _fetchMembers();
    _loadReadNotifications();
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

    final int targetLength = shouldShowOnlyAbout ? 1 : 5;

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

  // Define se deve mostrar apenas a aba About (se não for membro)
  bool get shouldShowOnlyAbout => !_isMember;

  // Define se o usuário pode se inscrever no grupo (apenas se for público e não for membro)
  bool get canJoin {
    if (_isMember) return false;
    final privacy = group.groupPrivacy?.toLowerCase().trim();
    return privacy == 'public' || group.groupPrivacy == null;
  }

  Future<void> joinGroup() async {
    if (currentUserId == null) return;

    _isJoining = true;
    notifyListeners();

    try {
      await _groupRepository.joinGroup(group.id, currentUserId!);
      _isMember = true;

      // Refresh group data to update member count
      final updatedGroup = await _groupRepository.getGroupById(group.id);
      if (updatedGroup != null) {
        _group = updatedGroup;
      }

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

  Future<void> _loadReadNotifications() async {
    if (currentUserId == null || currentUserId!.isEmpty) {
      return;
    }

    try {
      _readNotificationIds = await _notificationRepository.getReadNotificationIds(group.id, currentUserId!);
      _unreadNotificationCount = await _notificationRepository.getUnreadNotificationCount(group.id, currentUserId!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading read notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    if (currentUserId == null || currentUserId!.isEmpty) {
      return;
    }

    try {
      await _notificationRepository.markNotificationAsRead(notificationId, currentUserId!);
      _readNotificationIds.add(notificationId);

      // Atualiza o contador
      if (_unreadNotificationCount > 0) {
        _unreadNotificationCount--;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  bool isNotificationRead(int notificationId) {
    return _readNotificationIds.contains(notificationId);
  }

  @override
  void dispose() {
    tabController?.removeListener(_onTabChanged);
    tabController?.dispose();
    super.dispose();
  }

  Future<void> deleteSharing(int id) async {
    await _sharingRepository.deleteSharing(id);
    notifyListeners();
  }

  Future<void> deleteEvent(int id) async {
    await _eventRepository.deleteEvent(id);
    notifyListeners();
  }

  Future<void> deleteNotification(int id) async {
    await _notificationRepository.deleteNotification(id);
    notifyListeners();
  }

  Future<bool> leaveGroup(BuildContext context) async {
    if (currentUserId == null || currentUserId!.isEmpty) return false;

    // Optional: Add loading state if needed for UI feedback
    // _isJoining = true; // reusing existing flag or create new one
    // notifyListeners();

    try {
      await _groupRepository.removeUserFromGroup(group.id, currentUserId!);
      _isMember = false;

      // Update local check
      _isCheckingMembership = false; // logic reset
      _updateTabController();
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error leaving group: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error leaving group: $e')),
        );
      }
      return false;
    }
  }

  // Member management methods for admin/group_manager

  /// Adds a user directly to the group (status: Active)
  Future<bool> addMember(String userId) async {
    try {
      await _groupRepository.addUserToGroup(group.id, userId);
      await refreshMembers();
      // Refresh group data to update member count
      final updatedGroup = await _groupRepository.getGroupById(group.id);
      if (updatedGroup != null) {
        _group = updatedGroup;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding member: $e');
      return false;
    }
  }

  /// Removes a member from the group
  Future<bool> removeMember(String userId) async {
    try {
      await _groupRepository.removeUserFromGroup(group.id, userId);
      await refreshMembers();
      // Refresh group data to update member count
      final updatedGroup = await _groupRepository.getGroupById(group.id);
      if (updatedGroup != null) {
        _group = updatedGroup;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error removing member: $e');
      return false;
    }
  }

  /// Gets users available to invite (not already members)
  Future<List<CcMembersRow>> getAvailableUsersToInvite() async {
    try {
      return await _groupRepository.getUsersNotInGroup(group.id);
    } catch (e) {
      debugPrint('Error fetching available users: $e');
      return [];
    }
  }

  /// Refreshes the members list
  Future<void> refreshMembers() async {
    await _fetchMembers();
  }

  /// Refreshes the group data (for member count) and members list
  Future<void> refreshGroup() async {
    try {
      final updatedGroup = await _groupRepository.getGroupById(group.id);
      if (updatedGroup != null) {
        _group = updatedGroup;
      }
      await refreshMembers();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing group: $e');
    }
  }
}
