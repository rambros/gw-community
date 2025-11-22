import 'package:flutter/material.dart';
import '/data/models/enums/enums.dart';
import '/data/services/supabase/supabase.dart';
import '/data/repositories/sharing_repository.dart';
import '/utils/flutter_flow_util.dart';
import '/index.dart';

/// ViewModel para a página de adicionar sharing
/// Gerencia estado do formulário, validações e lógica de negócio
class SharingAddViewModel extends ChangeNotifier {
  final SharingRepository _repository;
  final String currentUserUid;
  final int? groupId;
  final String? groupName;
  final String privacy;

  SharingAddViewModel({
    required SharingRepository repository,
    required this.currentUserUid,
    this.groupId,
    this.groupName,
    String? privacy,
  })  : _repository = repository,
        privacy = privacy ?? 'public' {
    _init();
  }

  // ========== STATE ==========

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();

  final TextEditingController textController = TextEditingController();
  final FocusNode textFocusNode = FocusNode();

  // Visibility dropdown
  String _visibility = 'group_only';
  String get visibility => _visibility;

  // User data
  CcUsersRow? _currentUser;
  CcUsersRow? get currentUser => _currentUser;

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

  // ========== COMPUTED PROPERTIES ==========

  /// Verifica se tem grupo associado
  bool get hasGroup => groupId != null && (groupName != null && groupName!.isNotEmpty);

  /// Texto de visibilidade para exibição
  String get visibilityText {
    if (!hasGroup || _visibility == 'everyone') {
      return 'Sharing for everyone';
    }
    return 'Sharing only for this group';
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

  /// Valida o campo de título
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    return null;
  }

  /// Valida o campo de texto/experiência
  String? validateText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Experience is required';
    }
    return null;
  }

  /// Verifica se o formulário pode ser salvo
  bool canSave() {
    return titleController.text.trim().isNotEmpty && textController.text.trim().isNotEmpty && !_isSaving;
  }

  // ========== COMMANDS ==========

  /// Define a visibilidade do sharing
  void setVisibility(String? value) {
    if (value != null) {
      _visibility = value;
      notifyListeners();
    }
  }

  /// Salva o sharing
  Future<void> saveCommand(BuildContext context) async {
    if (!canSave()) {
      _setError('Please fill in all required fields');
      return;
    }

    _setSaving(true);
    _clearError();
    _clearSuccess();

    try {
      await _repository.createSharing(
        title: titleController.text.trim(),
        text: textController.text.trim(),
        privacy: privacy,
        userId: currentUserUid,
        visibility: _visibility,
        type: SharingType.sharing.name,
        groupId: groupId,
      );

      _setSuccess('Sharing created with success');

      // Navigate back to community page
      if (context.mounted) {
        context.pushNamed(CommunityPage.routeName);
      }
    } catch (e) {
      _setError('Error creating sharing: $e');
    } finally {
      _setSaving(false);
    }
  }

  /// Cancela a criação do sharing
  void cancelCommand(BuildContext context) {
    // Clear form
    titleController.clear();
    textController.clear();

    // Navigate back
    if (context.mounted) {
      context.pushNamed(CommunityPage.routeName);
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
