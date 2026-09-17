import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/learn_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/learn/utils/portal_content_mapper.dart';

class ContentViewModel extends ChangeNotifier {
  ContentViewModel({
    required this.contentId,
    ViewContentRow? viewContentRow,
    LibraryContentSection? librarySection,
    LearnRepository? repository,
  })  : _repository = repository ?? LearnRepository(),
        _viewContentRow = viewContentRow,
        _passedSection = librarySection;

  final int contentId;
  final LearnRepository _repository;
  final LibraryContentSection? _passedSection;

  ViewContentRow? _viewContentRow;
  ViewContentRow? get viewContentRow => _viewContentRow;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? get midiaType => _viewContentRow?.midiaType?.toLowerCase();

  bool get isMessageType =>
      isMessageContentType(_viewContentRow?.contentTypeId);

  bool get hasTranscript =>
      _viewContentRow?.transcript != null &&
      _viewContentRow!.transcript!.isNotEmpty;

  LibraryContentSection? get librarySection =>
      _passedSection ?? inferLibraryContentSection(_viewContentRow);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final previousGroup = _viewContentRow?.dashboardGroupId;
      _viewContentRow = await _repository.getById(contentId);
      if (_viewContentRow == null) {
        _error = 'Content not found';
      } else {
        _viewContentRow!.dashboardGroupId ??= previousGroup;
        if (_passedSection == null &&
            inferLibraryContentSection(_viewContentRow) == null) {
          final eventId = _viewContentRow!.cottEventId ?? 0;
          if (eventId > 0) {
            _viewContentRow!.dashboardGroupId =
                await _repository.getDashboardGroupIdForEvent(eventId);
          }
        }
      }
    } catch (e) {
      _error = 'Error loading content: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
