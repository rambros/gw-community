import 'package:flutter/foundation.dart';
import 'package:gw_community/data/models/enums/user_role.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/facilitator_group_settings.dart';

class FacilitatorSettingsRepository {
  Future<List<FacilitatorGroupSettings>> load(String userId) async {
    if (userId.isEmpty) return const [];

    final memberships = await CcGroupMembersTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId),
    );
    final facilitated = memberships.where((row) {
      return row.groupId != null &&
          UserRole.fromString(row.userRole) == UserRole.groupManager;
    }).toList();
    if (facilitated.isEmpty) return const [];

    final groupIds = facilitated.map((row) => row.groupId!).toList();
    final groups = await CcGroupsTable().queryRows(
      queryFn: (q) => q.inFilter('id', groupIds),
    );
    final nameById = {for (final group in groups) group.id: group.name ?? ''};

    final saved = await _savedRows(userId);
    return [
      for (final membership in facilitated)
        _merge(
          groupId: membership.groupId!,
          groupName: nameById[membership.groupId] ?? '',
          saved: saved[membership.groupId],
        ),
    ]..sort((a, b) => a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase()));
  }

  Future<void> save(String userId, FacilitatorGroupSettings settings) async {
    await SupaFlow.client.from('cc_facilitator_group_settings').upsert(
      settings.toRow(userId),
      onConflict: 'user_id,group_id',
    );
  }

  /// Missing row means the server defaults: alerts on, experience email off,
  /// member-message email on, digests off.
  Future<bool> messagesEnabled(String userId, int groupId) async {
    final rows = await _savedRows(userId);
    final saved = rows[groupId];
    if (saved == null) return true;
    return saved['notify_messages'] as bool? ?? true;
  }

  Future<Set<int>> groupsWithMessagesOff(String userId) async {
    try {
      final rows = await SupaFlow.client
          .from('cc_facilitator_group_settings')
          .select('group_id')
          .eq('user_id', userId)
          .eq('notify_messages', false);
      return {
        for (final row in rows as List<dynamic>)
          if (row['group_id'] is int) row['group_id'] as int,
      };
    } catch (e) {
      debugPrint('Facilitator message settings unavailable: $e');
      return {};
    }
  }

  Future<Map<int, Map<String, dynamic>>> _savedRows(String userId) async {
    try {
      final rows = await SupaFlow.client
          .from('cc_facilitator_group_settings')
          .select()
          .eq('user_id', userId);
      return {
        for (final row in rows as List<dynamic>)
          if (row['group_id'] is int) row['group_id'] as int: Map<String, dynamic>.from(row as Map),
      };
    } catch (e) {
      debugPrint('Facilitator settings unavailable: $e');
      return {};
    }
  }

  FacilitatorGroupSettings _merge({
    required int groupId,
    required String groupName,
    required Map<String, dynamic>? saved,
  }) {
    if (saved == null) {
      return FacilitatorGroupSettings(groupId: groupId, groupName: groupName);
    }
    return FacilitatorGroupSettings(
      groupId: groupId,
      groupName: groupName,
      notifyNewExperiences: saved['notify_new_experiences'] as bool? ?? true,
      notifyMessages: saved['notify_messages'] as bool? ?? true,
      emailEachExperience: saved['email_each_experience'] as bool? ?? false,
      emailMemberMessage: saved['email_member_message'] as bool? ?? true,
      emailDailySummary: saved['email_daily_summary'] as bool? ?? false,
      emailWeeklySummary: saved['email_weekly_summary'] as bool? ?? false,
    );
  }
}
