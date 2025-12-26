import 'package:flutter/widgets.dart';
import 'package:gw_community/data/repositories/auth_repository.dart';
import 'package:provider/provider.dart';

extension AuthRepositoryContext on BuildContext {
  AuthRepository get authRepository => read<AuthRepository>();
  String get currentUserIdOrEmpty => authRepository.currentUserId ?? '';
}
