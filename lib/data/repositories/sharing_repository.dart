import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Repository responsável por todas as operações de dados relacionadas a Sharings e Comentários
/// Segue padrão de arquitetura Compass - camada de dados isolada
class SharingRepository {
  /// Busca um sharing específico por ID com informações do usuário
  ///
  /// Retorna null se o sharing não for encontrado
  Future<CcViewSharingsUsersRow?> getSharingById(int id) async {
    final result = await CcViewSharingsUsersTable().querySingleRow(queryFn: (q) => q.eqOrNull('id', id));
    return result.isNotEmpty ? result.first : null;
  }

  /// Deleta um sharing e todos os seus comentários associados
  ///
  /// Esta operação é irreversível e remove:
  /// - O sharing da tabela cc_sharings
  /// - Todos os comentários relacionados da tabela cc_comments
  Future<void> deleteSharing(int id) async {
    // Deletar comentários primeiro (foreign key)
    await CcCommentsTable().delete(matchingRows: (rows) => rows.eqOrNull('sharing_id', id));

    // Deletar o sharing
    await CcSharingsTable().delete(matchingRows: (rows) => rows.eqOrNull('id', id));
  }

  /// Alterna o estado de lock de um sharing
  ///
  /// Quando locked = true, usuários não podem adicionar comentários
  Future<void> toggleSharingLock(int id, bool currentLockState) async {
    await CcSharingsTable().update(
      data: {'locked': !currentLockState},
      matchingRows: (rows) => rows.eqOrNull('id', id),
    );
  }

  /// Busca todos os comentários de um sharing ordenados hierarquicamente
  ///
  /// Os comentários são retornados ordenados por sort_path, que mantém
  /// a hierarquia de respostas (parent -> children)
  Future<List<CcViewOrderedCommentsRow>> getComments(int sharingId) async {
    final result = await CcViewOrderedCommentsTable().queryRows(
      queryFn: (q) => q.eqOrNull('sharing_id', sharingId).order('sort_path', ascending: true),
    );
    return result;
  }

  /// Deleta um comentário específico
  ///
  /// Nota: Comentários filhos podem ser afetados dependendo da configuração
  /// do banco de dados (cascade delete)
  Future<void> deleteComment(int commentId) async {
    await CcCommentsTable().delete(matchingRows: (rows) => rows.eqOrNull('id', commentId));
  }

  /// Cria um novo comentário para um sharing específico
  ///
  /// [content] deve ser validado antes de chegar aqui
  Future<void> createComment({
    required String userId,
    required int sharingId,
    required String content,
    int? parentId,
  }) async {
    await CcCommentsTable().insert({
      'user_id': userId,
      'parent_id': parentId,
      'content': content,
      'sharing_id': sharingId,
      'created_at': supaSerialize<DateTime>(DateTime.now()),
      'updated_at': supaSerialize<DateTime>(DateTime.now()),
    });
  }

  /// Atualiza um sharing existente
  ///
  /// Atualiza título, texto, visibilidade e privacy de um sharing.
  /// Se [keepAsDraft] for true, mantém como draft.
  /// Caso contrário, resets moderation_status to 'pending' for re-review.
  Future<void> updateSharing({
    required int id,
    required String title,
    required String text,
    required String visibility,
    required String privacy,
    bool keepAsDraft = false,
  }) async {
    await CcSharingsTable().update(
      data: {
        'title': title,
        'text': text,
        'updated_at': supaSerialize<DateTime>(DateTime.now()),
        'privacy': privacy,
        'visibility': visibility,
        // Keep as draft or reset for re-review
        'moderation_status': keepAsDraft ? 'draft' : 'awaiting_approval',
        'moderation_reason': null,
        'moderated_by': null,
        'moderated_at': null,
      },
      matchingRows: (rows) => rows.eqOrNull('id', id),
    );
  }

  /// Retorna um stream de sharings para um grupo específico
  /// Aplica filtro de moderação: mostra apenas experiências aprovadas ou do próprio usuário
  ///
  /// Nota: Supabase Realtime não funciona com views, então escutamos a tabela real
  /// e re-fazemos a query na view quando há mudanças.
  Stream<List<CcViewSharingsUsersRow>> getSharingsStream(int groupId, {String? currentUserId}) {
    final controller = StreamController<List<CcViewSharingsUsersRow>>();

    // Carrega dados iniciais
    _loadSharingsFromView(groupId, currentUserId).then((data) {
      if (!controller.isClosed) {
        controller.add(data);
      }
    });

    // Escuta mudanças na tabela real (cc_sharings)
    final subscription = SupaFlow.client.from('cc_sharings').stream(primaryKey: ['id']).eq('group_id', groupId).listen((
      _,
    ) async {
      // Quando há mudança, re-carrega da view
      final data = await _loadSharingsFromView(groupId, currentUserId);
      if (!controller.isClosed) {
        controller.add(data);
      }
    });

    // Cleanup quando o stream for cancelado
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream.asBroadcastStream();
  }

