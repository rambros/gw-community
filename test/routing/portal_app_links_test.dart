import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/routing/portal_app_links.dart';

void main() {
  group('PortalAppLinks', () {
    test('builds a share/email URL for any event id', () {
      expect(
        PortalAppLinks.event(98),
        'https://invite.callofthetime.org/event?id=98',
      );
      expect(
        PortalAppLinks.event(12),
        'https://invite.callofthetime.org/event?id=12',
      );
    });

    test('builds a share/email URL for any content id', () {
      expect(
        PortalAppLinks.content(421),
        'https://invite.callofthetime.org/content?id=421',
      );
    });

    test('maps HTTPS event links to the in-app event screen', () {
      expect(
        PortalAppLinks.inAppLocation(
          Uri.parse('https://invite.callofthetime.org/event?id=98'),
        ),
        '/event?id=98',
      );
    });

    test('maps custom-scheme links used as a web fallback', () {
      expect(
        PortalAppLinks.inAppLocation(Uri.parse('gw://event?id=7')),
        '/event?id=7',
      );
      expect(
        PortalAppLinks.inAppLocation(Uri.parse('gw://content?id=15')),
        '/content?id=15',
      );
    });

    test('recovers the event id when the URL is pasted twice', () {
      expect(
        PortalAppLinks.inAppLocation(
          Uri.parse(
            'https://invite.callofthetime.org/event?id=98 https://invite.callofthetime.org/event?id=98',
          ),
        ),
        '/event?id=98',
      );
    });

    test('ignores auth links and missing ids', () {
      expect(
        PortalAppLinks.inAppLocation(
          Uri.parse('https://invite.callofthetime.org/access-link?token_hash=abc'),
        ),
        isNull,
      );
      expect(
        PortalAppLinks.inAppLocation(
          Uri.parse('https://invite.callofthetime.org/event'),
        ),
        isNull,
      );
    });
  });
}
