/// Auth links that arrive from the invite site or the `gw://` app scheme.
///
/// Password reset and magic links both land here. The query (and, for the
/// implicit flow, the fragment) carries the token the app has to exchange
/// before it can show the new-password screen.
class AuthCallbackLink {
  AuthCallbackLink._({
    required this.isAccessLink,
    required this.params,
  });

  final bool isAccessLink;
  final Map<String, String> params;

  bool get isRecovery => params['type'] == 'recovery';

  String? get tokenHash {
    final value = params['token_hash'];
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? get code {
    final value = params['code'];
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? get errorCode {
    final code = params['error_code'];
    if (code != null && code.isNotEmpty) return code;
    final error = params['error'];
    if (error != null && error.isNotEmpty) return error;
    return null;
  }

  bool get hasSessionPayload =>
      code != null || (params['access_token']?.isNotEmpty ?? false);

  bool get hasPayload => tokenHash != null || hasSessionPayload;

  /// Token stored so a re-delivered link is not verified twice.
  /// Access tokens are not persisted.
  String? get persistKey => tokenHash ?? code;

  String get dedupeKey {
    final token = persistKey ?? params['access_token'];
    if (token != null && token.isNotEmpty) return token;
    return '${isAccessLink ? 'access' : 'login'}:${errorCode ?? 'empty'}';
  }

  /// go_router location that preserves the auth parameters.
  String get inAppLocation {
    final path = isAccessLink ? '/access-link' : '/login-callback';
    if (params.isEmpty) return path;
    return Uri(path: path, queryParameters: params).toString();
  }

  static AuthCallbackLink? tryParse(Uri uri) {
    if (!_hostOk(uri)) return null;

    final path = uri.path;
    final isAccess = path.startsWith('/access-link') ||
        (uri.scheme == 'gw' && uri.host == 'access-link');
    final isLogin = path.startsWith('/login-callback') ||
        (uri.scheme == 'gw' && uri.host == 'login-callback');
    if (!isAccess && !isLogin) return null;

    return AuthCallbackLink._(
      isAccessLink: isAccess,
      params: _mergedParams(uri),
    );
  }

  static bool _hostOk(Uri uri) {
    if (uri.scheme == 'gw' || uri.scheme.isEmpty) return true;
    if (uri.scheme != 'https' && uri.scheme != 'http') return false;
    return uri.host.isEmpty ||
        uri.host == 'invite.callofthetime.org' ||
        uri.host == 'gw-invite.web.app';
  }

  static Map<String, String> _mergedParams(Uri uri) {
    final params = <String, String>{};
    if (uri.fragment.isNotEmpty) {
      try {
        params.addAll(Uri.splitQueryString(uri.fragment));
      } catch (_) {}
    }
    params.addAll(uri.queryParameters);
    return params;
  }
}
