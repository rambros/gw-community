import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/experience_moderation_repository.dart';
import 'package:gw_community/data/repositories/notification_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// ViewModel for group moderation page
/// Manages state and actions for moderating experiences in a single group
/// Follows MVVM pattern as per Compass architecture
class GroupModerationViewModel extends ChangeNotifier {
  final ExperienceModerationRepository _repository;
  final NotificationRepository _notificationRepository;
  final int groupId;
  final String currentUserUid;

  GroupModerationViewModel({
    required ExperienceModerationRepository repository,
    required NotificationRepository notificationRepository,
    required this.groupId,
    required this.currentUserUid,
  }) : _repository = repository,
       _notificationRepository = notificationRepository;

  // ========== STATE ==========

  List<CcViewPendingExperiencesRow> _pendingExperiences = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CcViewPendingExperiencesRow> get pendingExperiences => _pendingExperiences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ========== COMPUTED ==========

  int get pendingCount => _pendingExperiences.length;
  bool get hasPending => pendingCount > 0;
  bool get hasError => _errorMessage != null;

  // ========== INITIALIZATION ==========

  Future<void> loadPendingExperiences() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('GroupModerationViewModel: loading pending for group $groupId');
      _pendingExperiences = await _repository.getPendingForGroup(groupId);
      debugPrint('GroupModerationViewModel: loaded ${_pendingExperiences.length} pending experiences');
    } catch (e) {
      debugPrint('GroupModerationViewModel: error loading experiences: $e');
      _setError('Error loading experiences: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== COMMANDS (User Actions) ==========

  /// Approves an experience and notifies the author
  Future<bool> approveExperienceCommand(CcViewPendingExperiencesRow experience) async {
    try {
      debugPrint('GroupModerationViewModel: approving experience ${experience.id}');

      await _repository.approveExperience(experienceId: experience.id!, moderatorId: currentUserUid);

      // Notify author (non-blocking)
      if (experience.userId != null) {
        try {
          await _notificationRepository.createApprovalNotification(
            userId: experience.userId!,
            experienceId: experience.id!,
            experienceTitle: _getPreview(experience),
            groupId: groupId,
          );
          debugPrint('GroupModerationViewModel: approval notification sent');
        } catch (notifError) {
          debugPrint('GroupModerationViewModel: notification failed (non-critical): $notifError');
        }
      }

      await loadPendingExperiences();
      return true;
    } catch (e) {
      debugPrint('GroupModerationViewModel: error approving: $e');
      _setError('Error approving experience: $e');
      return false;
    }
  }

  /// Sets an experience to "Not Published" with a reason and notifies the author
  Future<bool> notPublishExperienceCommand(CcViewPendingExperiencesRow experience, String reason) async {
    if (reason.trim().isEmpty) {
      _setError('Reason is required');
      return false;
    }

    try {
      debugPrint('GroupModerationViewModel: setting "Not Published" on experience ${experience.id}');

      await _repository.rejectExperience(experienceId: experience.id!, moderatorId: currentUserUid, reason: reason);

      // Notify author (non-blocking)
      if (experience.userId != null) {
        try {
          await _notificationRepository.createRejectionNotification(
            userId: experience.userId!,
            experienceId: experience.id!,
            experienceTitle: _getPreview(experience),
            reason: reason,
            groupId: groupId,
          );
          debugPrint('GroupModerationViewModel: "Not Published" notification sent');
        } catch (notifError) {
          debugPrint('GroupModerationViewModel: notification failed (non-critical): $notifError');
        }
      }

      await loadPendingExperiences();
      return true;
    } catch (e) {
      debugPrint('GroupModerationViewModel: error setting "Not Published": $e');
      _setError('Error setting "Not Published": $e');
      return false;
    }
  }

  /// Suggests refinement on an experience with feedback and notifies the author
  Future<bool> suggestRefinementCommand(CcViewPendingExperiencesRow experience, String reason) async {
    if (reason.trim().isEmpty) {
      _setError('Feedback is required');
      return false;
    }

    try {
      debugPrint('GroupModerationViewModel: suggesting refinement on experience ${experience.id}');

      await _repository.requestChanges(experienceId: experience.id!, moderatorId: currentUserUid, reason: reason);

      // Notify author (non-blocking)
      if (experience.userId != null) {
        try {
          await _notificationRepository.createChangesRequestedNotification(
            userId: experience.userId!,
            experienceId: experience.id!,
            experienceTitle: _getPreview(experience),
            reason: reason,
            groupId: groupId,
          );
          debugPrint('GroupModerationViewModel: refinement suggested notification sent');
        } catch (notifError) {
          debugPrint('GroupModerationViewModel: notification failed (non-critical): $notifError');
        }
      }

      await loadPendingExperiences();
      return true;
    } catch (e) {
      debugPrint('GroupModerationViewModel: error suggesting refinement: $e');
      _setError('Error suggesting refinement: $e');
      return false;
    }
  }

  // ========== HELPERS ==========

  /// Generates a preview/title from experience text (first 50 chars)
  String _getPreview(CcViewPendingExperiencesRow experience) {
    final text = experience.text ?? '';
    if (text.isEmpty) return 'Experience';
    if (text.length <= 50) return text;
    return '${text.substring(0, 50)}...';
  }

  void _setLoading(bool value) {
    _isLoading = value;
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
