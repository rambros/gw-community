// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LoginUserStruct extends BaseStruct {
  LoginUserStruct({
    String? fullName,
    String? firstName,
    String? displayName,
    String? email,
    String? userId,
    List<String>? roles,
    String? photoUrl,
  })  : _fullName = fullName,
        _firstName = firstName,
        _displayName = displayName,
        _email = email,
        _userId = userId,
        _roles = roles,
        _photoUrl = photoUrl;

  // "fullName" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  set fullName(String? val) => _fullName = val;

  bool hasFullName() => _fullName != null;

  // "firstName" field.
  String? _firstName;
  String get firstName => _firstName ?? '';
  set firstName(String? val) => _firstName = val;

  bool hasFirstName() => _firstName != null;

  // "displayName" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  set displayName(String? val) => _displayName = val;

  bool hasDisplayName() => _displayName != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  set email(String? val) => _email = val;

  bool hasEmail() => _email != null;

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  set userId(String? val) => _userId = val;

  bool hasUserId() => _userId != null;

  // "roles" field.
  List<String>? _roles;
  List<String> get roles => _roles ?? const [];
  set roles(List<String>? val) => _roles = val;

  void updateRoles(Function(List<String>) updateFn) {
    updateFn(_roles ??= []);
  }

  bool hasRoles() => _roles != null;

  // "photoUrl" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  set photoUrl(String? val) => _photoUrl = val;

  bool hasPhotoUrl() => _photoUrl != null;

  static LoginUserStruct fromMap(Map<String, dynamic> data) => LoginUserStruct(
        fullName: data['fullName'] as String?,
        firstName: data['firstName'] as String?,
        displayName: data['displayName'] as String?,
        email: data['email'] as String?,
        userId: data['userId'] as String?,
        roles: getDataList(data['roles']),
        photoUrl: data['photoUrl'] as String?,
      );

  static LoginUserStruct? maybeFromMap(dynamic data) => data is Map
      ? LoginUserStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'fullName': _fullName,
        'firstName': _firstName,
        'displayName': _displayName,
        'email': _email,
        'userId': _userId,
        'roles': _roles,
        'photoUrl': _photoUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'fullName': serializeParam(
          _fullName,
          ParamType.String,
        ),
        'firstName': serializeParam(
          _firstName,
          ParamType.String,
        ),
        'displayName': serializeParam(
          _displayName,
          ParamType.String,
        ),
        'email': serializeParam(
          _email,
          ParamType.String,
        ),
        'userId': serializeParam(
          _userId,
          ParamType.String,
        ),
        'roles': serializeParam(
          _roles,
          ParamType.String,
          isList: true,
        ),
        'photoUrl': serializeParam(
          _photoUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static LoginUserStruct fromSerializableMap(Map<String, dynamic> data) =>
      LoginUserStruct(
        fullName: deserializeParam(
          data['fullName'],
          ParamType.String,
          false,
        ),
        firstName: deserializeParam(
          data['firstName'],
          ParamType.String,
          false,
        ),
        displayName: deserializeParam(
          data['displayName'],
          ParamType.String,
          false,
        ),
        email: deserializeParam(
          data['email'],
          ParamType.String,
          false,
        ),
        userId: deserializeParam(
          data['userId'],
          ParamType.String,
          false,
        ),
        roles: deserializeParam<String>(
          data['roles'],
          ParamType.String,
          true,
        ),
        photoUrl: deserializeParam(
          data['photoUrl'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'LoginUserStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is LoginUserStruct &&
        fullName == other.fullName &&
        firstName == other.firstName &&
        displayName == other.displayName &&
        email == other.email &&
        userId == other.userId &&
        listEquality.equals(roles, other.roles) &&
        photoUrl == other.photoUrl;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([fullName, firstName, displayName, email, userId, roles, photoUrl]);
}

LoginUserStruct createLoginUserStruct({
  String? fullName,
  String? firstName,
  String? displayName,
  String? email,
  String? userId,
  String? photoUrl,
}) =>
    LoginUserStruct(
      fullName: fullName,
      firstName: firstName,
      displayName: displayName,
      email: email,
      userId: userId,
      photoUrl: photoUrl,
    );
