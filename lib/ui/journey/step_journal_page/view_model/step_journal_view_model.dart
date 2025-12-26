import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/journal_repository.dart';

class StepJournalViewModel extends ChangeNotifier {
  final JournalRepository _repository;
  final int activityId;
  final String initialContent;

  StepJournalViewModel({
    required JournalRepository repository,
    required this.activityId,
    required this.initialContent,
  }) : _repository = repository {
    _journalContent = initialContent;
  }

  // ========== STATE ==========

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String _journalContent = '';
  String get journalContent => _journalContent;

  void updateJournalContent(String content) {
    _journalContent = content;
    notifyListeners();
  }

  // ========== COMMANDS ==========

  Future<void> saveJournalCommand(BuildContext context, VoidCallback onSuccess) async {
    _setSaving(true);

    try {
      await _repository.saveJournalEntry(activityId, _journalContent);
      onSuccess();
    } catch (e) {
      // Error handling could be improved with error state
      debugPrint('Error saving journal: $e');
    } finally {
      _setSaving(false);
    }
  }

  // ========== HELPER METHODS ==========

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }
}
