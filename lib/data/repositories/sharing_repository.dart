import '/data/services/supabase/supabase.dart';

/// Repository responsável por todas as operações de dados relacionadas a Sharings e Comentários
/// Segue padrão de arquitetura Compass - camada de dados isolada
class SharingRepository {
  /// Busca um sharing específico por ID com informações do usuário
  ///
  /// Retorna null se o sharing não for encontrado
  Future<CcViewSharingsUsersRow?> getSharingById(int id) async {
    final result = await CcViewSharingsUsersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', id),
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Deleta um sharing e todos os seus comentários associados
  ///
  /// Esta operação é irreversível e remove:
  /// - O sharing da tabela cc_sharings
  /// - Todos os comentários relacionados da tabela cc_comments
  Future<void> deleteSharing(int id) async {
    // Deletar comentários primeiro (foreign key)
    await CcCommentsTable().delete(
      matchingRows: (rows) => rows.eqOrNull('sharing_id', id),
    );

    // Deletar o sharing
    await CcSharingsTable().delete(
      matchingRows: (rows) => rows.eqOrNull('id', id),
    );
  }

  /// Alterna o estado de lock de um sharing
  ///
  /// Quando locked = true, usuários não podem adicionar comentários
  Future<void> toggleSharingLock(int id, bool currentLockState) async {
    await CcSharingsTable().update(
      data: {
        'locked': !currentLockState,
      },
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
    await CcCommentsTable().delete(
      matchingRows: (rows) => rows.eqOrNull('id', commentId),
    );
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
  /// Atualiza título, texto, visibilidade e privacy de um sharing
  Future<void> updateSharing({
    required int id,
    required String title,
    required String text,
    required String visibility,
    required String privacy,
  }) async {
    await CcSharingsTable().update(
      data: {
        'title': title,
        'text': text,
        'updated_at': supaSerialize<DateTime>(DateTime.now()),
        'privacy': privacy,
        'visibility': visibility,
      },
      matchingRows: (rows) => rows.eqOrNull('id', id),
    );
  }

  /// Retorna um stream de sharings para um grupo específico
  Stream<List<CcViewSharingsUsersRow>> getSharingsStream(int groupId) {
    return SupaFlow.client
        .from("cc_view_sharings_users")
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('updated_at')
        .map((list) => list.map((item) => CcViewSharingsUsersRow(item)).toList());
  }

  /// Cria um novo sharing
  ///
  /// Insere um novo sharing no banco de dados com todos os campos necessários
  Future<void> createSharing({
    required String title,
    required String text,
    required String privacy,
    required String userId,
    required String visibility,
    required String type,
    int? groupId,
  }) async {
    await CcSharingsTable().insert({
      'title': title,
      'privacy': privacy,
      'user_id': userId,
      'text': text,
      'group_id': groupId,
      'updated_at': supaSerialize<DateTime>(DateTime.now()),
      'visibility': visibility,
      'type': type,
    });
  }

  /// Busca informações do usuário por auth user ID
  ///
  /// Retorna null se o usuário não for encontrado
  Future<CcMembersRow?> getUserById(String authUserId) async {
    final result = await CcMembersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('auth_user_id', authUserId),
    );
    return result.isNotEmpty ? result.first : null;
  }
}
