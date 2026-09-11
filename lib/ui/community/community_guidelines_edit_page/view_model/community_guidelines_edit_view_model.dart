import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/community_repository.dart';
import 'package:gw_community/l10n/l10n.dart';

class CommunityGuidelinesEditViewModel extends ChangeNotifier {
  final CommunityRepository _communityRepository;

  CommunityGuidelinesEditViewModel(this._communityRepository);

  final TextEditingController englishController = TextEditingController();
  final TextEditingController portugueseController = TextEditingController();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final versions =
          await _communityRepository.getCommunityGuidelinesVersions();
      englishController.text = versions.english ?? '';
      portugueseController.text = versions.portuguese ?? '';
    } catch (e) {
      debugPrint('Error loading guidelines for edit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveGuidelines(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _communityRepository.updateCommunityGuidelinesVersions(
        english: englishController.text,
        portuguese: portugueseController.text,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.guidelinesSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('❌ [GuidelinesEdit] Error saving guidelines: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToSaveGuidelines('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    englishController.dispose();
    portugueseController.dispose();
    super.dispose();
  }
}
