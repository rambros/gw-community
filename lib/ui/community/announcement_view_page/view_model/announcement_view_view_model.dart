import 'package:flutter/material.dart';

import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class AnnouncementViewViewModel extends ChangeNotifier {
  AnnouncementViewViewModel({
    required AnnouncementRepository repository,
    required this.currentUserUid,
    required this.appState,
    this.groupModerators,
  }) : _repository = repository;

  final AnnouncementRepository _repository;
  final String currentUserUid;
  final FFAppState appState;
  final List<int>? groupModerators;

  int? _announcementId;
  CcViewNotificationsUsersRow? _announcement;
  List<CcViewOrderedCommentsRow> _comments = [];
  bool _isLoading = false;
  bool _isActionInProgress = false;
  String? _errorMessage;

  CcViewNotificationsUsersRow? get announcement => _announcement;
  List<CcViewOrderedCommentsRow> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isActionInProgress => _isActionInProgress;
  String? get errorMessage => _errorMessage;
  bool get isLocked => _announcement?.locked ?? false;

  Future<void> initialize(int announcementId) async {
    _announcementId = announcementId;
    await loadAnnouncement();
  }

  Future<void> loadAnnouncement() async {
    if (_announcementId == null) return;
    _setLoading(true);
    try {
      _announcement = await _repository.getAnnouncementById(_announcementId!);
      _comments = await _repository.getComments(_announcementId!);
      _clearError();
    } catch (e) {
      _setError('Error loading announcement: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshComments() async {
    if (_announcementId == null) return;
    try {
      _comments = await _repository.getComments(_announcementId!);
      notifyListeners();
    } catch (e) {
      _setError('Error loading comments: $e');
    }
  }

  bool get canDeleteAnnouncement {
    if (_announcement == null) return false;
    return _announcement!.userId == currentUserUid || _isAdmin;
  }

  bool get canToggleLock => canDeleteAnnouncement;
  bool get canEditAnnouncement => canDeleteAnnouncement;

  bool get _isAdmin => appState.loginUser.roles.hasAdmin;

  bool canDeleteComment(String? userId) {
    if (userId == null) return _isAdmin;
    return userId == currentUserUid || _isAdmin;
  }

  bool get canComment => !isLocked;

  Future<bool> toggleLock() async {
    if (!canToggleLock || _announcementId == null || _announcement == null) {
      return false;
    }
    _setActionInProgress(true);
    try {
      await _repository.toggleLock(_announcementId!, !_announcement!.locked!);
      await loadAnnouncement();
      return true;
    } catch (e) {
      _setError('Error updating lock status: $e');
      return false;
    } finally {
      _setActionInProgress(false);
    }
  }

  Future<bool> deleteAnnouncement() async {
    if (!canDeleteAnnouncement || _announcementId == null) {
      return false;
    }
    _setActionInProgress(true);
    try {
      await _repository.deleteAnnouncement(_announcementId!);
      return true;
    } catch (e) {
      _setError('Error deleting announcement: $e');
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
