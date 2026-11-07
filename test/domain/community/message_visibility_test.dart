import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/domain/community/message_visibility.dart';

void main() {
  test('the author of a facilitator message sees replies on it', () {
    expect(
      authorSeesFacilitatorReplies(
        audience: 'facilitators',
        authorUserId: 'member',
        viewerId: 'member',
      ),
      isTrue,
    );
    expect(
      authorSeesFacilitatorReplies(
        audience: 'facilitators',
        authorUserId: 'member',
        viewerId: 'other',
      ),
      isFalse,
    );
    expect(
      authorSeesFacilitatorReplies(
        audience: null,
        authorUserId: 'member',
        viewerId: 'member',
      ),
      isFalse,
    );
  });

  test('facilitator messages are hidden from other members', () {
    expect(
      canSeeGroupMessage(
        audience: 'facilitators',
        recipientUserId: null,
        authorUserId: 'member',
        viewerId: 'other',
        viewerIsFacilitator: false,
      ),
      isFalse,
    );
    expect(
      canSeeGroupMessage(
        audience: 'facilitators',
        recipientUserId: null,
        authorUserId: 'member',
        viewerId: 'facilitator',
        viewerIsFacilitator: true,
      ),
      isTrue,
    );
    expect(
      canSeeGroupMessage(
        audience: 'facilitators',
        recipientUserId: null,
        authorUserId: 'member',
        viewerId: 'member',
        viewerIsFacilitator: false,
      ),
      isTrue,
    );
  });

  test('a private message stays with the author and the recipient', () {
    expect(
      canSeeGroupMessage(
        audience: null,
        recipientUserId: 'member',
        authorUserId: 'facilitator',
        viewerId: 'other',
        viewerIsFacilitator: true,
      ),
      isFalse,
    );
    expect(
      canSeeGroupMessage(
        audience: null,
        recipientUserId: 'member',
        authorUserId: 'facilitator',
        viewerId: 'member',
        viewerIsFacilitator: false,
      ),
      isTrue,
    );
  });

  test('a group message is visible to everyone in the group', () {
    expect(
      canSeeGroupMessage(
        audience: null,
        recipientUserId: null,
        authorUserId: 'facilitator',
        viewerId: 'member',
        viewerIsFacilitator: false,
      ),
      isTrue,
    );
  });

  test('messages for the facilitator exclude the ones they wrote', () {
    expect(
      isMessageForFacilitator(
        audience: 'facilitators',
        recipientUserId: null,
        authorUserId: 'member',
        viewerId: 'facilitator',
      ),
      isTrue,
    );
    expect(
      isMessageForFacilitator(
        audience: 'facilitators',
        recipientUserId: null,
        authorUserId: 'member',
        viewerId: 'member',
      ),
      isFalse,
    );
  });
}