  /// Helper para carregar sharings da view com filtro de moderação
  Future<List<CcViewSharingsUsersRow>> _loadSharingsFromView(int groupId, String? currentUserId) async {
    final result = await CcViewSharingsUsersTable().queryRows(
      queryFn: (q) => q.eqOrNull('group_id', groupId).order('updated_at', ascending: false),
    );

    // Filtra: approved OU do próprio usuário OU sem status (legado)
    final filtered = result.where((item) {
      final status = item.moderationStatus;
      final ownerId = item.userId;

      // Mostrar se: aprovado, sem status (legado), ou é do próprio usuário
      final isApproved = status == 'approved' || status == null;
      final isOwner = currentUserId != null && ownerId == currentUserId;

      return isApproved || isOwner;
    }).toList();

    return filtered;
  }

  /// Cria um novo sharing
  ///
  /// Insere um novo sharing no banco de dados com todos os campos necessários.
  /// Se [isDraft] for true, cria com moderation_status = 'draft' (rascunho).
  /// Caso contrário, cria com moderation_status = 'pending' para moderação.
  Future<void> createSharing({
    required String title,
    required String text,
    required String privacy,
    required String userId,
    required String visibility,
    required String type,
    int? groupId,
    bool isDraft = false,
    bool locked = false,
  }) async {
    await CcSharingsTable().insert({
      'title': title,
      'privacy': privacy,
      'user_id': userId,
      'text': text,
      'group_id': groupId,
      'created_at': supaSerialize<DateTime>(DateTime.now()),
      'updated_at': supaSerialize<DateTime>(DateTime.now()),
      'visibility': visibility,
      'type': type,
      'moderation_status': isDraft ? 'draft' : 'awaiting_approval',
      'locked': locked,
    });
  }

  /// Busca informações do usuário por auth user ID
  ///
  /// Retorna null se o usuário não for encontrado
  Future<CcMembersRow?> getUserById(String authUserId) async {
    final result = await CcMembersTable().querySingleRow(queryFn: (q) => q.eqOrNull('auth_user_id', authUserId));
    return result.isNotEmpty ? result.first : null;
  }

  // ==========================================================================
  // MODERATION METHODS
  // ==========================================================================

  /// Submit experience for moderation (sets status to pending)
  Future<bool> submitExperienceForModeration(int experienceId) async {
    try {
      await CcSharingsTable().update(
        data: {
          'moderation_status': 'awaiting_approval',
          'moderated_by': null,
          'moderated_at': null,
          'moderation_reason': null,
        },
        matchingRows: (rows) => rows.eqOrNull('id', experienceId),
      );
      return true;
    } catch (e) {
      debugPrint('Error submitting for moderation: $e');
      return false;
    }
  }

  /// Create new experience with pending moderation status
  Future<int?> createExperienceWithModeration({
    required String title,
    required String text,
    required String privacy,
    required String userId,
    required String visibility,
    int? groupId,
  }) async {
    try {
      final result = await CcSharingsTable().insert({
        'title': title,
        'text': text,
        'privacy': privacy,
        'user_id': userId,
        'group_id': groupId,
        'visibility': visibility,
        'type': 'sharing',
        'moderation_status': 'awaiting_review',
        'locked': false,
        'created_at': supaSerialize<DateTime>(DateTime.now()),
        'updated_at': supaSerialize<DateTime>(DateTime.now()),
      });
      return result.id;
    } catch (e) {
      debugPrint('Error creating experience: $e');
      return null;
    }
  }

  /// Get moderation status for an experience
  Future<Map<String, dynamic>?> getModerationStatus(int experienceId) async {
    try {
      final result = await CcSharingsTable().querySingleRow(queryFn: (q) => q.eqOrNull('id', experienceId));
      if (result.isEmpty) return null;

      final sharing = result.first;
      return {
        'moderation_status': sharing.data['moderation_status'],
        'moderation_reason': sharing.data['moderation_reason'],
        'moderated_at': sharing.data['moderated_at'],
      };
    } catch (e) {
      debugPrint('Error fetching moderation status: $e');
      return null;
    }
  }

  /// Publish a draft experience (changes status from 'draft' to 'pending')
  Future<bool> publishDraft(int experienceId) async {
    try {
      await CcSharingsTable().update(
        data: {'moderation_status': 'awaiting_review', 'updated_at': supaSerialize<DateTime>(DateTime.now())},
        matchingRows: (rows) => rows.eqOrNull('id', experienceId),
      );
      return true;
    } catch (e) {
      debugPrint('Error publishing draft: $e');
      return false;
    }
  }

  /// Update and resubmit experience after changes requested
  Future<bool> resubmitExperience(int experienceId, {String? title, String? text}) async {
    try {
      final updates = <String, dynamic>{
        'moderation_status': 'awaiting_review',
        'moderation_reason': null,
        'moderated_by': null,
        'moderated_at': null,
        'updated_at': supaSerialize<DateTime>(DateTime.now()),
      };

      if (title != null) updates['title'] = title;
      if (text != null) updates['text'] = text;

      await CcSharingsTable().update(data: updates, matchingRows: (rows) => rows.eqOrNull('id', experienceId));
      return true;
    } catch (e) {
      debugPrint('Error resubmitting experience: $e');
      return false;
    }
  }
}
