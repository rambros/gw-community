import 'package:gw_community/domain/models/app_auth_user.dart';
import 'package:gw_community/domain/models/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Stream<AppAuthUser> get authUserChanges;
  Stream<String> get jwtTokenChanges;

  UserEntity? get currentUser;
  String? get currentUserId;

  Future<UserEntity?> signInWithEmail(String email, String password);

  Future<void> signOut();

  Future<void> resetPassword(String email, {String? redirectTo});

  Future<void> updateEmail(String email);

  Future<void> updatePassword(String newPassword);

  Future<void> deleteUser();

  Future<void> sendEmailVerification();

  Future<void> refreshUser();

  Future<void> sendMagicLink(String email);
}
