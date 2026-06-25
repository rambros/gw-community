import 'package:flutter/foundation.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class FileResourceRepository {
  // ==========================================================================
  // QUERIES
  // ==========================================================================

  Future<List<CcFileResourcesRow>> getFileResourcesForGroup(
    int groupId, {
    bool publishedOnly = true,
  }) async {
    try {
      final junctionRows = await CcFileResourceGroupsTable().queryRows(
        queryFn: (q) => q.eq('group_id', groupId),
      );
      if (junctionRows.isEmpty) return [];

      final resourceIds = junctionRows.map((r) => r.resourceId).toList();
      final rows = await CcFileResourcesTable().queryRows(
        queryFn: (q) => q
            .inFilter('id', resourceIds)
            .order('created_at', ascending: false),
      );

      if (publishedOnly) {
        return rows.where((r) => r.status == 'published').toList();
      }
      return rows;
    } catch (e) {
      debugPrint('FileResourceRepository.getFileResourcesForGroup: $e');
      return [];
    }
  }

  Future<CcFileResourcesRow?> getResourceById(int id) async {
    try {
      final rows = await CcFileResourcesTable().querySingleRow(
        queryFn: (q) => q.eq('id', id),
      );
      return rows.isNotEmpty ? rows.first : null;
    } catch (e) {
      debugPrint('FileResourceRepository.getResourceById: $e');
      return null;
    }
  }

  Future<int> getGroupCountForResource(int resourceId) async {
    try {
      final rows = await CcFileResourceGroupsTable().queryRows(
        queryFn: (q) => q.eq('resource_id', resourceId),
      );
      return rows.length;
    } catch (e) {
      return 0;
    }
  }

  /// Returns group IDs where the user holds a GROUP_MANAGER role.
  Future<List<int>> getManagedGroupIds(String userId) async {
    try {
      final rows = await CcGroupMembersTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId),
      );
      return rows
          .where((r) => UserRole.fromString(r.userRole) == UserRole.groupManager)
          .map((r) => r.groupId)
          .whereType<int>()
          .toList();
    } catch (e) {
      debugPrint('FileResourceRepository.getManagedGroupIds: $e');
      return [];
    }
  }

  /// Returns all groups ordered by name (for admins).
  Future<List<CcGroupsRow>> getAllGroups() async {
    try {
      return await CcGroupsTable().queryRows(
        queryFn: (q) => q.order('name', ascending: true),
      );
    } catch (e) {
      debugPrint('FileResourceRepository.getAllGroups: $e');
      return [];
    }
  }

  /// Returns group IDs currently linked to a portal item (non-deleted).
  Future<List<int>> getLinkedGroupIds(int portalItemId) async {
    try {
      final result = await SupaFlow.client
          .from('cc_group_resources')
          .select('group_id')
          .eq('portal_item_id', portalItemId)
          .isFilter('deleted_at', null);
      return (result as List).map((r) => r['group_id'] as int).toList();
    } catch (e) {
      debugPrint('FileResourceRepository.getLinkedGroupIds: $e');
      return [];
    }
  }

  // ==========================================================================
  // PORTAL ITEM LINK / UNLINK
  // ==========================================================================

  /// Dual-write: links a portal item to groups via both cc_file_resources
  /// (mobile Resources tab) and cc_group_resources (Library group filter).
  /// [toAddGroupIds] / [toRemoveGroupIds] are the diff from current state.
  Future<bool> linkPortalItemToGroups({
    required int portalItemId,
    required String title,
    String? description,
    required String url,
    required String type,
    bool isPublished = false,
    DateTime? datePublished,
    required List<int> toAddGroupIds,
    required List<int> toRemoveGroupIds,
    required String userId,
  }) async {
    try {
      int? resourceId;

      if (toAddGroupIds.isNotEmpty) {
        // Find or create the cc_file_resources entry for this portal item.
        final existing = await CcFileResourcesTable().queryRows(
          queryFn: (q) => q.eq('portal_item_id', portalItemId),
        );
        if (existing.isNotEmpty) {
          resourceId = existing.first.id;
          // Update description/title in case content changed since last link
          if (description != null && description.isNotEmpty) {
            final now = DateTime.now().toUtc().toIso8601String();
            await CcFileResourcesTable().update(
              data: {
                'title': title,
                'description': description,
                'updated_at': now,
              },
              matchingRows: (q) => q.eq('id', resourceId!),
            );
          }
        } else {
          final now = DateTime.now().toUtc().toIso8601String();
          final row = await CcFileResourcesTable().insert({
            'title': title,
            if (description != null && description.isNotEmpty)
              'description': description,
            'url': url,
            'type': type,
            'portal_item_id': portalItemId,
            'status': isPublished ? 'published' : 'draft',
            if (datePublished != null)
              'published_at': datePublished.toUtc().toIso8601String(),
            'created_by': userId,
            'created_at': now,
            'updated_at': now,
          });
          resourceId = row.id;
        }

        for (final groupId in toAddGroupIds) {
          // cc_file_resource_groups (mobile Resources tab)
          final existingFG = await CcFileResourceGroupsTable().queryRows(
            queryFn: (q) =>
                q.eq('resource_id', resourceId!).eq('group_id', groupId),
          );
          if (existingFG.isEmpty) {
            await CcFileResourceGroupsTable().insert({
              'resource_id': resourceId,
              'group_id': groupId,
              'added_by': userId,
              'created_at': DateTime.now().toUtc().toIso8601String(),
            });
          }

          // cc_group_resources (Library group filter) — upsert to restore soft-deletes
          await SupaFlow.client.from('cc_group_resources').upsert(
            {
              'portal_item_id': portalItemId,
              'group_id': groupId,
              'visibility': 'public',
              'added_by': userId,
              'created_by': userId,
              'display_order': 0,
              'deleted_at': null,
            },
            onConflict: 'portal_item_id,group_id',
          );
        }
      }

      for (final groupId in toRemoveGroupIds) {
        // cc_group_resources: soft delete
        await SupaFlow.client
            .from('cc_group_resources')
            .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
            .eq('portal_item_id', portalItemId)
            .eq('group_id', groupId);

        // cc_file_resource_groups: hard delete
        if (resourceId == null) {
          final existing = await CcFileResourcesTable().queryRows(
            queryFn: (q) => q.eq('portal_item_id', portalItemId),
          );
          if (existing.isNotEmpty) resourceId = existing.first.id;
        }
        if (resourceId != null) {
          await CcFileResourceGroupsTable().delete(
            matchingRows: (q) =>
                q.eq('resource_id', resourceId!).eq('group_id', groupId),
          );
        }
      }

      return true;
    } catch (e, st) {
      debugPrint('FileResourceRepository.linkPortalItemToGroups: $e\n$st');
      return false;
    }
  }

  /// Unlinks a portal-linked resource from a group.
  /// Soft-deletes from cc_group_resources and removes from cc_file_resource_groups.
  /// Deletes the cc_file_resources row if no groups remain.
  Future<bool> unlinkPortalItemFromGroup({
    required int resourceId,
    required int groupId,
    required int portalItemId,
  }) async {
    try {
      // cc_group_resources: soft delete
      await SupaFlow.client
          .from('cc_group_resources')
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
          .eq('portal_item_id', portalItemId)
          .eq('group_id', groupId);

      // cc_file_resource_groups: hard delete
      await CcFileResourceGroupsTable().delete(
        matchingRows: (q) =>
            q.eq('resource_id', resourceId).eq('group_id', groupId),
      );

      // Clean up cc_file_resources if no groups remain
      final remaining = await getGroupCountForResource(resourceId);
      if (remaining == 0) {
        await CcFileResourcesTable().delete(
          matchingRows: (q) => q.eq('id', resourceId),
        );
      }

      return true;
    } catch (e) {
      debugPrint('FileResourceRepository.unlinkPortalItemFromGroup: $e');
      return false;
    }
  }

  // ==========================================================================
  // CRUD
  // ==========================================================================

  Future<bool> createFileResource({
    required String title,
    String? description,
    required String url,
    required String type,
    required int groupId,
    required String createdBy,
  }) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final row = await CcFileResourcesTable().insert({
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
        'url': url,
        'type': type,
        'status': 'draft',
        'created_by': createdBy,
        'created_at': now,
        'updated_at': now,
      });

      await CcFileResourceGroupsTable().insert({
        'resource_id': row.id,
        'group_id': groupId,
        'added_by': createdBy,
        'created_at': now,
      });
      return true;
    } catch (e) {
      debugPrint('FileResourceRepository.createFileResource: $e');
      return false;
    }
  }

  Future<bool> updateFileResource(
    int id, {
    String? title,
    String? description,
    String? url,
    String? status,
  }) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final data = <String, dynamic>{'updated_at': now};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (url != null) data['url'] = url;
      if (status != null) {
        data['status'] = status;
        if (status == 'published') data['published_at'] = now;
      }
      await CcFileResourcesTable().update(
        data: data,
        matchingRows: (q) => q.eq('id', id),
      );
      return true;
    } catch (e) {
      debugPrint('FileResourceRepository.updateFileResource: $e');
      return false;
    }
  }

  /// Remove o recurso do grupo. Se for o último grupo, deleta o arquivo e o registro.
  Future<bool> deleteFileResource(int resourceId, int groupId) async {
    try {
      final count = await getGroupCountForResource(resourceId);
      if (count > 1) {
        await CcFileResourceGroupsTable().delete(
          matchingRows: (q) =>
              q.eq('resource_id', resourceId).eq('group_id', groupId),
        );
      } else {
        final resource = await getResourceById(resourceId);
        if (resource != null) {
          try {
            await deleteSupabaseFileFromPublicUrl(resource.url);
          } catch (e) {
            debugPrint('FileResourceRepository: storage delete failed: $e');
          }
        }
        await CcFileResourcesTable().delete(
          matchingRows: (q) => q.eq('id', resourceId),
        );
      }
      return true;
    } catch (e) {
      debugPrint('FileResourceRepository.deleteFileResource: $e');
      return false;
    }
  }

  // ==========================================================================
  // STORAGE
  // ==========================================================================

  Future<String?> uploadFile(
    Uint8List bytes,
    String filename,
    String type,
  ) async {
    try {
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final storagePath = 'resources/${timestamp}_$filename';

      final bucket = SupaFlow.client.storage.from('portal');
      await bucket.uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(contentType: null),
      );
      return bucket.getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('FileResourceRepository.uploadFile: $e');
      return null;
    }
  }
}
