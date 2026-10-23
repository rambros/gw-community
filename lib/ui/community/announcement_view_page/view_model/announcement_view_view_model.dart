import 'package:flutter/material.dart';

import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/reply_attention.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';

class AnnouncementViewViewModel extends ChangeNotifier {
  AnnouncementViewViewModel({
    required AnnouncementRepository repository,
    required this.currentUserUid,
    required this.appState,
    this.groupModerators,
    this.commentsReadAt,
    this.highlightNewComments = false,
  }) : _repository = repository;

  final AnnouncementRepository _repository;
  final String currentUserUid;
  final FFAppState appState;
  final List<int>? groupModerators;

  /// Last open, captured before this visit marks the message as read.
  final DateTime? commentsReadAt;
  final bool highlightNewComments;

  int? _announcementId;
  CcViewNotificationsUsersRow? _announcement;
  List<CcViewOrderedCommentsRow> _comments = [];
  CommentListOrder _commentOrder = CommentListOrder.conversation;
  bool _canSeeAllComments = false;
  bool _isLoading = false;
  bool _isActionInProgress = false;
  String? _errorMessage;

  CcViewNotificationsUsersRow? get announcement => _announcement;

  /// Facilitators see every comment. Members see only what they wrote.
  bool get canSeeAllComments => _canSeeAllComments;
  CommentListOrder get commentOrder => _commentOrder;

  bool get showCommentThread => canSeeAllComments || comments.isNotEmpty;

  String get _viewerId =>
      ViewAsSession.instance.subjectUserId(currentUserUid);

  List<CcViewOrderedCommentsRow> get comments {
    final visibleIds = commentIdsVisibleToMember(
      viewerId: _viewerId,
      comments: _comments.map(
        (comment) => SharingComment(
          id: comment.id,
          parentId: comment.parentId,
          userId: comment.userId,
          sharingId: comment.sharingId ?? 0,
          createdAt: comment.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
      ),
    );
    final visible = _canSeeAllComments
        ? _comments
        : _comments.where((comment) => visibleIds.contains(comment.id));
    final list = List<CcViewOrderedCommentsRow>.of(visible);
    if (_commentOrder == CommentListOrder.oldestFirst) {
      list.sort((a, b) => _commentTime(a).compareTo(_commentTime(b)));
    } else if (_commentOrder == CommentListOrder.newestFirst) {
      list.sort((a, b) => _commentTime(b).compareTo(_commentTime(a)));
    }
    return list;
  }

  void cycleCommentOrder() {
    _commentOrder = cycleCommentListOrder(_commentOrder);
    notifyListeners();
  }

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
      _canSeeAllComments = await _repository.isGroupFacilitator(
        groupId: _announcement?.groupId,
        userId: _viewerId,
      );
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

  bool isNewComment(CcViewOrderedCommentsRow comment) {
    if (!highlightNewComments) return false;
    return commentIsNewSinceRead(
      authorId: comment.userId,
      viewerId: currentUserUid,
      createdAt: comment.createdAt,
      readAt: commentsReadAt,
    );
  }

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

  DateTime _commentTime(CcViewOrderedCommentsRow comment) {
    return comment.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
