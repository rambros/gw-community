import 'package:flutter/material.dart';

import '/data/services/supabase/supabase.dart';
import '/data/repositories/notification_repository.dart';

class NotificationEditViewModel extends ChangeNotifier {
  NotificationEditViewModel({
    required NotificationRepository repository,
    required CcViewNotificationsUsersRow sharingRow,
  })  : _repository = repository,
        _sharingRow = sharingRow {
    titleController.text = sharingRow.title ?? '';
    descriptionController.text = sharingRow.text ?? '';
    _visibility = sharingRow.visibility ?? 'group_only';
    _privacy = sharingRow.privacy ?? 'public';
  }

  final NotificationRepository _repository;
  final CcViewNotificationsUsersRow _sharingRow;

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

  CcViewNotificationsUsersRow get sharingRow => _sharingRow;

  bool get canSelectVisibility => sharingRow.groupName != null && sharingRow.groupName!.isNotEmpty;

  void setVisibility(String? value) {
    if (value == null) return;
    _visibility = value;
    notifyListeners();
  }

  Future<bool> saveNotification() async {
    if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
      _setError('Please fill in all required fields.');
      return false;
    }

    _setSaving(true);
    try {
      await _repository.updateNotification(
        id: sharingRow.id!,
        title: titleController.text.trim(),
        text: descriptionController.text.trim(),
        privacy: _privacy,
        visibility: _visibility,
      );
      return true;
    } catch (e) {
      _setError('Error updating notification: $e');
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
