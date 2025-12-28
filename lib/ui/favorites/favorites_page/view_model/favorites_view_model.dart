import 'package:flutter/foundation.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// ViewModel para a página de favoritos
class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel({
    required FavoritesRepository repository,
    required this.currentUserId,
  }) : _repository = repository;

  final FavoritesRepository _repository;
  final String currentUserId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CcViewUserFavoriteRecordingsRow> _favoriteRecordings = [];
  List<CcViewUserFavoriteRecordingsRow> get favoriteRecordings =>
      _favoriteRecordings;

  List<CcViewUserFavoriteActivitiesRow> _favoriteActivities = [];
  List<CcViewUserFavoriteActivitiesRow> get favoriteActivities =>
      _favoriteActivities;

  int get totalFavorites =>
      _favoriteRecordings.length + _favoriteActivities.length;

  /// Carrega todos os favoritos do usuário
  Future<void> loadFavorites() async {
    if (currentUserId.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Carrega em paralelo
      final results = await Future.wait([
        _repository.getFavoriteRecordings(currentUserId),
        _repository.getFavoriteActivities(currentUserId),
      ]);

      _favoriteRecordings =
          results[0] as List<CcViewUserFavoriteRecordingsRow>;
      _favoriteActivities =
          results[1] as List<CcViewUserFavoriteActivitiesRow>;
    } catch (e) {
      _errorMessage = 'Erro ao carregar favoritos: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove um recording dos favoritos
  Future<void> removeRecordingFromFavorites(int contentId) async {
    final success = await _repository.removeFavorite(
      authUserId: currentUserId,
      contentType: FavoritesRepository.typeRecording,
      contentId: contentId,
    );

    if (success) {
      _favoriteRecordings.removeWhere((r) => r.contentId == contentId);
      notifyListeners();
    }
  }

  /// Remove uma activity dos favoritos
  Future<void> removeActivityFromFavorites(int activityId) async {
    final success = await _repository.removeFavorite(
      authUserId: currentUserId,
      contentType: FavoritesRepository.typeActivity,
      contentId: activityId,
    );

    if (success) {
      _favoriteActivities.removeWhere((a) => a.id == activityId);
      notifyListeners();
    }
  }
}
