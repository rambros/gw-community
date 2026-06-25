import 'package:flutter/material.dart';

import 'package:gw_community/domain/models/app_auth_user.dart';
import 'package:gw_community/domain/models/user_entity.dart';

abstract class AuthService {
  Stream<UserEntity?> get authStateChanges;
  Stream<AppAuthUser> get authUserChanges;
  Stream<String> get jwtTokenChanges;

  UserEntity? get currentUser;
  String? get currentUserId;

  Future<UserEntity?> signInWithEmail(BuildContext context, String email, String password);

  Future<void> signOut();

  Future<void> resetPassword({
    required String email,
    required BuildContext context,
    String? redirectTo,
  });

  Future<void> updateEmail({required String email, required BuildContext context});

  Future<void> updatePassword({required String newPassword, required BuildContext context});

  Future<void> deleteUser(BuildContext context);

  Future<void> sendEmailVerification();

  Future<void> refreshUser();

  Future<void> sendMagicLink(String email);
}
