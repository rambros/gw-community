import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';
import '/data/repositories/user_profile_repository.dart';
import '/auth/supabase_auth/auth_util.dart';

class UserJourneysViewModel extends ChangeNotifier {
  final UserProfileRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CcViewUserJourneysRow> _journeys = [];
  List<CcViewUserJourneysRow> get journeys => _journeys;

  UserJourneysViewModel({
    required UserProfileRepository repository,
  }) : _repository = repository;

  Future<void> loadJourneys() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (currentUserUid.isNotEmpty) {
        _journeys = await _repository.getUserJourneys(currentUserUid);
      }
    } catch (e) {
      _errorMessage = 'Failed to load journeys: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
