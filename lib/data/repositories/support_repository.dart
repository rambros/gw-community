import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Repository for managing Help Center support requests and messages
///
/// Handles:
/// - Creating and managing support requests (questions)
/// - Sending and receiving messages
/// - Real-time message streams
/// - Status updates
class SupportRepository {
  // ==================== MEMBER ID CACHE ====================

  /// Cache do member_id para evitar queries repetidas
  String? _cachedMemberId;
  String? _cachedAuthUserId;

  /// Busca o member_id baseado no auth_user_id
  Future<String?> getMemberIdByAuthUserId(String authUserId) async {
    // Retorna do cache se disponível
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
      debugPrint('Error getting member_id: $e');
      return null;
    }
  }

  /// Limpa o cache do member_id
  void clearMemberIdCache() {
    _cachedMemberId = null;
    _cachedAuthUserId = null;
  }

  // ==================== REQUESTS ====================

  /// Get all support requests for current user
  Future<List<CcSupportRequestsRow>> getMyRequests() async {
    try {
      final authUserId = SupaFlow.client.auth.currentUser?.id;
      if (authUserId == null) return [];

      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return [];

      return await CcSupportRequestsTable().queryRows(
        queryFn: (q) => q.eq('member_id', memberId).order('updated_at', ascending: false),
      );
    } catch (e) {
      debugPrint('Error fetching support requests: $e');
      return [];
    }
  }

  /// Get requests filtered by status
  Future<List<CcSupportRequestsRow>> getMyRequestsByStatus(String status) async {
    try {
      final authUserId = SupaFlow.client.auth.currentUser?.id;
      if (authUserId == null) return [];

      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return [];

      return await CcSupportRequestsTable().queryRows(
        queryFn: (q) => q
            .eq('member_id', memberId)
            .eq('status', status)
            .order('updated_at', ascending: false),
      );
    } catch (e) {
      debugPrint('Error fetching support requests by status: $e');
      return [];
    }
  }

  /// Get open requests (not resolved)
  Future<List<CcSupportRequestsRow>> getMyOpenRequests() async {
    try {
      final authUserId = SupaFlow.client.auth.currentUser?.id;
      if (authUserId == null) return [];

      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return [];

      return await CcSupportRequestsTable().queryRows(
        queryFn: (q) => q
            .eq('member_id', memberId)
            .neq('status', 'resolved')
            .order('updated_at', ascending: false),
      );
    } catch (e) {
      debugPrint('Error fetching open support requests: $e');
      return [];
    }
  }

  /// Get a single request by ID
  Future<CcSupportRequestsRow?> getRequestById(int id) async {
    try {
      final result = await CcSupportRequestsTable().querySingleRow(
        queryFn: (q) => q.eq('id', id),
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Error fetching support request: $e');
      return null;
    }
  }

  /// Create a new support request
  Future<CcSupportRequestsRow?> createRequest({
    required String title,
    required String description,
    required String category,
    String? contextType,
    int? contextId,
    String? contextTitle,
  }) async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null) return null;

      final memberId = await getMemberIdByAuthUserId(user.id);
      if (memberId == null) return null;

      final data = {
        'title': title,
        'description': description,
        'category': category,
        'member_id': memberId,
        'user_name': user.userMetadata?['full_name'] ?? user.userMetadata?['display_name'] ?? 'User',
        'user_email': user.email,
        'status': 'open',
        'priority': 'normal',
        if (contextType != null) 'context_type': contextType,
        if (contextId != null) 'context_id': contextId,
        if (contextTitle != null) 'context_title': contextTitle,
      };

      final result = await CcSupportRequestsTable().insert(data);
      return result;
    } catch (e) {
      debugPrint('Error creating support request: $e');
      return null;
    }
  }

  /// Update request status (user can mark as resolved or reopen)
  Future<bool> updateRequestStatus(int requestId, String status) async {
    try {
      final data = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == 'resolved') {
        data['resolved_at'] = DateTime.now().toIso8601String();
      } else if (status == 'open') {
        data['resolved_at'] = null;
      }

      await CcSupportRequestsTable().update(
        data: data,
        matchingRows: (rows) => rows.eq('id', requestId),
      );
      return true;
    } catch (e) {
      debugPrint('Error updating request status: $e');
      return false;
    }
  }

  /// Mark request as resolved by user
  Future<bool> markAsResolved(int requestId) async {
    return updateRequestStatus(requestId, 'resolved');
  }

  /// Reopen a resolved request
  Future<bool> reopenRequest(int requestId) async {
    return updateRequestStatus(requestId, 'open');
  }

  /// Delete a request
  Future<bool> deleteRequest(int requestId) async {
    try {
      await CcSupportRequestsTable().delete(
        matchingRows: (rows) => rows.eq('id', requestId),
      );
      return true;
    } catch (e) {
      debugPrint('Error deleting support request: $e');
      return false;
    }
  }

  /// Stream of user's requests for real-time updates
  /// Nota: Este método precisa do member_id já cacheado para funcionar
  Stream<List<CcSupportRequestsRow>> watchMyRequests() {
    // Usa o member_id cacheado (deve ser chamado após alguma operação que popule o cache)
    if (_cachedMemberId == null) return Stream.value([]);

    return SupaFlow.client
        .from('cc_support_requests')
        .stream(primaryKey: ['id'])
        .eq('member_id', _cachedMemberId!)
        .order('updated_at', ascending: false)
        .map((list) => list.map((item) => CcSupportRequestsRow(item)).toList());
  }

  /// Get count of open requests
  Future<int> getOpenRequestCount() async {
    try {
      final authUserId = SupaFlow.client.auth.currentUser?.id;
      if (authUserId == null) return 0;

      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return 0;

      final requests = await CcSupportRequestsTable().queryRows(
        queryFn: (q) => q.eq('member_id', memberId).neq('status', 'resolved'),
      );
      return requests.length;
    } catch (e) {
      debugPrint('Error fetching open request count: $e');
      return 0;
    }
  }

  // ==================== MESSAGES ====================

  /// Get all messages for a request
  Future<List<CcSupportMessagesRow>> getMessages(int requestId) async {
    try {
      return await CcSupportMessagesTable().queryRows(
        queryFn: (q) => q.eq('request_id', requestId).order('created_at', ascending: true),
      );
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      return [];
    }
  }

  /// Send a new message
  Future<CcSupportMessagesRow?> sendMessage({
    required int requestId,
    required String content,
    String? imageUrl,
    String? imageName,
  }) async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null) return null;

      final memberId = await getMemberIdByAuthUserId(user.id);
      if (memberId == null) return null;

      final data = {
        'request_id': requestId,
        'content': content,
        'author_id': memberId,
        'author_name': user.userMetadata?['full_name'] ?? user.userMetadata?['display_name'] ?? 'User',
        'author_type': 'user',
        'author_photo': user.userMetadata?['photo_url'],
        if (imageUrl != null) 'image_url': imageUrl,
        if (imageName != null) 'image_name': imageName,
      };

      final result = await CcSupportMessagesTable().insert(data);
      return result;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return null;
    }
  }

  /// Stream of messages for real-time updates
  Stream<List<CcSupportMessagesRow>> watchMessages(int requestId) {
    return SupaFlow.client
        .from('cc_support_messages')
        .stream(primaryKey: ['id'])
        .eq('request_id', requestId)
        .order('created_at', ascending: true)
        .map((list) => list.map((item) => CcSupportMessagesRow(item)).toList());
  }

  /// Mark messages as read
  Future<bool> markMessagesAsRead(int requestId) async {
    try {
      final authUserId = SupaFlow.client.auth.currentUser?.id;
      if (authUserId == null) return false;

      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return false;

      // Only mark admin messages as read (user already knows their own messages)
      await CcSupportMessagesTable().update(
        data: {'is_read': true},
        matchingRows: (rows) => rows
            .eq('request_id', requestId)
            .neq('author_id', memberId)
            .eq('is_read', false),
      );
      return true;
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      return false;
    }
  }

  /// Get unread message count for a request
  Future<int> getUnreadMessageCount(int requestId) async {
    try {
      final authUserId = SupaFlow.client.auth.currentUser?.id;
      if (authUserId == null) return 0;

      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return 0;

      final messages = await CcSupportMessagesTable().queryRows(
        queryFn: (q) => q
            .eq('request_id', requestId)
            .neq('author_id', memberId)
            .eq('is_read', false),
      );
      return messages.length;
    } catch (e) {
      debugPrint('Error fetching unread message count: $e');
      return 0;
    }
  }

  // ==================== IMAGE UPLOAD ====================

  /// Upload an image for a message
  Future<String?> uploadMessageImage(String filePath, String fileName) async {
    try {
      final authUserId = SupaFlow.client.auth.currentUser?.id;
      if (authUserId == null) return null;

      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'support/$memberId/$timestamp-$fileName';

      // Read file and upload
      final file = await SupabaseStorageService().uploadFileFromPath(
        filePath,
        storagePath,
        'support-attachments',
      );

      return file;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}

/// Helper class for storage operations
class SupabaseStorageService {
  Future<String?> uploadFileFromPath(
    String filePath,
    String storagePath,
    String bucket,
  ) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      await SupaFlow.client.storage.from(bucket).uploadBinary(storagePath, bytes);

      // Get public URL
      final publicUrl = SupaFlow.client.storage.from(bucket).getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }
}
