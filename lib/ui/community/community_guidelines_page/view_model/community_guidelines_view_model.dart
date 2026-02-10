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
      _guidelines = await _communityRepository.getCommunityGuidelines();
    } catch (e) {
      debugPrint('Error loading guidelines: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
