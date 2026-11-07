import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/routing/auth_callback_link.dart';

void main() {
  group('AuthCallbackLink', () {
    test('reads a recovery token from the invite universal link', () {
      final link = AuthCallbackLink.tryParse(
        Uri.parse(
          'https://invite.callofthetime.org/access-link?token_hash=abc&type=recovery',
        ),
      );

      expect(link, isNotNull);
      expect(link!.isAccessLink, isTrue);
      expect(link.isRecovery, isTrue);
      expect(link.tokenHash, 'abc');
      expect(
        link.inAppLocation,
        '/access-link?token_hash=abc&type=recovery',
      );
    });

    test('reads the PKCE code from the custom scheme', () {
      final link = AuthCallbackLink.tryParse(
        Uri.parse('gw://login-callback?code=auth-code'),
      );

      expect(link, isNotNull);
      expect(link!.isAccessLink, isFalse);
      expect(link.hasSessionPayload, isTrue);
      expect(link.code, 'auth-code');
      expect(link.isRecovery, isFalse);
      expect(link.inAppLocation, '/login-callback?code=auth-code');
    });

    test('reads a recovery session from the URL fragment', () {
      final link = AuthCallbackLink.tryParse(
        Uri.parse(
          'gw://login-callback#access_token=tok&refresh_token=ref&type=recovery',
        ),
      );

      expect(link, isNotNull);
      expect(link!.isRecovery, isTrue);
      expect(link.hasSessionPayload, isTrue);
      expect(link.params['access_token'], 'tok');
    });

    test('keeps an in-app callback location', () {
      final link = AuthCallbackLink.tryParse(
        Uri.parse('/login-callback?code=abc'),
      );

      expect(link, isNotNull);
      expect(link!.inAppLocation, '/login-callback?code=abc');
    });

    test('ignores portal links and other hosts', () {
      expect(
        AuthCallbackLink.tryParse(
          Uri.parse('https://invite.callofthetime.org/event?id=98'),
        ),
        isNull,
      );
      expect(
        AuthCallbackLink.tryParse(
          Uri.parse('https://evil.example/login-callback?code=abc'),
        ),
        isNull,
      );
    });
  });
}
