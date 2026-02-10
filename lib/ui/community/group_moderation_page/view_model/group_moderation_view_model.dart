import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/repositories/experience_moderation_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Moderation status filter options - synced with admin portal
enum ModerationStatusFilter {
  all,
  awaitingApproval,
  approved,
  rejected,
  changesRequested,
}

extension ModerationStatusFilterExtension on ModerationStatusFilter {
  String get label {
    switch (this) {
      case ModerationStatusFilter.all:
        return 'All';
      case ModerationStatusFilter.awaitingApproval:
        return 'Awaiting';
      case ModerationStatusFilter.approved:
        return 'Approved';
      case ModerationStatusFilter.rejected:
        return 'Not Published';
      case ModerationStatusFilter.changesRequested:
        return 'Refinement';
    }
  }

  String? get dbValue {
    switch (this) {
      case ModerationStatusFilter.all:
        return null;
      case ModerationStatusFilter.awaitingApproval:
        return 'awaiting_approval';
      case ModerationStatusFilter.approved:
        return 'approved';
      case ModerationStatusFilter.rejected:
        return 'rejected';
      case ModerationStatusFilter.changesRequested:
        return 'changes_requested';
    }
  }
}

/// ViewModel for group moderation page
/// Manages state and actions for moderating experiences in a single group
/// Follows MVVM pattern as per Compass architecture
class GroupModerationViewModel extends ChangeNotifier {
  final ExperienceModerationRepository _repository;
  final AnnouncementRepository _announcementRepository;
  final int groupId;
  final String currentUserUid;

  GroupModerationViewModel({
    required ExperienceModerationRepository repository,
    required AnnouncementRepository announcementRepository,
    required this.groupId,
    required this.currentUserUid,
  })  : _repository = repository,
        _announcementRepository = announcementRepository;

  // ========== STATE ==========

  List<CcViewPendingExperiencesRow> _allExperiences = [];
  List<CcViewPendingExperiencesRow> _filteredExperiences = [];
  bool _isLoading = false;
  String? _errorMessage;
  ModerationStatusFilter _statusFilter = ModerationStatusFilter.awaitingApproval;

  List<CcViewPendingExperiencesRow> get experiences => _filteredExperiences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ModerationStatusFilter get statusFilter => _statusFilter;

  // ========== COMPUTED ==========

  int get experienceCount => _filteredExperiences.length;
  bool get hasExperiences => experienceCount > 0;
  bool get hasError => _errorMessage != null;

  // Status counts for tabs
  Map<String, int> _statusCounts = {};
  int get awaitingApprovalCount => _statusCounts['awaiting_approval'] ?? 0;
  int get approvedCount => _statusCounts['approved'] ?? 0;
  int get rejectedCount => _statusCounts['rejected'] ?? 0;
  int get changesRequestedCount => _statusCounts['changes_requested'] ?? 0;
  int get totalCount => _allExperiences.length;

  // ========== INITIALIZATION ==========

  Future<void> loadExperiences() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('GroupModerationViewModel: loading all experiences for group $groupId');
      // Load all experiences for this group (not just awaiting_approval)
      _allExperiences = await _repository.getExperiencesForGroups([groupId]);

      // Filter out 'pending' status (Reflection phase) - same as admin portal
      _allExperiences = _allExperiences.where((e) => (e.moderationStatus ?? 'pending') != 'pending').toList();

      debugPrint('GroupModerationViewModel: loaded ${_allExperiences.length} experiences');

      // Calculate status counts
      _calculateStatusCounts();

