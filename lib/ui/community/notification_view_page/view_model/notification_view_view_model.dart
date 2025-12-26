import 'package:flutter/material.dart';

import '/app_state.dart';
import '/data/repositories/notification_repository.dart';
import '/data/services/supabase/supabase.dart';

class NotificationViewViewModel extends ChangeNotifier {
  NotificationViewViewModel({
    required NotificationRepository repository,
    required this.currentUserUid,
    required this.appState,
    this.groupModerators,
  }) : _repository = repository;

  final NotificationRepository _repository;
  final String currentUserUid;
  final FFAppState appState;
  final List<int>? groupModerators;

  int? _notificationId;
  CcViewNotificationsUsersRow? _notification;
  List<CcViewOrderedCommentsRow> _comments = [];
  bool _isLoading = false;
  bool _isActionInProgress = false;
  String? _errorMessage;

  CcViewNotificationsUsersRow? get notification => _notification;
  List<CcViewOrderedCommentsRow> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isActionInProgress => _isActionInProgress;
  String? get errorMessage => _errorMessage;
  bool get isLocked => _notification?.locked ?? false;

  Future<void> initialize(int notificationId) async {
    _notificationId = notificationId;
    await loadNotification();
  }

  Future<void> loadNotification() async {
    if (_notificationId == null) return;
    _setLoading(true);
    try {
      _notification = await _repository.getNotificationById(_notificationId!);
      _comments = await _repository.getComments(_notificationId!);
      _clearError();
    } catch (e) {
      _setError('Error loading notification: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshComments() async {
    if (_notificationId == null) return;
    try {
      _comments = await _repository.getComments(_notificationId!);
      notifyListeners();
    } catch (e) {
      _setError('Error loading comments: $e');
    }
  }

  bool get canDeleteNotification {
    if (_notification == null) return false;
    return _notification!.userId == currentUserUid || _isAdmin;
  }

  bool get canToggleLock => canDeleteNotification;

  bool get _isAdmin => appState.loginUser.roles.contains('Admin');

  bool canDeleteComment(String? userId) {
    if (userId == null) return _isAdmin;
    return userId == currentUserUid || _isAdmin;
  }

  bool get canComment => !isLocked;

  Future<bool> toggleLock() async {
    if (!canToggleLock || _notificationId == null || _notification == null) {
      return false;
    }
    _setActionInProgress(true);
    try {
      await _repository.toggleLock(_notificationId!, !_notification!.locked!);
      await loadNotification();
      return true;
    } catch (e) {
      _setError('Error updating lock status: $e');
      return false;
    } finally {
      _setActionInProgress(false);
    }
  }

  Future<bool> deleteNotification() async {
    if (!canDeleteNotification || _notificationId == null) {
      return false;
    }
    _setActionInProgress(true);
    try {
      await _repository.deleteNotification(_notificationId!);
      return true;
    } catch (e) {
      _setError('Error deleting notification: $e');
      return false;
    } finally {
      _setActionInProgress(false);
    }
  }

  Future<bool> deleteComment(int commentId) async {
    _setActionInProgress(true);
    try {
      await _repository.deleteComment(commentId);
      await refreshComments();
      return true;
    } catch (e) {
      _setError('Error deleting comment: $e');
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
