import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Repository responsável por todas as operações de favoritos
/// Suporta favoritos de recordings (Learn) e activities (Journeys)
///
/// Nota: Os favoritos são vinculados ao member_id (cc_members.id),
/// não diretamente ao auth.users. O authUserId é usado para buscar
/// o member_id correspondente.
class FavoritesRepository {
  /// Tipos de conteúdo suportados
  static const String typeRecording = 'recording';
  static const String typeActivity = 'activity';

  /// Cache do member_id para evitar queries repetidas
  String? _cachedMemberId;
  String? _cachedAuthUserId;

  /// Busca o member_id baseado no auth_user_id
  /// Nota: No banco de dados, a coluna member_id da cc_user_favorites
  /// aponta para cc_members.auth_user_id, não para cc_members.id.
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
        // Usamos o auth_user_id conforme a constraint do banco
        _cachedMemberId = result.first.authUserId;
        _cachedAuthUserId = authUserId;
        return _cachedMemberId;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting member_id: $e');
      return null;
    }
  }

  /// Limpa o cache (útil quando o usuário faz logout)
  void clearCache() {
    _cachedMemberId = null;
    _cachedAuthUserId = null;
  }

  /// Verifica se um item está nos favoritos do usuário
  Future<bool> isFavorite({
    required String authUserId,
    required String contentType,
    required int contentId,
  }) async {
    try {
      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return false;

      final result = await CcUserFavoritesTable().queryRows(
        queryFn: (q) =>
            q.eqOrNull('member_id', memberId).eqOrNull('content_type', contentType).eqOrNull('content_id', contentId),
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking favorite: $e');
      return false;
    }
  }

  /// Adiciona um item aos favoritos
  /// Retorna true se adicionado com sucesso
  Future<bool> addFavorite({
    required String authUserId,
    required String contentType,
    required int contentId,
  }) async {
    try {
      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) {
        debugPrint('Error adding favorite: Member record not found for auth_user_id: $authUserId');
        debugPrint('The user may not have completed profile creation yet.');
        return false;
      }

      debugPrint('Adding favorite: member_id=$memberId, contentType=$contentType, contentId=$contentId');

      await CcUserFavoritesTable().insert({
        'member_id': memberId,
        'content_type': contentType,
        'content_id': contentId,
        'created_at': supaSerialize<DateTime>(DateTime.now()),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      debugPrint('This may indicate a database constraint issue or the member record may be missing.');
      return false;
    }
  }

  /// Remove um item dos favoritos
  /// Retorna true se removido com sucesso
  Future<bool> removeFavorite({
    required String authUserId,
    required String contentType,
    required int contentId,
  }) async {
    try {
      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return false;

      await CcUserFavoritesTable().delete(
        matchingRows: (rows) => rows
            .eqOrNull('member_id', memberId)
            .eqOrNull('content_type', contentType)
            .eqOrNull('content_id', contentId),
      );
      return true;
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      return false;
    }
  }

  /// Alterna o estado de favorito de um item
  /// Retorna o novo estado (true = favorito, false = não favorito)
  Future<bool> toggleFavorite({
    required String authUserId,
    required String contentType,
    required int contentId,
  }) async {
    final currentlyFavorite = await isFavorite(
      authUserId: authUserId,
      contentType: contentType,
      contentId: contentId,
    );

    if (currentlyFavorite) {
      await removeFavorite(
        authUserId: authUserId,
        contentType: contentType,
        contentId: contentId,
      );
      return false;
    } else {
      await addFavorite(
        authUserId: authUserId,
        contentType: contentType,
        contentId: contentId,
      );
      return true;
    }
  }

  /// Retorna um Set com os IDs de todos os favoritos de um tipo para um usuário
  /// Útil para verificação rápida em listas
  Future<Set<int>> getFavoriteIds({
    required String authUserId,
    required String contentType,
  }) async {
    try {
      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return {};

      final result = await CcUserFavoritesTable().queryRows(
        queryFn: (q) => q.eqOrNull('member_id', memberId).eqOrNull('content_type', contentType),
      );
      return result.map((row) => row.contentId!).toSet();
    } catch (e) {
      debugPrint('Error getting favorite IDs: $e');
      return {};
    }
  }

  /// Busca todos os recordings favoritos do usuário
  Future<List<CcViewUserFavoriteRecordingsRow>> getFavoriteRecordings(
    String authUserId,
  ) async {
    try {
      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return [];

      final result = await CcViewUserFavoriteRecordingsTable().queryRows(
        queryFn: (q) => q.eqOrNull('member_id', memberId).order('favorited_at', ascending: false),
      );
      return result;
    } catch (e) {
      debugPrint('Error getting favorite recordings: $e');
      return [];
    }
  }

  /// Busca todas as activities favoritas do usuário
  Future<List<CcViewUserFavoriteActivitiesRow>> getFavoriteActivities(
    String authUserId,
  ) async {
    try {
      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return [];

      final result = await CcViewUserFavoriteActivitiesTable().queryRows(
        queryFn: (q) => q.eqOrNull('member_id', memberId).order('favorited_at', ascending: false),
      );
      return result;
    } catch (e) {
      debugPrint('Error getting favorite activities: $e');
      return [];
    }
  }

  /// Conta o total de favoritos de um usuário
  Future<int> getFavoritesCount(String authUserId) async {
    try {
      final memberId = await getMemberIdByAuthUserId(authUserId);
      if (memberId == null) return 0;

      final result = await CcUserFavoritesTable().queryRows(
        queryFn: (q) => q.eqOrNull('member_id', memberId),
      );
      return result.length;
    } catch (e) {
      debugPrint('Error counting favorites: $e');
      return 0;
    }
  }
}
