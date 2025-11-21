import 'package:flutter/material.dart';
import '/data/repositories/user_profile_repository.dart';
import '/backend/supabase/supabase.dart';

class UserJournalViewModel extends ChangeNotifier {
  final UserProfileRepository _repository;

  UserJournalViewModel({
    required UserProfileRepository repository,
  }) : _repository = repository;

  CcViewUserJournalRow? _journalEntry;
  CcViewUserJournalRow? get journalEntry => _journalEntry;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadJournalEntry(int userActivityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _journalEntry = await _repository.getJournalEntry(userActivityId);
    } catch (e) {
      _errorMessage = 'Failed to load journal entry: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
