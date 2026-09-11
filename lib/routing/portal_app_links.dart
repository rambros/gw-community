/// Universal Links used in email and share to open a screen in the app.
///
/// Hosted on the invite domain so iOS/Android already treat them as app links.
class PortalAppLinks {
  static const inviteOrigin = 'https://invite.callofthetime.org';
  static const eventPath = '/event';
  static const contentPath = '/content';

  static bool isInviteHost(Uri uri) =>
      uri.host == 'invite.callofthetime.org' || uri.host == 'gw-invite.web.app';

  static String event(int id) => '$inviteOrigin$eventPath?id=$id';

  static String content(int id) => '$inviteOrigin$contentPath?id=$id';

  /// Reads the first positive integer from a query value.
  /// Handles pasted junk such as `98 https://invite.../event?id=98`.
  static int? parseId(String? raw) {
    if (raw == null) return null;
    final match = RegExp(r'\d+').firstMatch(raw.trim());
    if (match == null) return null;
    final id = int.tryParse(match.group(0)!);
    if (id == null || id <= 0) return null;
    return id;
  }

  /// In-app go_router location, or null when the URI is not a portal content link.
  static String? inAppLocation(Uri uri) {
    final kind = _kind(uri);
    final id = parseId(uri.queryParameters['id']);
    if (kind == null || id == null) return null;
    return switch (kind) {
      'event' => '$eventPath?id=$id',
      'content' => '$contentPath?id=$id',
      _ => null,
    };
  }

  static String? _kind(Uri uri) {
    if (uri.scheme == 'gw' && (uri.host == 'event' || uri.host == 'content')) {
      return uri.host;
    }
    if ((uri.scheme == 'https' || uri.scheme == 'http') && isInviteHost(uri)) {
      final path = uri.path.replaceAll(RegExp(r'/+$'), '');
      if (path == eventPath || path == contentPath) return path.substring(1);
    }
    return null;
  }
}
