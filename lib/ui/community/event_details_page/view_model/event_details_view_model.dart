import 'package:flutter/material.dart';

import '/app_state.dart';
import '/data/services/supabase/supabase.dart';
import '/data/repositories/event_repository.dart';

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
  List<CcUsersRow> _participants = [];
  bool _isLoading = false;
  bool _isActionInProgress = false;
  String? _errorMessage;

  CcEventsRow? get event => _event;
  List<CcUsersRow> get participants => _participants;
  bool get isLoading => _isLoading;
  bool get isActionInProgress => _isActionInProgress;
  String? get errorMessage => _errorMessage;
  int get participantsCount => _participants.length;
  bool get isUserRegistered => _participants.any((p) => p.id == currentUserUid);

  bool get canEdit {
    final loginUser = appState.loginUser;
    return loginUser.roles.contains('Admin') ||
        loginUser.roles.contains('Group Manager') ||
        (_event?.facilitatorId == currentUserUid);
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
      await _repository.registerUser(
          eventId: _eventId!, userId: currentUserUid);
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
      await _repository.unregisterUser(
          eventId: _eventId!, userId: currentUserUid);
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
