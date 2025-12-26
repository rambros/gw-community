import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/unsplash_repository.dart';
import 'package:gw_community/data/services/api/api_calls.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class UnsplashViewModel extends ChangeNotifier {
  final UnsplashRepository _repository;

  UnsplashViewModel({required UnsplashRepository repository}) : _repository = repository;

  // ========== STATE ==========

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ApiCallResponse? _apiResponse;
  ApiCallResponse? get apiResponse => _apiResponse;

  String get currentImageUrl => valueOrDefault<String>(
        getJsonField(
          (_apiResponse?.jsonBody ?? ''),
          r'''$.urls.regular''',
        )?.toString(),
        'https://randomuser.me/api/portraits/lego/7.jpg',
      );

  // ========== COMMANDS ==========

  Future<void> fetchRandomImage() async {
    _setLoading(true);
    _clearError();

    try {
      _apiResponse = await _repository.getRandomImage();

      if (!(_apiResponse?.succeeded ?? true)) {
        _setError('Error fetching image');
      }

      notifyListeners();
    } catch (e) {
      _setError('Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== HELPER METHODS ==========

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
