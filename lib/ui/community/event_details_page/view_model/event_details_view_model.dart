import 'package:flutter/material.dart';

import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/event_repository.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/event_access.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';

class EventDetailsViewModel extends ChangeNotifier {
  EventDetailsViewModel({
    required EventRepository repository,
    required GroupRepository groupRepository,
    required this.currentUserUid,
    required this.subjectUserId,
    required this.appState,
    CcEventsRow? initialEvent,
  })  : _repository = repository,
        _groupRepository = groupRepository {
    if (initialEvent != null) {
      _eventId = initialEvent.id;
      _isLoading = true;
    }
  }

  final EventRepository _repository;
  final GroupRepository _groupRepository;
  final String currentUserUid;

  /// Member whose groups decide visibility. Equals [currentUserUid] except
  /// while an admin is using view-as.
  final String subjectUserId;
  final FFAppState appState;

  int? _eventId;
  CcEventsRow? _event;
  List<CcMembersRow> _participants = [];
  bool _isLoading = false;
  bool _isActionInProgress = false;
  String? _errorMessage;

  CcEventsRow? get event => _event;
  List<CcMembersRow> get participants => _participants;
  bool get isLoading => _isLoading;
  bool get isActionInProgress => _isActionInProgress;
  String? get errorMessage => _errorMessage;
  int get participantsCount => _participants.length;

  bool get isUserRegistered {
    return _participants.any((p) => p.id == currentUserUid);
  }

  bool get canEdit {
    final loginUser = appState.loginUser;
    return loginUser.roles.hasAdminOrGroupManager || (_event?.facilitatorId == currentUserUid);
  }

  bool get canDelete => canEdit;
  bool get isPublic => _event?.visibility == 'everyone';

  String? _groupImageUrl;

  /// Custom event header, or the group's image when the event has none.
  String? get headerImageUrl {
    final custom = _usableImage(_event?.eventImageUrl);
    if (custom != null) return custom;
    return _usableImage(_groupImageUrl);
  }

  Future<void> initialize(int eventId) async {
    _eventId = eventId;
    await loadEvent();
  }

  Future<void> loadEvent() async {
    if (_eventId == null) {
      return;
    }
    _setLoading(true);
    try {
      final fetchedEvent = await _repository.getEventById(_eventId!);
      final groups = await _groupRepository.getMyGroups(subjectUserId);
      final memberGroupIds = groups.map((group) => group.id).toSet();
      final visible = fetchedEvent != null &&
          eventVisibleToUser(
            visibility: fetchedEvent.visibility,
            groupId: fetchedEvent.groupId,
            facilitatorId: fetchedEvent.facilitatorId,
            userId: subjectUserId,
            memberGroupIds: memberGroupIds,
          );
      if (!visible) {
        _event = null;
        _participants = [];
        _clearError();
        return;
      }
      _event = fetchedEvent;
      await _loadGroupImage();
      _participants = await _repository.getParticipants(_eventId!);
      _clearError();
    } catch (e) {
      _setError('Error loading event: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register() async {
    if (viewAsBlocksWrite()) return false;
    if (_eventId == null) return false;
    _setActionInProgress(true);
    try {
      await _repository.registerUser(eventId: _eventId!, userId: currentUserUid);
      await loadEvent();
      return true;
    } catch (e) {
      _setError('Error registering: $e');
      return false;
    } finally {
      _setActionInProgress(false);
    }
  }

  Future<bool> unregister() async {
    if (viewAsBlocksWrite()) return false;
    if (_eventId == null) return false;
    _setActionInProgress(true);
    try {
      await _repository.unregisterUser(eventId: _eventId!, userId: currentUserUid);
      await loadEvent();
      return true;
    } catch (e) {
      _setError('Error unregistering: $e');
      return false;
    } finally {
      _setActionInProgress(false);
    }
  }

  Future<bool> deleteEvent() async {
    if (_eventId == null) return false;
    _setActionInProgress(true);
    try {
      await _repository.deleteEvent(_eventId!);
      return true;
    } catch (e) {
      _setError('Error deleting event: $e');
      return false;
    } finally {
      _setActionInProgress(false);
    }
  }

  bool _disposed = false;

  Future<void> _loadGroupImage() async {
    final groupId = _event?.groupId;
    if (groupId == null) return;
    try {
      final group = await _groupRepository.getGroupById(groupId);
      if (_disposed) return;
      final nextUrl = group?.groupImageUrl;
      if (nextUrl == _groupImageUrl) return;
      _groupImageUrl = nextUrl;
      notifyListeners();
    } catch (_) {
      // Header falls back to an empty placeholder.
    }
  }

  String? _usableImage(String? url) {
    final value = url?.trim();
    if (value == null || value.isEmpty) return null;
    if (RegExp(r'\.(mp3|mp4|wav|m4a|mov|webm)(\?|$)', caseSensitive: false).hasMatch(value)) {
      return null;
    }
    return value;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setActionInProgress(bool value) {
    _isActionInProgress = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
