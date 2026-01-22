import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class AnnouncementEditViewModel extends ChangeNotifier {
  AnnouncementEditViewModel({
    required AnnouncementRepository repository,
    required CcViewNotificationsUsersRow experienceRow,
  })  : _repository = repository,
        _experienceRow = experienceRow {
    titleController.text = experienceRow.title ?? '';
    descriptionController.text = experienceRow.text ?? '';
    _visibility = experienceRow.visibility ?? 'group_only';
    _privacy = experienceRow.privacy ?? 'public';
  }

  final AnnouncementRepository _repository;
  final CcViewNotificationsUsersRow _experienceRow;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final titleFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();

  String _visibility = 'group_only';
  String get visibility => _visibility;

  String _privacy = 'public';
  String get privacy => _privacy;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CcViewNotificationsUsersRow get experienceRow => _experienceRow;

  bool get canSelectVisibility => experienceRow.groupName != null && experienceRow.groupName!.isNotEmpty;

  void setVisibility(String? value) {
    if (value == null) return;
    _visibility = value;
    notifyListeners();
  }

  Future<bool> saveAnnouncement() async {
    if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
      _setError('Please fill in all required fields.');
      return false;
    }

    _setSaving(true);
    try {
      await _repository.updateAnnouncement(
        id: experienceRow.id!,
        title: titleController.text.trim(),
        text: descriptionController.text.trim(),
        privacy: _privacy,
        visibility: _visibility,
      );
      return true;
    } catch (e) {
      _setError('Error updating announcement: $e');
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

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }
}
