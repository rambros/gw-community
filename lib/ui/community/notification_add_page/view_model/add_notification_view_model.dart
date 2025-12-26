import 'package:flutter/material.dart';

import '/data/repositories/notification_repository.dart';
import '/data/services/supabase/supabase.dart';

class AddNotificationViewModel extends ChangeNotifier {
  AddNotificationViewModel({
    required NotificationRepository repository,
    required this.currentUserUid,
    this.groupId,
    this.groupName,
    required this.privacy,
  }) : _repository = repository {
    _loadCurrentUser();
  }

  final NotificationRepository _repository;
  final String currentUserUid;
  final int? groupId;
  final String? groupName;
  final String privacy;

  final titleController = TextEditingController();
  final experienceController = TextEditingController();
  final titleFocusNode = FocusNode();
  final experienceFocusNode = FocusNode();

  String _visibility = 'group_only';
  String get visibility => _visibility;

  CcMembersRow? _currentUser;
  CcMembersRow? get currentUser => _currentUser;

  bool _isLoadingUser = false;
  bool get isLoadingUser => _isLoadingUser;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get canSelectVisibility => groupName != null && groupName!.isNotEmpty;

  void setVisibility(String? value) {
    if (value == null) return;
    _visibility = value;
    notifyListeners();
  }

  Future<void> _loadCurrentUser() async {
    _isLoadingUser = true;
    notifyListeners();
    try {
      _currentUser = await _repository.getUserById(currentUserUid);
    } finally {
      _isLoadingUser = false;
      notifyListeners();
    }
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty ||
        experienceController.text.trim().isEmpty) {
      _setError('Please fill in all required fields.');
      return false;
    }
    _clearError();
    return true;
  }

  Future<bool> saveNotification() async {
    if (!_validateForm()) {
      return false;
    }
    _setSaving(true);
    try {
      await _repository.createNotification(
        title: titleController.text.trim(),
        text: experienceController.text.trim(),
        privacy: privacy,
        userId: currentUserUid,
        groupId: groupId,
        visibility: visibility,
      );
      return true;
    } catch (e) {
      _setError('Error creating notification: $e');
      return false;
    } finally {
      _setSaving(false);
    }
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

  @override
  void dispose() {
    titleController.dispose();
    experienceController.dispose();
    titleFocusNode.dispose();
    experienceFocusNode.dispose();
    super.dispose();
  }
}
