import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';
import '/data/repositories/sharing_repository.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// ViewModel para a página de edição de Sharing
/// Gerencia estado do formulário e lógica de negócio
/// Segue padrão MVVM estilo Compass
class SharingEditViewModel extends ChangeNotifier {
  final SharingRepository _repository;
  final CcViewSharingsUsersRow originalSharing;

  SharingEditViewModel({
    required SharingRepository repository,
    required this.originalSharing,
  }) : _repository = repository {
    _initializeForm();
  }

  // ========== FORM CONTROLLERS ==========

  late TextEditingController titleController;
  late TextEditingController textController;
  late FocusNode titleFocusNode;
  late FocusNode textFocusNode;

  String _visibility = '';
  String get visibility => _visibility;

  // ========== STATE ==========

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // ========== INITIALIZATION ==========

  void _initializeForm() {
    titleController = TextEditingController(text: originalSharing.title ?? '');
    textController = TextEditingController(text: originalSharing.text ?? '');
    titleFocusNode = FocusNode();
    textFocusNode = FocusNode();
    _visibility = originalSharing.visibility ?? 'everyone';
  }

  // ========== COMMANDS (User Actions) ==========

  /// Salva as alterações do sharing
  Future<void> saveCommand(BuildContext context) async {
    if (!canSave()) {
      _setError('Por favor, preencha todos os campos obrigatórios');
      return;
    }

    _setSaving(true);
    _clearMessages();

    try {
      await _repository.updateSharing(
        id: originalSharing.id!,
        title: titleController.text.trim(),
        text: textController.text.trim(),
        visibility: _visibility,
        privacy: originalSharing.privacy ?? 'public',
      );

      _setSuccess('Sharing atualizado com sucesso');

      // Aguardar um pouco para mostrar mensagem
      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        context.goNamed(
          'communityPage',
          extra: <String, dynamic>{
            kTransitionInfoKey: const TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 0),
            ),
          },
        );
      }
    } catch (e) {
      _setError('Erro ao salvar sharing: $e');
    } finally {
      _setSaving(false);
    }
  }

  /// Cancela a edição e volta para a página anterior
  void cancelCommand(BuildContext context) {
    resetForm();
    if (context.mounted) {
      context.pushNamed('communityPage');
    }
  }

  /// Reseta o formulário para os valores originais
  void resetForm() {
    titleController.text = originalSharing.title ?? '';
    textController.text = originalSharing.text ?? '';
    _visibility = originalSharing.visibility ?? 'everyone';
    _clearMessages();
    notifyListeners();
  }

  /// Atualiza a visibilidade do sharing
  void setVisibility(String? value) {
    if (value != null) {
      _visibility = value;
      notifyListeners();
    }
  }

  // ========== VALIDATIONS ==========

  /// Verifica se o título é válido (não vazio)
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Título é obrigatório';
    }
    return null;
  }

  /// Verifica se o texto é válido (não vazio)
  String? validateText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Texto é obrigatório';
    }
    return null;
  }

  /// Verifica se o formulário pode ser salvo
  bool canSave() {
    return titleController.text.trim().isNotEmpty && textController.text.trim().isNotEmpty && !_isSaving;
  }

  /// Verifica se houve mudanças no formulário
  bool get hasChanges {
    return titleController.text.trim() != (originalSharing.title ?? '') ||
        textController.text.trim() != (originalSharing.text ?? '') ||
        _visibility != (originalSharing.visibility ?? 'everyone');
  }

  /// Verifica se o sharing pertence a um grupo
  bool get hasGroup {
    return originalSharing.groupName != null && originalSharing.groupName!.isNotEmpty;
  }

  // ========== HELPER METHODS ==========

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    titleFocusNode.dispose();
    textFocusNode.dispose();
    super.dispose();
  }
}
