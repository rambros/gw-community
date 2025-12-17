import 'package:flutter/material.dart';
import '/data/repositories/user_profile_repository.dart';
import '/data/services/supabase/supabase.dart';

class UserJournalListViewModel extends ChangeNotifier {
  final UserProfileRepository _repository;

  UserJournalListViewModel({
    required UserProfileRepository repository,
  }) : _repository = repository;

  /// Gets the current user ID dynamically from Supabase auth
  String get _currentUserUid => SupaFlow.client.auth.currentUser?.id ?? '';

  List<CcViewUserJournalRow> _journalEntries = [];
  List<CcViewUserJournalRow> get journalEntries => _journalEntries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadJournalEntries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _journalEntries = await _repository.getUserJournalEntries(_currentUserUid);
    } catch (e) {
      _errorMessage = 'Failed to load journal entries: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
