import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/community_repository.dart';
import 'package:gw_community/data/repositories/experience_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/routing/router.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

/// ViewModel para a página de adicionar experience
/// Gerencia estado do formulário, validações e lógica de negócio
class ExperienceAddViewModel extends ChangeNotifier {
  final ExperienceRepository _repository;
  final CommunityRepository? _communityRepository;
  final String currentUserUid;
  final int? groupId;
  final String? groupName;
  final String privacy;
  final bool chooseGroups;
  final String? fixedLanguage;

  ExperienceAddViewModel({
    required ExperienceRepository repository,
    CommunityRepository? communityRepository,
    required this.currentUserUid,
    this.groupId,
    this.groupName,
    String? privacy,
    this.chooseGroups = false,
    this.fixedLanguage,
  })  : _repository = repository,
        _communityRepository = communityRepository,
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

  // Id of the experience once it has been saved for the first time (draft or
  // published). Subsequent saves update this row instead of inserting a new one.
  int? _savedExperienceId;

  // Groups the member can share into, used when [chooseGroups] is true.
  // Each selected group gets its own sharing row.
  List<CcGroupsRow> _availableGroups = [];
  List<CcGroupsRow> get availableGroups => _availableGroups;

  final Set<int> _selectedGroupIds = {};
  final Map<int, int> _savedIdsByGroup = {};

  bool isGroupSelected(int groupId) => _selectedGroupIds.contains(groupId);

  bool get allGroupsSelected =>
      _availableGroups.isNotEmpty && _selectedGroupIds.length == _availableGroups.length;

  List<CcGroupsRow> get selectedGroups =>
      _availableGroups.where((group) => _selectedGroupIds.contains(group.id)).toList();

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

  /// Carrega dados do usuário atual e, no fluxo pós-meditação, os grupos dele.
  Future<void> _loadUserData() async {
    _setLoading(true);
    _clearError();

    try {
      final userFuture = _repository.getUserById(currentUserUid);
      final groupsFuture = chooseGroups
          ? _communityRepository!.getMyGroups(currentUserUid)
          : Future<List<CcGroupsRow>>.value(const []);
      final results = await Future.wait([userFuture, groupsFuture]);
      _currentUser = results[0] as CcMembersRow?;
      _availableGroups = results[1] as List<CcGroupsRow>;
      notifyListeners();
    } catch (e) {
      _setError('Error loading user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  void toggleGroup(int id) {
    if (_selectedGroupIds.contains(id)) {
      _selectedGroupIds.remove(id);
    } else {
      _selectedGroupIds.add(id);
    }
    notifyListeners();
  }

  void setAllGroups(bool selected) {
    _selectedGroupIds
      ..clear()
      ..addAll(selected ? _availableGroups.map((group) => group.id) : const <int>[]);
    notifyListeners();
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
    if (textController.text.trim().isEmpty || _isSaving) return false;
    if (chooseGroups && _selectedGroupIds.isEmpty) return false;
    return true;
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

      if (chooseGroups) {
        await _saveToSelectedGroups(
          title: autoTitle,
          text: text,
          isDraft: isDraft,
        );
      } else {
        await _saveSingle(
          title: autoTitle,
          text: text,
          isDraft: isDraft,
        );
      }

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

  Future<void> _saveSingle({
    required String title,
    required String text,
    required bool isDraft,
  }) async {
    final existingId = _savedExperienceId;
    if (existingId == null) {
      _savedExperienceId = await _repository.createExperience(
        title: title,
        text: text,
        privacy: privacy,
        userId: currentUserUid,
        visibility: _visibility,
        type: 'sharing',
        groupId: groupId,
        isDraft: isDraft,
        locked: !_commentsEnabled,
      );
      return;
    }

    await _repository.updateExperience(
      id: existingId,
      title: title,
      text: text,
      visibility: _visibility,
      privacy: privacy,
      groupId: groupId,
      keepAsDraft: isDraft,
      locked: !_commentsEnabled,
    );
  }

  /// One sharing row per selected group. Groups unchecked after a draft are removed.
  Future<void> _saveToSelectedGroups({
    required String title,
    required String text,
    required bool isDraft,
  }) async {
    final removed = _savedIdsByGroup.keys.where((id) => !_selectedGroupIds.contains(id)).toList();
    for (final removedGroupId in removed) {
      await _repository.deleteExperience(_savedIdsByGroup[removedGroupId]!);
      _savedIdsByGroup.remove(removedGroupId);
    }

    for (final group in selectedGroups) {
      final groupPrivacy = group.groupPrivacy ?? 'public';
      final existingId = _savedIdsByGroup[group.id];
      if (existingId == null) {
        _savedIdsByGroup[group.id] = await _repository.createExperience(
          title: title,
          text: text,
          privacy: groupPrivacy,
          userId: currentUserUid,
          visibility: 'group_only',
          type: 'sharing',
          groupId: group.id,
          isDraft: isDraft,
          locked: !_commentsEnabled,
        );
      } else {
        await _repository.updateExperience(
          id: existingId,
          title: title,
          text: text,
          visibility: 'group_only',
          privacy: groupPrivacy,
          groupId: group.id,
          keepAsDraft: isDraft,
          locked: !_commentsEnabled,
        );
      }
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
