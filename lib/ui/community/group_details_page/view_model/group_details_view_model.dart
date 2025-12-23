import 'package:flutter/material.dart';
import '/data/services/supabase/supabase.dart';
import '/data/repositories/group_repository.dart';
import '/data/repositories/sharing_repository.dart';
import '/data/repositories/event_repository.dart';
import '/data/repositories/notification_repository.dart';

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

  late TabController tabController;

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
    tabController = TabController(
      length: 4,
      vsync: vsync,
      initialIndex: 0,
    );
    tabController.addListener(_onTabChanged);
    _fetchMembers();
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
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
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