      // Apply current filter
      _applyFilter();
    } catch (e) {
      debugPrint('GroupModerationViewModel: error loading experiences: $e');
      _setError('Error loading experiences: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _calculateStatusCounts() {
    _statusCounts = {
      'awaiting_approval': 0,
      'approved': 0,
      'rejected': 0,
      'changes_requested': 0,
    };

    for (final exp in _allExperiences) {
      final status = exp.moderationStatus ?? 'pending';
      _statusCounts[status] = (_statusCounts[status] ?? 0) + 1;
    }
  }

  void _applyFilter() {
    final statusValue = _statusFilter.dbValue;
    if (statusValue == null) {
      _filteredExperiences = List.from(_allExperiences);
    } else {
      _filteredExperiences = _allExperiences.where((e) {
        final expStatus = e.moderationStatus ?? 'pending';
        return expStatus == statusValue;
      }).toList();
    }
  }

  void setStatusFilter(ModerationStatusFilter filter) {
    _statusFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  int getCountForFilter(ModerationStatusFilter filter) {
    switch (filter) {
      case ModerationStatusFilter.all:
        return totalCount;
      case ModerationStatusFilter.awaitingApproval:
        return awaitingApprovalCount;
      case ModerationStatusFilter.approved:
        return approvedCount;
      case ModerationStatusFilter.rejected:
        return rejectedCount;
      case ModerationStatusFilter.changesRequested:
        return changesRequestedCount;
    }
  }

  String getStatusLabel(String? status) {
    switch (status) {
      case 'awaiting_approval':
        return 'Awaiting Approval';
      case 'pending':
        return 'In Reflection';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Not Published';
      case 'changes_requested':
        return 'Refinement Suggested';
      default:
        return 'Pending';
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF2E7D32); // Dark green for better contrast
      case 'rejected':
        return const Color(0xFFD32F2F); // Dark red for better contrast
      case 'changes_requested':
        return const Color(0xFFE65100); // Dark orange for better contrast
      case 'awaiting_approval':
      case 'pending':
      default:
        return const Color(0xFF1565C0); // Dark blue for better contrast
    }
  }

  // ========== COMMANDS (User Actions) ==========

  /// Approves an experience and notifies the author
  Future<bool> approveExperienceCommand(CcViewPendingExperiencesRow experience) async {
    final experienceId = experience.id;
    if (experienceId == null) {
      debugPrint('GroupModerationViewModel: error approving: experience ID is null');
      _setError('Error approving experience: ID not found');
      return false;
    }

    try {
      debugPrint('GroupModerationViewModel: approving experience $experienceId');

      await _repository.approveExperience(experienceId: experienceId, moderatorId: currentUserUid);

      // Notify author (non-blocking)
      final userId = experience.userId;
      if (userId != null) {
        try {
          await _announcementRepository.createApprovalNotification(
            userId: userId,
            experienceId: experienceId,
            experienceTitle: _getPreview(experience),
            groupId: groupId,
          );
          debugPrint('GroupModerationViewModel: approval notification sent');
        } catch (notifError) {
          debugPrint('GroupModerationViewModel: notification failed (non-critical): $notifError');
        }
      }

      await loadExperiences();
      return true;
    } catch (e) {
      debugPrint('GroupModerationViewModel: error approving: $e');
      _setError('Error approving experience: $e');
      return false;
    }
  }

  /// Sets an experience to "Not Published" with a reason and notifies the author
  Future<bool> notPublishExperienceCommand(CcViewPendingExperiencesRow experience, String reason) async {
    final experienceId = experience.id;
    if (experienceId == null) {
      _setError('Error: Experience ID is unknown');
      return false;
    }

    if (reason.trim().isEmpty) {
      _setError('Reason is required');
      return false;
    }

    try {
      debugPrint('GroupModerationViewModel: setting "Not Published" on experience $experienceId');

      await _repository.rejectExperience(experienceId: experienceId, moderatorId: currentUserUid, reason: reason);

      // Notify author (non-blocking)
      final userId = experience.userId;
      if (userId != null) {
        try {
          await _announcementRepository.createRejectionNotification(
            userId: userId,
            experienceId: experienceId,
            experienceTitle: _getPreview(experience),
            reason: reason,
            groupId: groupId,
          );
          debugPrint('GroupModerationViewModel: "Not Published" notification sent');
        } catch (notifError) {
          debugPrint('GroupModerationViewModel: notification failed (non-critical): $notifError');
        }
      }

      await loadExperiences();
      return true;
    } catch (e) {
      debugPrint('GroupModerationViewModel: error setting "Not Published": $e');
      _setError('Error setting "Not Published": $e');
      return false;
    }
  }

  /// Suggests refinement on an experience with feedback and notifies the author
  Future<bool> suggestRefinementCommand(CcViewPendingExperiencesRow experience, String reason) async {
    final experienceId = experience.id;
    if (experienceId == null) {
      _setError('Error: Experience ID is unknown');
      return false;
    }

    if (reason.trim().isEmpty) {
      _setError('Feedback is required');
      return false;
    }

    try {
      debugPrint('GroupModerationViewModel: suggesting refinement on experience $experienceId');

      await _repository.requestChanges(experienceId: experienceId, moderatorId: currentUserUid, reason: reason);

      // Notify author (non-blocking)
      final userId = experience.userId;
      if (userId != null) {
        try {
          await _announcementRepository.createChangesRequestedNotification(
            userId: userId,
            experienceId: experienceId,
            experienceTitle: _getPreview(experience),
            reason: reason,
            groupId: groupId,
          );
          debugPrint('GroupModerationViewModel: refinement suggested notification sent');
        } catch (notifError) {
          debugPrint('GroupModerationViewModel: notification failed (non-critical): $notifError');
        }
      }

      await loadExperiences();
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
