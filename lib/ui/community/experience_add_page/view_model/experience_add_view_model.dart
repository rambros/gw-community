import 'package:flutter/material.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/experience_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/routing/router.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

/// ViewModel para a página de adicionar experience
/// Gerencia estado do formulário, validações e lógica de negócio
class ExperienceAddViewModel extends ChangeNotifier {
  final ExperienceRepository _repository;
  final String currentUserUid;
  final int? groupId;
  final String? groupName;
  final String privacy;

  ExperienceAddViewModel({
    required ExperienceRepository repository,
    required this.currentUserUid,
    this.groupId,
    this.groupName,
    String? privacy,
  })  : _repository = repository,
        privacy = privacy ?? 'public',
        _visibility = (groupId != null && groupName != null && groupName.isNotEmpty) ? 'group_only' : 'everyone' {
    _init();
  }

  // ========== STATE ==========

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();

  final TextEditingController textController = TextEditingController();
  final FocusNode textFocusNode = FocusNode();

  // Visibility dropdown
  late String _visibility;
  String get visibility => _visibility;

  // User data
  CcMembersRow? _currentUser;
  CcMembersRow? get currentUser => _currentUser;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  // Messages
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Comments control
  bool _commentsEnabled = true;
  bool get commentsEnabled => _commentsEnabled;

  // ========== COMPUTED PROPERTIES ==========

  /// Verifica se tem grupo associado
  bool get hasGroup => groupId != null && (groupName != null && groupName!.isNotEmpty);

  /// Texto de visibilidade para exibição
  String get visibilityText {
    if (!hasGroup || _visibility == 'everyone') {
      return 'Experience for everyone';
    }
    return 'Experience only for this group';
  }

  // ========== INITIALIZATION ==========

  void _init() {
    _loadUserData();
  }

  /// Carrega dados do usuário atual
  Future<void> _loadUserData() async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _repository.getUserById(currentUserUid);
      notifyListeners();
    } catch (e) {
      _setError('Error loading user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== VALIDATIONS ==========

  /// Valida o campo de texto/experiência
  String? validateText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Experience is required';
    }
    return null;
  }

  /// Verifica se o formulário pode ser salvo
  bool canSave() {
    return textController.text.trim().isNotEmpty && !_isSaving;
  }

  // ========== COMMANDS ==========

  /// Define a visibilidade do experience
  void setVisibility(String? value) {
    if (value != null) {
      _visibility = value;
      notifyListeners();
    }
  }

  /// Alterna o estado de comentários habilitados/desabilitados
  void toggleComments(bool value) {
    _commentsEnabled = value;
    notifyListeners();
  }

  /// Salva o experience e publica (envia para moderação)
  Future<bool> saveCommand(BuildContext context, {bool navigateAway = true}) async {
    return _save(context, isDraft: false, navigateAway: navigateAway);
  }

  /// Salva como rascunho (draft) - não envia para moderação
  Future<bool> saveDraftCommand(BuildContext context) async {
    return _save(context, isDraft: true, navigateAway: false);
  }

  /// Método interno que salva o experience
  Future<bool> _save(BuildContext context, {required bool isDraft, required bool navigateAway}) async {
    if (!canSave()) {
      _setError('Please fill in all required fields');
      return false;
    }

    _setSaving(true);
    _clearError();
    _clearSuccess();

    try {
      // Generate title from first 50 characters of text
      final text = textController.text.trim();
      final autoTitle = text.length > 50 ? '${text.substring(0, 50)}...' : text;

      await _repository.createExperience(
        title: autoTitle,
        text: text,
        privacy: privacy,
        userId: currentUserUid,
        visibility: _visibility,
        type: ExperienceType.experience.name,
        groupId: groupId,
        isDraft: isDraft,
        locked: !_commentsEnabled, // locked = true quando comments estão desabilitados
      );

      _setSuccess(isDraft ? 'Reflection saved' : 'Experience created with success');

      // Navigate back to community page only if not a draft
      if (navigateAway && context.mounted) {
        context.safePop();
      }

      return true;
    } catch (e) {
      _setError('Error creating experience: $e');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// Cancela a criação do experience
  void cancelCommand(BuildContext context) {
    // Clear form
    textController.clear();

    // Navigate back
    if (context.mounted) {
      context.safePop();
    }
  }

  // ========== HELPER METHODS ==========

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setSuccess(String message) {
    _successMessage = message;
    notifyListeners();
  }

  void _clearSuccess() {
    _successMessage = null;
  }

  @override
  void dispose() {
    titleController.dispose();
    titleFocusNode.dispose();
    textController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }
}
