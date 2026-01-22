import 'package:flutter/foundation.dart';

import 'package:gw_community/data/repositories/experience_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// ViewModel for the My Experiences page
/// Lists all experiences created by the current user
class MyExperiencesViewModel extends ChangeNotifier {
  final ExperienceRepository _repository;
  final String currentUserId;

  MyExperiencesViewModel({
    required ExperienceRepository repository,
    required this.currentUserId,
  }) : _repository = repository;

  List<CcViewSharingsUsersRow> _experiences = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filtering
  String? _statusFilter;
  String? get statusFilter => _statusFilter;

  String? _groupFilter;
  String? get groupFilter => _groupFilter;

  void setStatusFilter(String? value) {
    _statusFilter = value;
    notifyListeners();
  }

  void setGroupFilter(String? value) {
    _groupFilter = value;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _groupFilter = null;
    notifyListeners();
  }

  List<String> get availableGroups {
    return _experiences.map((e) => e.groupName).whereType<String>().where((name) => name.isNotEmpty).toSet().toList()
      ..sort();
  }

  List<CcViewSharingsUsersRow> get filteredExperiences {
    return _experiences.where((e) {
      final statusMatch = _statusFilter == null || e.moderationStatus == _statusFilter;
      final groupMatch = _groupFilter == null || e.groupName == _groupFilter;
      return statusMatch && groupMatch;
    }).toList();
  }

  List<CcViewSharingsUsersRow> get experiences => filteredExperiences;

  /// Load all experiences for the current user
  Future<void> loadExperiences() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await CcViewSharingsUsersTable().queryRows(
        queryFn: (q) => q.eqOrNull('user_id', currentUserId).order('updated_at', ascending: false),
      );
      _experiences = result;
    } catch (e) {
      _errorMessage = 'Error loading experiences: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an experience
  Future<bool> deleteExperience(int id) async {
    try {
      await _repository.deleteExperience(id);
      _experiences.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting experience: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// Publish a draft experience (changes status from 'draft' to 'pending')
  Future<bool> publishExperience(int id) async {
    try {
      final success = await _repository.publishDraft(id);
      if (success) {
        // Reload to get updated data
        await loadExperiences();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error publishing experience: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }
}
