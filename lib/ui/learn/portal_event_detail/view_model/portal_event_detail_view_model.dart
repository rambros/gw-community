import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/portal_event_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class PortalEventDetailViewModel extends ChangeNotifier {
  PortalEventDetailViewModel({
    PortalEventRepository? repository,
  }) : _repository = repository ?? PortalEventRepository();

  final PortalEventRepository _repository;

  ViewEventsRow? _event;
  ViewEventsRow? get event => _event;

  List<ViewContentRow> _contents = [];
  List<ViewContentRow> get contents => _contents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> load(int eventId) async {
    _setLoading(true);
    _error = null;

    try {
      _event = await _repository.getById(eventId);
      if (_event == null) {
        _error = 'Event not found';
      } else {
        _contents = await _repository.getEventContents(eventId);
      }
    } catch (e) {
      _error = 'Error loading event: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
