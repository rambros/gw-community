import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/community_repository.dart';
import 'package:gw_community/l10n/l10n.dart';

class CommunityGuidelinesEditViewModel extends ChangeNotifier {
  final CommunityRepository _communityRepository;

  CommunityGuidelinesEditViewModel(this._communityRepository);

  final TextEditingController contentController = TextEditingController();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final content = await _communityRepository.getCommunityGuidelines();
      if (content != null) {
        contentController.text = content;
      }
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
      debugPrint('🔵 [GuidelinesEdit] Attempting to save...');
      await _communityRepository.updateCommunityGuidelines(contentController.text);
      debugPrint('✅ [GuidelinesEdit] Save completed successfully');
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
    contentController.dispose();
    super.dispose();
  }
}
