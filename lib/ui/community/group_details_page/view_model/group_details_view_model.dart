import 'package:flutter/material.dart';
import 'dart:async';

import 'package:gw_community/data/repositories/event_repository.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/repositories/experience_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/data/repositories/learn_repository.dart';
import 'package:gw_community/data/repositories/experience_moderation_repository.dart';

class GroupDetailsViewModel extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final ExperienceRepository _experienceRepository;
  final EventRepository _eventRepository;
  final AnnouncementRepository _announcementRepository;
  final JourneysRepository _journeysRepository;
  final LearnRepository _learnRepository;
  CcGroupsRow _group;
  CcGroupsRow get group => _group;
  final String? currentUserId;

  GroupDetailsViewModel(
    this._groupRepository,
    this._experienceRepository,
    this._eventRepository,
    this._announcementRepository,
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
  bool _isCheckingMembership = true; // Start true to block UI while loading
  bool get isCheckingMembership => _isCheckingMembership;

  // Data for About tab
  List<CcMembersRow> _members = [];
  List<CcMembersRow> get members => _members;
  bool _isLoadingMembers = false;
  bool get isLoadingMembers => _isLoadingMembers;

  Stream<List<CcViewSharingsUsersRow>> get experiencesStream {
    return _experienceRepository.getExperiencesStream(group.id, currentUserId: currentUserId);
  }

  Stream<List<CcEventsRow>> get eventsStream {
    return _eventRepository.getEventsStream(group.id);
  }

  Stream<List<CcViewNotificationsUsersRow>> get notificationsStream {
    return _announcementRepository.getAnnouncementsStream(group.id);
  }

  // Contador de notificações não lidas
  int _unreadNotificationCount = 0;
  int get unreadNotificationCount => _unreadNotificationCount;

  // IDs de notificações lidas
  Set<int> _readNotificationIds = {};
  Set<int> get readNotificationIds => _readNotificationIds;

  // Contador de experiences pendentes de moderação
  int _pendingModerationCount = 0;
  int get pendingModerationCount => _pendingModerationCount;

  Future<List<CcJourneysRow>>? _groupJourneysFuture;
  Future<List<CcJourneysRow>> get groupJourneys =>
      _groupJourneysFuture ??= _journeysRepository.getJourneysForGroup(group.id);

  Future<List<ViewContentRow>>? _groupLibraryFuture;
  Future<List<ViewContentRow>> get groupLibrary =>
      _groupLibraryFuture ??= _learnRepository.filterContent(filterByGroupId: group.id);

  StreamSubscription<List<CcViewNotificationsUsersRow>>? _notificationsSubscription;

  void init(TickerProvider vsync) {
    _vsync = vsync;

    // Inicialização síncrona obrigatória
    _updateTabController();

    // Executa as cargas de dados
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // 1. Check membership first as it defines the UI structure
      await _checkMembership();

      // 2. Load other data in background
      _fetchMembers();
      _loadReadNotificationsAndSubscribe();
      _loadPendingModerationCount();
    } catch (e) {
      debugPrint('Error in GroupDetailsViewModel.init: $e');
      // Ensure we stop loading state even on error
      _isCheckingMembership = false;
      notifyListeners();
    }
  }

  // ... (existing code)

  Future<void> _checkMembership() async {
    if (currentUserId == null || currentUserId!.isEmpty) {
      _isMember = false;
      _isCheckingMembership = false;
      _updateTabController();
      notifyListeners();
      return;
    }

    // Still perform the check, but it won't block the UI with a spinner
    try {
      _isMember = await _groupRepository.isUserMemberOfGroup(group.id, currentUserId!);
    } catch (e) {
      debugPrint('Error checking membership: $e');
      _isMember = false;
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

  // Manager IDs storage
  Set<String> _groupManagerIds = {};
  Set<String> get groupManagerIds => _groupManagerIds;

  Future<void> _fetchMembers() async {
    _isLoadingMembers = true;
    notifyListeners();
    try {
      // 1. Fetch the relationships (roles)
      final groupMembersLinks = await _groupRepository.getGroupMembers(group.id);

      // 2. Fetch the user profiles
      final membersUsers = await _groupRepository.getGroupMembersAsUsers(group.id);

      // 3. Identify managers based on group-specific role
      _groupManagerIds = groupMembersLinks
          .where((m) => m.userRole == 'GROUP_MANAGER' || m.userRole == 'Manager' || m.userRole == 'group_manager')
          .map((m) => m.userId)
          .where((id) => id != null)
          .cast<String>()
          .toSet();

      _members = membersUsers;
    } catch (e) {
      debugPrint('Error fetching members: $e');
    } finally {
      _isLoadingMembers = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    if (currentUserId == null || currentUserId!.isEmpty) {
      return;
    }

    try {
      await _announcementRepository.markAnnouncementAsRead(notificationId, currentUserId!);
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

  /// Recarrega os IDs de notificações lidas do banco de dados.
  /// Útil após editar um anúncio, que reseta o status de leitura.
  Future<void> refreshReadNotifications() async {
    if (currentUserId == null || currentUserId!.isEmpty) {
      return;
    }

    try {
      _readNotificationIds = await _announcementRepository.getReadAnnouncementIds(group.id, currentUserId!);
      // Força atualização do contador buscando as notificações atuais
      final notifications = await CcViewNotificationsUsersTable().queryRows(
        queryFn: (q) => q.eq('group_id', group.id),
      );
      _updateUnreadCount(notifications);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing read notifications: $e');
    }
  }

  bool isNotificationRead(int notificationId) {
    return _readNotificationIds.contains(notificationId);
  }

  Future<void> _loadReadNotificationsAndSubscribe() async {
    if (currentUserId == null || currentUserId!.isEmpty) {
      return;
    }

    try {
      // First load existing read status
      _readNotificationIds = await _announcementRepository.getReadAnnouncementIds(group.id, currentUserId!);

      // Cancel previous subscription if exists
      await _notificationsSubscription?.cancel();

      // Subscribe to stream to keep count updated
      // Also refresh read status when stream updates (handles edited announcements)
      _notificationsSubscription =
          _announcementRepository.getAnnouncementsStream(group.id).listen((notifications) async {
        // Recarrega os IDs lidos do banco para detectar anúncios editados
        // (que tiveram seus registros de leitura deletados)
        final newReadIds = await _announcementRepository.getReadAnnouncementIds(group.id, currentUserId!);
        final readIdsChanged = !_setEquals(_readNotificationIds, newReadIds);
        _readNotificationIds = newReadIds;
        _updateUnreadCount(notifications, forceNotify: readIdsChanged);
      });
    } catch (e) {
      debugPrint('Error loading read notifications: $e');
    }
  }

  void _updateUnreadCount(List<CcViewNotificationsUsersRow> notifications, {bool forceNotify = false}) {
    final ids = notifications.map((n) => n.id!).toSet();
    final unreadCount = ids.where((id) => !_readNotificationIds.contains(id)).length;

    if (_unreadNotificationCount != unreadCount || forceNotify) {
      _unreadNotificationCount = unreadCount;
      notifyListeners();
    }
  }

  bool _setEquals(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  Future<void> _loadPendingModerationCount() async {
    try {
      _pendingModerationCount = await ExperienceModerationRepository().getPendingCountForGroup(group.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pending moderation count: $e');
      _pendingModerationCount = 0;
    }
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    tabController?.removeListener(_onTabChanged);
    tabController?.dispose();
    super.dispose();
  }

  Future<void> deleteExperience(int id) async {
    await _experienceRepository.deleteExperience(id);
    notifyListeners();
  }

  Future<void> deleteEvent(int id) async {
    await _eventRepository.deleteEvent(id);
    notifyListeners();
  }

  Future<void> deleteNotification(int id) async {
    await _announcementRepository.deleteAnnouncement(id);
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
      await _loadPendingModerationCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing group: $e');
    }
  }
}
