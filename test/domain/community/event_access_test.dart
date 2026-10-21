import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/domain/community/event_access.dart';

void main() {
  const outsider = 'outsider';
  const memberGroups = {6};

  bool canSee({
    String? visibility,
    int? groupId,
    String? facilitatorId,
    String? userId = outsider,
    Set<int> groups = memberGroups,
  }) {
    return eventVisibleToUser(
      visibility: visibility,
      groupId: groupId,
      facilitatorId: facilitatorId,
      userId: userId,
      memberGroupIds: groups,
    );
  }

  test('hides a group-only event from someone outside the group', () {
    expect(canSee(visibility: 'group_only', groupId: 5), isFalse);
  });

  test('shows a group-only event to a member of that group', () {
    expect(
      canSee(visibility: 'group_only', groupId: 6, groups: {6}),
      isTrue,
    );
  });

  test('shows an everyone event even when the person is outside the group', () {
    expect(canSee(visibility: 'everyone', groupId: 5), isTrue);
  });

  test('treats a missing visibility on a group event as group only', () {
    expect(canSee(visibility: null, groupId: 5), isFalse);
    expect(canSee(visibility: null, groupId: 6), isTrue);
  });

  test('shows an ungrouped event with no visibility', () {
    expect(canSee(visibility: null, groupId: null, groups: {}), isTrue);
  });

  test('shows the facilitator their own group-only event', () {
    expect(
      canSee(
        visibility: 'group_only',
        groupId: 5,
        facilitatorId: outsider,
        groups: {},
      ),
      isTrue,
    );
  });

  test('hides an unknown visibility', () {
    expect(canSee(visibility: 'secret', groupId: 6), isFalse);
  });
}
