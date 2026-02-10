import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/community_repository.dart';

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
      await _communityRepository.updateCommunityGuidelines(contentController.text);
      return true;
    } catch (e) {
      debugPrint('Error saving guidelines: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save guidelines. Please try again.')),
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
