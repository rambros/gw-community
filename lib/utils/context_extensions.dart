import 'package:flutter/widgets.dart';
import 'package:gw_community/data/repositories/auth_repository.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';
import 'package:provider/provider.dart';

extension AuthRepositoryContext on BuildContext {
  AuthRepository get authRepository => read<AuthRepository>();

  /// Signed-in Supabase user. Stays the admin during "view as".
  String get currentUserIdOrEmpty => authRepository.currentUserId ?? '';

  /// Member whose groups and journeys are being read.
  String get effectiveUserIdOrEmpty =>
      read<ViewAsSession>().subjectUserId(currentUserIdOrEmpty);
}
