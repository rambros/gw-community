import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';

class GroupInvitationViewModel extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final CcGroupsRow? group;
  final String currentUserUid;

  GroupInvitationViewModel(
    this._groupRepository,
    this.group, {
    required this.currentUserUid,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> joinGroup(BuildContext context) async {
    if (group == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final userId = currentUserUid;
      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }

      await _groupRepository.joinGroup(group!.id, userId);
      return true;
    } catch (e) {
      debugPrint('Error joining group: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorJoiningGroup('$e'))),
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
