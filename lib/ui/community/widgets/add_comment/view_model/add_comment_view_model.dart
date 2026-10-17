import 'dart:async';

import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/experience_repository.dart';
import 'package:gw_community/data/services/push/comment_reply_notifier.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';

/// ViewModel responsável por gerenciar o formulário de criação de comentários
/// Mantém o estado do formulário, validações e interação com o repositório
class AddCommentViewModel extends ChangeNotifier {
  final ExperienceRepository _repository;
  final String currentUserUid;
  final int experienceId;
  final int? parentId;
  final bool notifyFacilitators;

  AddCommentViewModel({
    required ExperienceRepository repository,
    required this.currentUserUid,
    required this.experienceId,
    this.parentId,
    this.notifyFacilitators = false,
  }) : _repository = repository;

  final TextEditingController textController = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get canSubmit => textController.text.trim().isNotEmpty && !_isSubmitting;

  void onTextChanged(String _) {
    if (_errorMessage != null) {
      _clearError();
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  Future<bool> submitComment() async {
    if (viewAsBlocksWrite()) return false;
    if (!canSubmit) {
      _setError('Please write something before posting.');
      return false;
    }

    _setSubmitting(true);
    _clearError();

    try {
      final commentId = await _repository.createComment(
        userId: currentUserUid,
        experienceId: experienceId,
        content: textController.text.trim(),
        parentId: parentId,
      );
      if (notifyFacilitators) {
        unawaited(CommentReplyNotifier.notify(commentId));
      }
      textController.clear();
      return true;
    } catch (e) {
      _setError('Error posting comment: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }
}
