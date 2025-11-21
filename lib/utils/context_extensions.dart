import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '/data/repositories/auth_repository.dart';

extension AuthRepositoryContext on BuildContext {
  AuthRepository get authRepository => read<AuthRepository>();
  String get currentUserIdOrEmpty => authRepository.currentUserId ?? '';
}
