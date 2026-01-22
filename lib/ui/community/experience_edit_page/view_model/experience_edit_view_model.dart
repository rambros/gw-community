import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/experience_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:gw_community/routing/router.dart';

/// ViewModel para a página de edição de Experience
/// Gerencia estado do formulário e lógica de negócio
/// Segue padrão MVVM estilo Compass
class ExperienceEditViewModel extends ChangeNotifier {
  final ExperienceRepository _repository;
  final CcViewSharingsUsersRow originalExperience;

  ExperienceEditViewModel({
    required ExperienceRepository repository,
    required this.originalExperience,
  }) : _repository = repository {
    _initializeForm();
  }

  // ========== FORM CONTROLLERS ==========

  late TextEditingController textController;
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
    textController = TextEditingController(text: originalExperience.text ?? '');
    textFocusNode = FocusNode();
    _visibility = hasGroup ? 'group_only' : (originalExperience.visibility ?? 'everyone');
  }

  // ========== COMMANDS (User Actions) ==========

  /// Salva as alterações do experience (publica se era draft)
  Future<bool> saveCommand(BuildContext context, {bool navigateAway = true}) async {
    return _save(context, keepAsDraft: false, navigateAway: navigateAway);
  }

  /// Salva como rascunho (draft) - não envia para moderação
  Future<bool> saveDraftCommand(BuildContext context) async {
    return _save(context, keepAsDraft: true, navigateAway: false);
  }

  /// Método interno para salvar
  Future<bool> _save(BuildContext context, {required bool keepAsDraft, required bool navigateAway}) async {
    if (!canSave()) {
      _setError('Please fill in all required fields');
      return false;
    }

    _setSaving(true);
    _clearMessages();

    // Force group_only if hasGroup to ensure data consistency
    final saveVisibility = hasGroup ? 'group_only' : _visibility;

    try {
      await _repository.updateExperience(
        id: originalExperience.id!,
        title: originalExperience.title ?? '',
        text: textController.text.trim(),
        visibility: saveVisibility,
        privacy: originalExperience.privacy ?? 'public',
        keepAsDraft: keepAsDraft,
      );

      _setSuccess(keepAsDraft ? 'Reflection saved' : 'Experience updated successfully');

      // Aguardar um pouco para mostrar mensagem
      await Future.delayed(const Duration(milliseconds: 500));

      if (navigateAway && context.mounted) {
        context.safePop();
      }

      return true;
    } catch (e) {
      _setError('Error saving experience: $e');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// Cancela a edição e volta para a página anterior
  void cancelCommand(BuildContext context) {
    resetForm();
    if (context.mounted) {
      context.safePop();
    }
  }

  /// Reseta o formulário para os valores originais
  void resetForm() {
    textController.text = originalExperience.text ?? '';
    _visibility = originalExperience.visibility ?? 'everyone';
    _clearMessages();
    notifyListeners();
  }

  /// Atualiza a visibilidade do experience
  void setVisibility(String? value) {
    if (value != null) {
      _visibility = value;
      notifyListeners();
    }
  }

  // ========== VALIDATIONS ==========

  /// Verifica se o texto é válido (não vazio)
  String? validateText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Text is required';
    }
    return null;
  }

  /// Verifica se o formulário pode ser salvo
  bool canSave() {
    return textController.text.trim().isNotEmpty && !_isSaving;
  }

  /// Verifica se houve mudanças no formulário
  bool get hasChanges {
    return textController.text.trim() != (originalExperience.text ?? '') ||
        _visibility != (originalExperience.visibility ?? 'everyone');
  }

  /// Verifica se o experience pertence a um grupo
  bool get hasGroup {
    return originalExperience.groupName != null && originalExperience.groupName!.isNotEmpty;
  }

  /// Verifica se é um rascunho (draft)
  bool get isDraft {
    return originalExperience.moderationStatus == 'draft';
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
    textController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }
}
