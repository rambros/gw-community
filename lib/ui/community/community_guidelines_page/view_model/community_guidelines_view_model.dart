import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/community_repository.dart';

class CommunityGuidelinesViewModel extends ChangeNotifier {
  final CommunityRepository _communityRepository;

  CommunityGuidelinesViewModel(this._communityRepository);

  String? _guidelines;
  String? get guidelines => _guidelines;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔵 [GuidelinesView] Loading guidelines...');
      _guidelines = await _communityRepository.getCommunityGuidelines();
      debugPrint('✅ [GuidelinesView] Loaded: ${_guidelines?.length ?? 0} chars');
    } catch (e) {
      debugPrint('❌ [GuidelinesView] Error loading guidelines: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
