/// Contract that represents the authenticated user exposed to the rest of the app.
abstract class AppAuthUser {
  AppAuthUser();

  bool get loggedIn;
  String? get uid;
  String? get email;
  String? get displayName;
  String? get photoUrl;
  String? get phoneNumber;
  bool get emailVerified;
}
