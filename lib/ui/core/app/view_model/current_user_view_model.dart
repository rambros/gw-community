import 'package:flutter/material.dart';
import '/data/models/structs/login_user_struct.dart';

/// ViewModel for managing the current user's profile data.
///
/// This replaces the `loginUser` field from FFAppState.
class CurrentUserViewModel extends ChangeNotifier {
  LoginUserStruct _loginUser = LoginUserStruct.fromSerializableMap(
    {'roles': '[]'},
  );
  LoginUserStruct get loginUser => _loginUser;
  void updateLoginUser(LoginUserStruct user) {
    _loginUser = user;
    notifyListeners();
  }

  void updateLoginUserFields({
    String? fullName,
    String? firstName,
    String? displayName,
    String? email,
    String? userId,
    List<String>? roles,
    String? photoUrl,
  }) {
    _loginUser = LoginUserStruct(
      fullName: fullName ?? _loginUser.fullName,
      firstName: firstName ?? _loginUser.firstName,
      displayName: displayName ?? _loginUser.displayName,
      email: email ?? _loginUser.email,
      userId: userId ?? _loginUser.userId,
      roles: roles ?? _loginUser.roles,
      photoUrl: photoUrl ?? _loginUser.photoUrl,
    );
    notifyListeners();
  }

  void clearLoginUser() {
    _loginUser = LoginUserStruct.fromSerializableMap({'roles': '[]'});
    notifyListeners();
  }
}
