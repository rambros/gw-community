import 'package:flutter/material.dart';
import '/data/services/supabase/supabase.dart';
import '/data/repositories/sharing_repository.dart';
import '/app_state.dart';

/// ViewModel para a página de visualização de Sharing
/// Gerencia estado, lógica de negócio e ações do usuário
/// Segue padrão MVVM estilo Compass
class SharingViewViewModel extends ChangeNotifier {
  final SharingRepository _repository;
  final String currentUserUid;
  final FFAppState appState;

  SharingViewViewModel({
    required SharingRepository repository,
    required this.currentUserUid,
    required this.appState,
  }) : _repository = repository;

  // ========== STATE ==========

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CcViewSharingsUsersRow? _sharing;
  CcViewSharingsUsersRow? get sharing => _sharing;

  List<CcViewOrderedCommentsRow> _comments = [];
  List<CcViewOrderedCommentsRow> get comments => _comments;

  // ========== INITIALIZATION ==========

  /// Carrega o sharing e seus comentários
  Future<void> loadSharing(int sharingId) async {
    _setLoading(true);
    _clearError();

    try {
      // Carregar sharing e comentários em paralelo
      final sharingResult = await _repository.getSharingById(sharingId);
      final commentsResult = await _repository.getComments(sharingId);

      _sharing = sharingResult;
      _comments = commentsResult;

      if (_sharing == null) {
        _setError('Sharing não encontrado');
      }

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar sharing: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== COMMANDS (User Actions) ==========

  /// Deleta o sharing atual após confirmação
  /// Navega de volta para a página de comunidade após deletar
  Future<void> deleteSharingCommand(BuildContext context, int sharingId) async {
    if (!canDelete()) {
      _setError('Você não tem permissão para deletar este sharing');
      return;
    }

    try {
      await _repository.deleteSharing(sharingId);

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _setError('Erro ao deletar sharing: $e');
    }
  }

  /// Alterna o estado de lock do sharing
  /// Quando locked, usuários não podem comentar
  Future<void> toggleLockCommand(int sharingId) async {
    if (!canLock()) {
      _setError('Você não tem permissão para bloquear este sharing');
      return;
    }

    if (_sharing == null) return;

    try {
      await _repository.toggleSharingLock(sharingId, _sharing!.locked ?? false);

      // Recarregar sharing para obter estado atualizado
      await loadSharing(sharingId);
    } catch (e) {
      _setError('Erro ao alterar bloqueio: $e');
    }
  }

  /// Deleta um comentário específico
  /// Recarrega a lista de comentários após deletar
  Future<void> deleteCommentCommand(int commentId, int sharingId) async {
    try {
      await _repository.deleteComment(commentId);

      // Recarregar comentários
      _comments = await _repository.getComments(sharingId);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao deletar comentário: $e');
    }
  }

  /// Recarrega apenas os comentários
  /// Útil após adicionar um novo comentário
  Future<void> refreshComments(int sharingId) async {
    try {
      _comments = await _repository.getComments(sharingId);

      // Atualizar também o contador de comentários no sharing
      _sharing = await _repository.getSharingById(sharingId);

      notifyListeners();
    } catch (e) {
      _setError('Erro ao recarregar comentários: $e');
    }
  }

  // ========== VALIDATIONS ==========

  /// Verifica se o usuário atual pode deletar o sharing
  /// Pode deletar se for o autor OU se for admin
  bool canDelete() {
    if (_sharing == null) return false;

    return _sharing!.userId == currentUserUid || _isAdmin();
  }

  /// Verifica se o usuário atual pode fazer lock/unlock do sharing
  /// Pode fazer lock se for o autor OU se for admin
  bool canLock() {
    if (_sharing == null) return false;

    return _sharing!.userId == currentUserUid || _isAdmin();
  }

  /// Verifica se o usuário atual pode deletar um comentário específico
  /// Pode deletar se for o autor do comentário OU se for admin
  bool canDeleteComment(String commentUserId) {
    return commentUserId == currentUserUid || _isAdmin();
  }

  /// Verifica se o sharing está bloqueado para comentários
  bool isLocked() {
    return _sharing?.locked ?? false;
  }

  /// Verifica se o usuário atual é administrador
  bool _isAdmin() {
    return appState.loginUser.roles.contains('Admin');
  }

  // ========== HELPER METHODS ==========

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
