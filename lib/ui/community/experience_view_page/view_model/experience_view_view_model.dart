import 'package:flutter/material.dart';

import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/experience_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// ViewModel para a página de visualização de Experience
/// Gerencia estado, lógica de negócio e ações do usuário
/// Segue padrão MVVM estilo Compass
class ExperienceViewViewModel extends ChangeNotifier {
  final ExperienceRepository _repository;
  final FFAppState appState;

  ExperienceViewViewModel({
    required ExperienceRepository repository,
    required this.appState,
  }) : _repository = repository;

  /// Gets the current user ID dynamically from Supabase auth
  String get currentUserUid => SupaFlow.client.auth.currentUser?.id ?? '';

  // ========== STATE ==========

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CcViewSharingsUsersRow? _experience;
  CcViewSharingsUsersRow? get experience => _experience;

  List<CcViewOrderedCommentsRow> _comments = [];
  List<CcViewOrderedCommentsRow> get comments => _comments;

  // ========== INITIALIZATION ==========

  /// Carrega o experience e seus comentários
  Future<void> loadExperience(int experienceId) async {
    _setLoading(true);
    _clearError();

    try {
      // Carregar experience e comentários em paralelo
      final experienceResult = await _repository.getExperienceById(experienceId);
      final commentsResult = await _repository.getComments(experienceId);

      _experience = experienceResult;
      _comments = commentsResult;

      if (_experience == null) {
        _setError('Experience not found');
      }

      notifyListeners();
    } catch (e) {
      _setError('Error loading experience: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== COMMANDS (User Actions) ==========

  /// Deleta o experience atual após confirmação
  /// Navega de volta para a página de comunidade após deletar
  Future<void> deleteExperienceCommand(BuildContext context, int experienceId) async {
    if (!canDelete()) {
      _setError('You do not have permission to delete this experience');
      return;
    }

    try {
      await _repository.deleteExperience(experienceId);

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _setError('Error deleting experience: $e');
    }
  }

  /// Alterna o estado de lock do experience
  /// Quando locked, usuários não podem comentar
  Future<void> toggleLockCommand(int experienceId) async {
    if (!canLock()) {
      _setError('You do not have permission to lock this experience');
      return;
    }

    if (_experience == null) return;

    try {
      await _repository.toggleExperienceLock(experienceId, _experience!.locked ?? false);

      // Recarregar experience para obter estado atualizado
      await loadExperience(experienceId);
    } catch (e) {
      _setError('Error toggling lock: $e');
    }
  }

  /// Deleta um comentário específico
  /// Recarrega a lista de comentários após deletar
  Future<void> deleteCommentCommand(int commentId, int experienceId) async {
    try {
      await _repository.deleteComment(commentId);

      // Recarregar comentários
      _comments = await _repository.getComments(experienceId);
      notifyListeners();
    } catch (e) {
      _setError('Error deleting comment: $e');
    }
  }

  /// Recarrega apenas os comentários
  /// Útil após adicionar um novo comentário
  Future<void> refreshComments(int experienceId) async {
    try {
      _comments = await _repository.getComments(experienceId);

      // Atualizar também o contador de comentários no experience
      _experience = await _repository.getExperienceById(experienceId);

      notifyListeners();
    } catch (e) {
      _setError('Error reloading comments: $e');
    }
  }

  // ========== VALIDATIONS ==========

  /// Verifica se o usuário atual pode deletar o experience
  /// Pode deletar se for o autor OU se for admin
  bool canDelete() {
    if (_experience == null) return false;

    return _experience!.userId == currentUserUid || _isAdmin();
  }

  /// Verifica se o usuário atual pode editar o experience
  /// Pode editar apenas se for o autor
  bool canEdit() {
    if (_experience == null) return false;

    // Cannot edit if waiting for approval
    if (_experience!.moderationStatus == 'awaiting_approval') {
      return false;
    }

    return _experience!.userId == currentUserUid;
  }

  /// Verifica se o usuário atual pode fazer lock/unlock do experience
  /// Pode fazer lock se for o autor OU se for admin
  bool canLock() {
    if (_experience == null) return false;

    // Check if user is the owner (author)
    final isOwner = _experience!.userId == currentUserUid;

    // Check if user is admin
    final isAdmin = _isAdmin();

    return isOwner || isAdmin;
  }

  /// Verifica se o usuário atual pode deletar um comentário específico
  /// Pode deletar se for o autor do comentário OU se for admin
  bool canDeleteComment(String commentUserId) {
    return commentUserId == currentUserUid || _isAdmin();
  }

  /// Verifica se o experience está bloqueado para comentários
  bool isLocked() {
    return _experience?.locked ?? false;
  }

  /// Verifica se o usuário atual é administrador
  bool _isAdmin() {
    try {
      return appState.loginUser.roles.hasAdmin;
    } catch (e) {
      return false;
    }
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
