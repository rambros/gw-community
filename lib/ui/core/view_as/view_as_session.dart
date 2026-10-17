import 'package:flutter/foundation.dart';

/// Member an app admin is browsing as. The Supabase session stays the admin's.
class ViewAsTarget {
  const ViewAsTarget({
    required this.authUserId,
    required this.displayName,
  });

  final String authUserId;
  final String displayName;
}

/// In-memory "view as member" state. Cleared on exit and on app restart.
class ViewAsSession extends ChangeNotifier {
  ViewAsSession._();

  static final ViewAsSession instance = ViewAsSession._();

  ViewAsTarget? _target;

  ViewAsTarget? get target => _target;

  bool get isActive => _target != null;

  /// User id used for group and journey reads. Writes keep [realAuthUserId].
  String subjectUserId(String realAuthUserId) {
    final id = _target?.authUserId;
    if (!isActive || id == null || id.isEmpty) return realAuthUserId;
    return id;
  }

  void start(ViewAsTarget target) {
    if (target.authUserId.isEmpty) return;
    _target = target;
    notifyListeners();
  }

  void stop() {
    if (_target == null) return;
    _target = null;
    notifyListeners();
  }
}

/// True while an admin is browsing as another member. Writes must no-op.
bool viewAsBlocksWrite() => ViewAsSession.instance.isActive;
