import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Repository for managing experience moderation operations
/// Adapted from cott-portal-admin for mobile use
///
/// Handles:
/// - Querying experiences by moderation status
/// - Approving, rejecting, and requesting changes on experiences
/// - Getting groups managed by user (for GROUP_MANAGER role)
class ExperienceModerationRepository {
  // ==========================================================================
  // QUERIES - EXPERIENCES
  // ==========================================================================

  /// Returns all experiences from the pending view
  /// Only returns experiences (type = 'experience'), not notifications
  Future<List<CcViewPendingExperiencesRow>> getAllExperiences() async {
    try {
      final result = await CcViewPendingExperiencesTable().queryRows(
        queryFn: (q) => q.order('created_at', ascending: false),
      );
      debugPrint('ExperienceModerationRepository: loaded ${result.length} experiences');
      return result;
    } catch (e) {
      debugPrint('ExperienceModerationRepository: Error loading experiences: $e');
      return [];
    }
  }

  /// Returns experiences for multiple groups (for group managers)
  /// Only returns experiences (type = 'experience'), not notifications
  Future<List<CcViewPendingExperiencesRow>> getExperiencesForGroups(List<int> groupIds, {String? status}) async {
    if (groupIds.isEmpty) {
      debugPrint('ExperienceModerationRepository: No group IDs provided');
      return [];
    }

    try {
      final result = await CcViewPendingExperiencesTable().queryRows(
        queryFn: (q) {
          var query = q.inFilter('group_id', groupIds);
          if (status != null) {
            query = query.eq('moderation_status', status);
          }
          return query.order('created_at', ascending: false);
        },
      );
      debugPrint('ExperienceModerationRepository: loaded ${result.length} experiences for groups $groupIds');
      return result;
    } catch (e) {
      debugPrint('ExperienceModerationRepository: Query failed: $e');
      return [];
    }
  }

  /// Returns awaiting review experiences for a single group
  Future<List<CcViewPendingExperiencesRow>> getPendingForGroup(int groupId) async {
    return await getExperiencesForGroups([groupId], status: 'awaiting_approval');
  }

  /// Returns count of pending experiences for a group
  Future<int> getPendingCountForGroup(int groupId) async {
    final result = await getPendingForGroup(groupId);
    return result.length;
  }

  /// Returns experiences filtered by status
  Future<List<CcViewPendingExperiencesRow>> getExperiencesByStatus(String status) async {
    return await CcViewPendingExperiencesTable().queryRows(
      queryFn: (q) => q.eq('moderation_status', status).order('created_at', ascending: false),
    );
  }

  // ==========================================================================
  // MODERATION ACTIONS
  // ==========================================================================

  /// Approves an experience
  Future<void> approveExperience({required int experienceId, required String moderatorId}) async {
    debugPrint('approveExperience: updating experienceId=$experienceId');
    await CcSharingsTable().update(
      data: {
        'moderation_status': 'approved',
        'moderation_reason': null,
        'moderated_by': moderatorId,
        'moderated_at': supaSerialize<DateTime>(DateTime.now()),
      },
      matchingRows: (rows) => rows.eq('id', experienceId),
    );
    debugPrint('approveExperience: update completed');
  }

  /// Rejects an experience
  Future<void> rejectExperience({
    required int experienceId,
    required String moderatorId,
    required String reason,
  }) async {
    debugPrint('rejectExperience: updating experienceId=$experienceId');
    await CcSharingsTable().update(
      data: {
        'moderation_status': 'rejected',
        'moderation_reason': reason,
        'moderated_by': moderatorId,
        'moderated_at': supaSerialize<DateTime>(DateTime.now()),
      },
      matchingRows: (rows) => rows.eq('id', experienceId),
    );
    debugPrint('rejectExperience: update completed');
  }

  /// Requests changes on an experience
  Future<void> requestChanges({required int experienceId, required String moderatorId, required String reason}) async {
    debugPrint('requestChanges: updating experienceId=$experienceId');
    await CcSharingsTable().update(
      data: {
        'moderation_status': 'changes_requested',
        'moderation_reason': reason,
        'moderated_by': moderatorId,
        'moderated_at': supaSerialize<DateTime>(DateTime.now()),
      },
      matchingRows: (rows) => rows.eq('id', experienceId),
    );
    debugPrint('requestChanges: update completed');
  }

  // ==========================================================================
  // GROUP MANAGEMENT HELPERS
  // ==========================================================================

  /// Gets group IDs where the user is a manager
  /// Checks the group_managers array field
  Future<List<int>> getGroupsForManager(String userId) async {
    final groups = await CcGroupsTable().queryRows(queryFn: (q) => q.contains('group_managers', [userId]));
    return groups.map((g) => g.id).toList();
  }

  // ==========================================================================
  // DELETE
  // ==========================================================================

  /// Deletes an experience (admin only)
  Future<void> deleteExperience(int experienceId) async {
    debugPrint('deleteExperience: deleting experienceId=$experienceId');
    await CcSharingsTable().delete(matchingRows: (rows) => rows.eq('id', experienceId));
    debugPrint('deleteExperience: delete completed');
  }
}
