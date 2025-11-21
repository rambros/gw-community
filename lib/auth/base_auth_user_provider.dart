/// Base authentication user interface that all auth providers must implement.
abstract class BaseAuthUser {
  BaseAuthUser();

  bool get loggedIn;
  String? get uid;
  String? get email;
  String? get displayName;
  String? get photoUrl;
  String? get phoneNumber;
  bool get emailVerified;
}
