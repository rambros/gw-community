import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/repositories/event_repository.dart';
import 'package:gw_community/data/repositories/experience_moderation_repository.dart';
import 'package:gw_community/data/repositories/experience_repository.dart';
import 'package:gw_community/data/repositories/file_resource_repository.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/repositories/home_repository.dart';
import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/data/repositories/learn_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/data/services/unread_badge_sync.dart';
import 'package:gw_community/domain/community/reply_attention.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';

class GroupDetailsViewModel extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final ExperienceRepository _experienceRepository;
  final EventRepository _eventRepository;
  final AnnouncementRepository _announcementRepository;
  final JourneysRepository _journeysRepository;
  final LearnRepository _learnRepository;
  final FileResourceRepository _fileResourceRepository =
      FileResourceRepository();
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
    return _experienceRepository.getExperiencesStream(group.id,
        currentUserId: currentUserId);
  }

  Stream<List<CcEventsRow>> get eventsStream {
    return _eventRepository.getEventsStream(group.id);
  }

  Stream<List<CcViewNotificationsUsersRow>> get notificationsStream {
    return _announcementRepository.getAnnouncementsStream(group.id).map((list) {
      // Filtra mensagens privadas: exibe broadcast + privadas para/do usuário atual
      return list
          .where((n) =>
              n.recipientUserId == null ||
              n.recipientUserId == currentUserId ||
              n.userId == currentUserId)
          .toList();
    });
  }

  // Contador de notificações não lidas
  int _unreadNotificationCount = 0;
  int get unreadNotificationCount => _unreadNotificationCount;

  // IDs de notificações lidas
  Set<int> _readNotificationIds = {};
  Set<int> get readNotificationIds => _readNotificationIds;

  /// sharing id -> replies from other people after this facilitator last opened it.
  /// Empty for members.
  Map<int, int> _newReplyCounts = {};
  Map<int, int> _commentCounts = {};
  int replyCountFor(int notificationId) => _newReplyCounts[notificationId] ?? 0;
  int commentCountFor(int notificationId) =>
      _commentCounts[notificationId] ?? 0;

  DateTime? _memberJoinDate;

  bool messageNeedsAttention(int notificationId) {
    return announcementNeedsAttention(
      hasRead: _readNotificationIds.contains(notificationId),
      publishedAfterJoin: _publishedAfterJoin(notificationId),
      newReplies: replyCountFor(notificationId),
    );
  }

  bool _publishedAfterJoin(int notificationId) {
    final join = _memberJoinDate;
    if (join == null) return true;
    for (final message in _latestNotifications) {
      if (message.id != notificationId) continue;
      final published = message.updatedAt ?? message.createdAt;
      if (published == null) return true;
      return published.isAfter(join);
    }
    return true;
  }

  List<CcViewNotificationsUsersRow> _latestNotifications = [];

  // Contador de experiences pendentes de moderação
  int _pendingModerationCount = 0;
  int get pendingModerationCount => _pendingModerationCount;

  Future<List<CcJourneysRow>>? _groupJourneysFuture;
  Future<List<CcJourneysRow>> get groupJourneys => _groupJourneysFuture ??=
      _journeysRepository.getJourneysForGroup(group.id);

  Future<List<ViewContentRow>>? _groupLibraryFuture;
  Future<List<ViewContentRow>> get groupLibrary => _groupLibraryFuture ??=
      _learnRepository.filterContent(filterByGroupId: group.id);

  // File resources
  List<CcFileResourcesRow> _groupFileResources = [];
  List<CcFileResourcesRow> get groupFileResources => _groupFileResources;
  bool _isLoadingResources = false;
  bool get isLoadingResources => _isLoadingResources;

  StreamSubscription<List<CcViewNotificationsUsersRow>>?
      _notificationsSubscription;
  Timer? _replyPollTimer;
  bool _disposed = false;

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
      if (_isMember) loadFileResources();
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
      _isMember =
          await _groupRepository.isUserMemberOfGroup(group.id, currentUserId!);
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
      initialIndex:
          shouldShowOnlyAbout ? 0 : (oldIndex < targetLength ? oldIndex : 0),
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
    if (viewAsBlocksWrite()) return;
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
      // Reload module flags so the nav bar immediately reflects modules
      // enabled by this newly joined group (e.g. library, journey tabs).
      await FFAppState().loadGroupModuleConfig(HomeRepository());
      notifyListeners();
    } catch (e) {
      debugPrint('Error joining group: $e');
    } finally {
      _isJoining = false;
      notifyListeners();
    }
  }

  static const int _resourcesTabIndex = 3;

  void _onTabChanged() {
    // Recarrega recursos toda vez que o usuário entra na aba Resources,
    // para refletir mudanças de status feitas no admin portal.
    if (tabController != null &&
        !tabController!.indexIsChanging &&
        tabController!.index == _resourcesTabIndex &&
        _isMember) {
      loadFileResources();
    }
    notifyListeners();
  }

  // Manager IDs storage
  Set<String> _groupManagerIds = {};
  Set<String> get groupManagerIds => _groupManagerIds;

  bool get currentUserIsGroupManager =>
      currentUserId != null && _groupManagerIds.contains(currentUserId);

  Future<void> _fetchMembers() async {
    _isLoadingMembers = true;
    notifyListeners();
    try {
      // 1. Fetch the relationships (roles)
      final groupMembersLinks =
          await _groupRepository.getGroupMembers(group.id);

      // 2. Fetch the user profiles
      final membersUsers =
          await _groupRepository.getGroupMembersAsUsers(group.id);

      // 3. Identify managers based on group-specific role
      _groupManagerIds = groupMembersLinks
          .where((m) =>
              m.userRole == 'GROUP_MANAGER' ||
              m.userRole == 'Manager' ||
              m.userRole == 'group_manager')
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

  Future<DateTime?> announcementReadAt(int notificationId) {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) return Future.value(null);
    return _announcementRepository.getAnnouncementReadAt(
        notificationId, userId);
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    if (viewAsBlocksWrite()) return;
    if (currentUserId == null || currentUserId!.isEmpty) {
      return;
    }

    try {
      final wasNeedingAttention = messageNeedsAttention(notificationId);
      await _announcementRepository.markAnnouncementAsRead(
          notificationId, currentUserId!);
      _readNotificationIds.add(notificationId);
      _newReplyCounts.remove(notificationId);

      if (wasNeedingAttention && _unreadNotificationCount > 0) {
        _unreadNotificationCount--;
      }

      notifyListeners();
      // The group card reloads this same read. The phone icon badge does not,
      // unless something asks for the new total here.
      unawaited(UnreadBadgeSync.instance.refreshNow());
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
      _memberJoinDate = await _announcementRepository.memberJoinDate(
          group.id, currentUserId!);
      _readNotificationIds = await _announcementRepository
          .getReadAnnouncementIds(group.id, currentUserId!);
      final notifications = await CcViewNotificationsUsersTable().queryRows(
        queryFn: (q) => q.eq('group_id', group.id),
      );
      _latestNotifications = _visibleNotifications(notifications);
      await _reloadReplyCounts();
      notifyListeners();
      unawaited(UnreadBadgeSync.instance.refreshNow());
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
      _memberJoinDate = await _announcementRepository.memberJoinDate(
          group.id, currentUserId!);
      _readNotificationIds = await _announcementRepository
          .getReadAnnouncementIds(group.id, currentUserId!);

      // Cancel previous subscription if exists
      await _notificationsSubscription?.cancel();

      // Subscribe to stream to keep count updated
      // Also refresh read status when stream updates (handles edited announcements)
      _notificationsSubscription = _announcementRepository
          .getAnnouncementsStream(group.id)
          .listen((notifications) async {
        if (_disposed || currentUserId == null || currentUserId!.isEmpty) {
          return;
        }
        final joinDate = await _announcementRepository.memberJoinDate(
            group.id, currentUserId!);
        if (_disposed) return;
        final newReadIds = await _announcementRepository.getReadAnnouncementIds(
            group.id, currentUserId!);
        if (_disposed) return;
        final readIdsChanged = !_setEquals(_readNotificationIds, newReadIds) ||
            joinDate != _memberJoinDate;
        _memberJoinDate = joinDate;
        _readNotificationIds = newReadIds;
        _latestNotifications = notifications;
        await _reloadReplyCounts(forceNotify: readIdsChanged);
      });

      _replyPollTimer?.cancel();
      _replyPollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        if (_disposed) return;
        _reloadReplyCounts();
      });
    } catch (e) {
      debugPrint('Error loading read notifications: $e');
    }
  }

  List<CcViewNotificationsUsersRow> _visibleNotifications(
    List<CcViewNotificationsUsersRow> notifications,
  ) {
    return notifications
        .where((n) =>
            n.recipientUserId == null ||
            n.recipientUserId == currentUserId ||
            n.userId == currentUserId)
        .toList();
  }

  Future<void> _reloadReplyCounts({bool forceNotify = false}) async {
    if (_disposed) return;
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) return;

    final visible = _visibleNotifications(_latestNotifications);
    final sharingGroupIds = <int, int>{
      for (final message in visible)
        if (message.id != null) message.id!: group.id,
    };
    final attention = await _announcementRepository.getReplyAttention(
      userId: userId,
      sharingGroupIds: sharingGroupIds,
    );
    final nextCounts = {
      for (final entry in attention.unseen.entries)
        entry.key: entry.value.count,
    };
    final repliesChanged = !_replyCountsEqual(_newReplyCounts, nextCounts) ||
        !_replyCountsEqual(_commentCounts, attention.totals);
    if (_disposed) return;
    _newReplyCounts = nextCounts;
    _commentCounts = attention.totals;
    _updateUnreadCount(visible, forceNotify: forceNotify || repliesChanged);
  }

  bool _replyCountsEqual(Map<int, int> a, Map<int, int> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  void _updateUnreadCount(List<CcViewNotificationsUsersRow> notifications,
      {bool forceNotify = false}) {
    if (_disposed) return;
    // Só conta broadcast + privadas para/do usuário atual
    final visible = notifications.where((n) =>
        n.recipientUserId == null ||
        n.recipientUserId == currentUserId ||
        n.userId == currentUserId);
    final ids = visible.map((n) => n.id!).toSet();
    final unreadCount = ids.where(messageNeedsAttention).length;

    if (_unreadNotificationCount != unreadCount || forceNotify) {
      final changed = _unreadNotificationCount != unreadCount;
      _unreadNotificationCount = unreadCount;
      notifyListeners();
      if (changed) UnreadBadgeSync.instance.schedule();
    }
  }

  bool _setEquals(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  Future<void> _loadPendingModerationCount() async {
    try {
      _pendingModerationCount = await ExperienceModerationRepository()
          .getPendingCountForGroup(group.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pending moderation count: $e');
      _pendingModerationCount = 0;
    }
  }

  // =========================================================================
  // File Resources
  // =========================================================================

  Future<void> loadFileResources() async {
    _isLoadingResources = true;
    notifyListeners();
    try {
      final staffSeesDrafts = !viewAsBlocksWrite() &&
          FFAppState().loginUser.roles.hasAdminOrGroupManager;
      final publishedOnly = !currentUserIsGroupManager && !staffSeesDrafts;
      _groupFileResources =
          await _fileResourceRepository.getFileResourcesForGroup(
        group.id,
        publishedOnly: publishedOnly,
      );
    } catch (e) {
      debugPrint('GroupDetailsViewModel.loadFileResources: $e');
    } finally {
      _isLoadingResources = false;
      notifyListeners();
    }
  }

  Future<bool> createFileResource({
    required String title,
    String? description,
    required String url,
    required String type,
  }) async {
    if (viewAsBlocksWrite()) return false;
    if (currentUserId == null) return false;
    final ok = await _fileResourceRepository.createFileResource(
      title: title,
      description: description,
      url: url,
      type: type,
      groupId: group.id,
      createdBy: currentUserId!,
    );
    if (ok) await loadFileResources();
    return ok;
  }

  Future<bool> deleteFileResource(int resourceId) async {
    if (viewAsBlocksWrite()) return false;
    final ok =
        await _fileResourceRepository.deleteFileResource(resourceId, group.id);
    if (ok) await loadFileResources();
    return ok;
  }

  Future<bool> toggleFileResourceStatus(
      int resourceId, String currentStatus) async {
    if (viewAsBlocksWrite()) return false;
    final newStatus = currentStatus == 'published' ? 'draft' : 'published';
    final ok = await _fileResourceRepository.updateFileResource(resourceId,
        status: newStatus);
    if (ok) await loadFileResources();
    return ok;
  }

  Future<bool> unlinkFileResource(int resourceId, int portalItemId) async {
    if (viewAsBlocksWrite()) return false;
    final ok = await _fileResourceRepository.unlinkPortalItemFromGroup(
      resourceId: resourceId,
      groupId: group.id,
      portalItemId: portalItemId,
    );
    if (ok) await loadFileResources();
    return ok;
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _replyPollTimer?.cancel();
    _notificationsSubscription?.cancel();
    tabController?.removeListener(_onTabChanged);
    tabController?.dispose();
    super.dispose();
  }

  Future<void> deleteExperience(int id) async {
    if (viewAsBlocksWrite()) return;
    await _experienceRepository.deleteExperience(id);
    notifyListeners();
  }

  Future<void> unpublishExperience(int id) async {
    if (viewAsBlocksWrite()) return;
    await _experienceRepository.unpublishExperience(id);
    notifyListeners();
  }

  Future<void> deleteEvent(int id) async {
    if (viewAsBlocksWrite()) return;
    await _eventRepository.deleteEvent(id);
    notifyListeners();
  }

  Future<void> deleteNotification(int id) async {
    if (viewAsBlocksWrite()) return;
    await _announcementRepository.deleteAnnouncement(id);
    notifyListeners();
  }

  Future<bool> leaveGroup(BuildContext context) async {
    if (viewAsBlocksWrite()) return false;
    if (currentUserId == null || currentUserId!.isEmpty) return false;

    // Optional: Add loading state if needed for UI feedback
    // _isJoining = true; // reusing existing flag or create new one
    // notifyListeners();

    try {
      await _groupRepository.removeUserFromGroup(group.id, currentUserId!);
      _isMember = false;
      _isCheckingMembership = false;
      _updateTabController();
      // Reload module flags so nav tabs are hidden/shown based on remaining groups.
      await FFAppState().loadGroupModuleConfig(HomeRepository());
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
    if (viewAsBlocksWrite()) return false;
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
    if (viewAsBlocksWrite()) return false;
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
