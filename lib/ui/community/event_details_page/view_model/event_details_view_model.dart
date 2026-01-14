import 'package:flutter/material.dart';

import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/repositories/community_repository.dart';
import 'package:gw_community/data/repositories/event_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class EventDetailsViewModel extends ChangeNotifier {
  EventDetailsViewModel({
    required EventRepository repository,
    required this.currentUserUid,
    required this.appState,
    CcEventsRow? initialEvent,
  }) : _repository = repository {
    if (initialEvent != null) {
      _event = initialEvent;
      _eventId = initialEvent.id;
    }
  }

  final EventRepository _repository;
  final String currentUserUid;
  final FFAppState appState;

  int? _eventId;
  CcEventsRow? _event;
  List<CcMembersRow> _participants = [];
  bool _isLoading = false;
  bool _isActionInProgress = false;
  String? _errorMessage;

  String? _memberId;
  String? get memberId => _memberId;

  CcEventsRow? get event => _event;
  List<CcMembersRow> get participants => _participants;
  bool get isLoading => _isLoading;
  bool get isActionInProgress => _isActionInProgress;
  String? get errorMessage => _errorMessage;
  int get participantsCount => _participants.length;

  bool get isUserRegistered {
    final idToCompare = _memberId ?? currentUserUid;
    return _participants.any((p) => p.id == idToCompare);
  }

  bool get canEdit {
    final loginUser = appState.loginUser;
    final idToCompare = _memberId ?? currentUserUid;
    return loginUser.roles.contains('Admin') ||
        loginUser.roles.contains('Group Manager') ||
        (_event?.facilitatorId == idToCompare);
  }

  bool get canDelete => canEdit;
  bool get isPublic => _event?.visibility == 'everyone';

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
      if (_memberId == null) {
        // Resolvemos o memberId se ainda não tivermos
        final communityRepo = CommunityRepository(); // Ou injetar se preferir, mas como é stateless call...
        _memberId = await communityRepo.getMemberIdByAuthUserId(currentUserUid);
        debugPrint('EventDetailsViewModel.loadEvent: resolved memberId to $_memberId');
      }

      final fetchedEvent = await _repository.getEventById(_eventId!);
      if (fetchedEvent != null) {
        _event = fetchedEvent;
      }
      _participants = await _repository.getParticipants(_eventId!);
      _clearError();
    } catch (e) {
      _setError('Error loading event: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register() async {
    if (_eventId == null) return false;
    _setActionInProgress(true);
    try {
      final idToUse = _memberId ?? currentUserUid;
      await _repository.registerUser(eventId: _eventId!, userId: idToUse);
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
    if (_eventId == null) return false;
    _setActionInProgress(true);
    try {
      final idToUse = _memberId ?? currentUserUid;
      await _repository.unregisterUser(eventId: _eventId!, userId: idToUse);
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
