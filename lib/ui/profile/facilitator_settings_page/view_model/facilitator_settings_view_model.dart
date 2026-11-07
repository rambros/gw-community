import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/facilitator_settings_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/facilitator_group_settings.dart';

class FacilitatorSettingsViewModel extends ChangeNotifier {
  FacilitatorSettingsViewModel({FacilitatorSettingsRepository? repository})
      : _repository = repository ?? FacilitatorSettingsRepository();

  final FacilitatorSettingsRepository _repository;

  List<FacilitatorGroupSettings> groups = const [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final userId = SupaFlow.client.auth.currentUser?.id ?? '';
      groups = await _repository.load(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(FacilitatorGroupSettings next) async {
    final index = groups.indexWhere((group) => group.groupId == next.groupId);
    if (index < 0) return;
    final previous = groups[index];
    groups = [...groups]..[index] = next;
    errorMessage = null;
    notifyListeners();
    try {
      final userId = SupaFlow.client.auth.currentUser?.id ?? '';
      await _repository.save(userId, next);
    } catch (e) {
      groups = [...groups]..[index] = previous;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> applyToAll(FacilitatorGroupSettings source) async {
    final nextGroups = [
      for (final group in groups)
        group.groupId == source.groupId
            ? group
            : FacilitatorGroupSettings(
                groupId: group.groupId,
                groupName: group.groupName,
                notifyNewExperiences: source.notifyNewExperiences,
                notifyMessages: source.notifyMessages,
                emailEachExperience: source.emailEachExperience,
                emailMemberMessage: source.emailMemberMessage,
                emailDailySummary: source.emailDailySummary,
                emailWeeklySummary: source.emailWeeklySummary,
              ),
    ];
    final previous = groups;
    groups = nextGroups;
    errorMessage = null;
    notifyListeners();
    try {
      final userId = SupaFlow.client.auth.currentUser?.id ?? '';
      for (final group in nextGroups) {
        await _repository.save(userId, group);
      }
    } catch (e) {
      groups = previous;
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
