import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/user_profile_repository.dart';

class UserJournalOptionsViewModel extends ChangeNotifier {
  final UserProfileRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserJournalOptionsViewModel({
    required UserProfileRepository repository,
  }) : _repository = repository;

  Future<void> clearJournalEntry(int userActivityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateJournalEntry(userActivityId, '');
    } catch (e) {
      _errorMessage = 'Failed to clear journal entry: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
