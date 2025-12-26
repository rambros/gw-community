import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/sharing_repository.dart';

/// ViewModel responsável por gerenciar o formulário de criação de comentários
/// Mantém o estado do formulário, validações e interação com o repositório
class AddCommentViewModel extends ChangeNotifier {
  final SharingRepository _repository;
  final String currentUserUid;
  final int sharingId;
  final int? parentId;

  AddCommentViewModel({
    required SharingRepository repository,
    required this.currentUserUid,
    required this.sharingId,
    this.parentId,
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
    if (!canSubmit) {
      _setError('Please write something before posting.');
      return false;
    }

    _setSubmitting(true);
    _clearError();

    try {
      await _repository.createComment(
        userId: currentUserUid,
        sharingId: sharingId,
        content: textController.text.trim(),
        parentId: parentId,
      );
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
