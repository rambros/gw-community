import 'package:flutter/foundation.dart';

import 'package:gw_community/data/services/supabase/database/tables/cc_settings.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class CommunityRepository {
  // ==================== MEMBER ID CACHE ====================
  String? _cachedMemberId;
  String? _cachedAuthUserId;

  /// Busca o member_id baseado no auth_user_id (da cc_members)
  Future<String?> getMemberIdByAuthUserId(String authUserId) async {
    if (_cachedAuthUserId == authUserId && _cachedMemberId != null) {
      return _cachedMemberId;
    }

    try {
      final result = await CcMembersTable().querySingleRow(
        queryFn: (q) => q.eqOrNull('auth_user_id', authUserId),
      );

      if (result.isNotEmpty) {
        _cachedMemberId = result.first.id;
        _cachedAuthUserId = authUserId;
        return _cachedMemberId;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting member_id in CommunityRepository: $e');
      return null;
    }
  }

  /// Stream de experiences visíveis para todos
  /// Mostra experiências aprovadas + experiências do próprio usuário (qualquer status)
  Stream<List<CcViewSharingsUsersRow>> getExperiencesStream({String? currentUserId}) {
    return SupaFlow.client
        .from("cc_view_experiences_users")
        .stream(primaryKey: ['id'])
        .eq('visibility', 'everyone')
        .order('updated_at', ascending: false)
        .map((list) {
          // Filtra: approved OU do próprio usuário OU sem status (legado)
          final filtered = list.where((item) {
            final status = item['moderation_status'] as String?;
            final ownerId = item['user_id']?.toString();

            // Mostrar se: aprovado, sem status (legado), ou é do próprio usuário
            final isApproved = status == 'approved' || status == null;
            final isOwner = currentUserId != null && ownerId == currentUserId;

            return isApproved || isOwner;
          }).toList();
          return filtered.map((item) => CcViewSharingsUsersRow(item)).toList();
        });
  }

  /// Stream de experiences do próprio usuário (inclui pending, changes_requested, etc)
  Stream<List<CcViewSharingsUsersRow>> getMyExperiencesStream(String userId) {
    return SupaFlow.client
        .from("cc_view_experiences_users")
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('updated_at', ascending: false)
        .map((list) => list.map((item) => CcViewSharingsUsersRow(item)).toList());
  }

  Future<List<CcEventsRow>> getEvents(String currentUserUid) async {
    try {
      final response = await SupaFlow.client.rpc(
        'get_user_events',
        params: {
          'user_id_input': currentUserUid,
        },
      );
      if (response is List) {
        return response.map((row) => CcEventsRow(row as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // ignore error
    }
    return [];
  }

  Future<List<CcGroupsRow>> getAvailableGroups(String currentUserUid) async {
    final response = await SupaFlow.client.rpc(
      'get_available_groups',
      params: {
        'user_input': currentUserUid,
      },
    );

    if (response is List) {
      return response.map((row) => CcGroupsRow(row as Map<String, dynamic>)).where((group) {
        final privacy = group.groupPrivacy?.toLowerCase().trim();
        // Aceita 'public' ou null (padrão legado como público)
        return privacy == 'public' || group.groupPrivacy == null;
      }).toList();
    }
    return [];
  }

  Future<List<CcGroupsRow>> getMyGroups(String currentUserUid) async {
    final response = await SupaFlow.client.rpc(
      'get_my_groups',
      params: {
        'user_input': currentUserUid,
      },
    );

    if (response is List) {
      final groups = response.map((row) => CcGroupsRow(row as Map<String, dynamic>)).toList();
      return groups;
    }
    return [];
  }

  Future<void> deleteExperience(int id) async {
    await CcSharingsTable().delete(
      matchingRows: (rows) => rows.eqOrNull(
        'id',
        id,
      ),
    );
  }

  static const String _englishKey = 'community_guidelines';
  static const String _portugueseKey = 'community_guidelines_pt';

  /// Fetches the guidelines version that matches [languageCode].
  Future<String?> getCommunityGuidelines({required String languageCode}) async {
    final versions = await getCommunityGuidelinesVersions();
    return versions.resolve(languageCode);
  }

  Future<CommunityGuidelinesVersions> getCommunityGuidelinesVersions() async {
    try {
      final rows = await CcSettingsTable().queryRows(
        queryFn: (q) => q.inFilter('setting_key', [_englishKey, _portugueseKey]),
      );

      return CommunityGuidelinesVersions(
        english: _valueFor(rows, _englishKey),
        portuguese: _valueFor(rows, _portugueseKey),
      );
    } catch (e) {
      debugPrint('❌ [Guidelines] Error fetching: $e');
      return const CommunityGuidelinesVersions();
    }
  }

  Future<void> updateCommunityGuidelinesVersions({
    required String english,
    required String portuguese,
  }) async {
    try {
      await _upsertGuidelineSetting(
        key: _englishKey,
        name: 'Community Guidelines',
        description: 'English community guidelines and policy.',
        content: english,
      );
      await _upsertGuidelineSetting(
        key: _portugueseKey,
        name: 'Community Guidelines (PT)',
        description: 'Portuguese community guidelines and policy.',
        content: portuguese,
      );
    } catch (e) {
      debugPrint('Error updating community guidelines: $e');
      throw Exception('Failed to update community guidelines: $e');
    }
  }

  String? _valueFor(List<CcSettingsRow> rows, String key) {
    for (final row in rows) {
      if (row.settingKey == key) return row.value;
    }
    return null;
  }

  Future<void> _upsertGuidelineSetting({
    required String key,
    required String name,
    required String description,
    required String content,
  }) async {
    final rows = await CcSettingsTable().queryRows(
      queryFn: (q) => q.eq('setting_key', key),
    );
    final now = DateTime.now().toIso8601String();

    if (rows.isNotEmpty) {
      await SupaFlow.client.from('cc_settings').update({
        'value': content,
        'updated_at': now,
      }).eq('setting_key', key);
      return;
    }

    await SupaFlow.client.from('cc_settings').insert({
      'setting_key': key,
      'setting_name': name,
      'description': description,
      'value': content,
      'value_type': 'string',
      'category': 'community',
      'is_active': true,
      'is_encrypted': false,
      'created_at': now,
      'updated_at': now,
    });
  }
}
