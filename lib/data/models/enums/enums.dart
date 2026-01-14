// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';

export 'user_role.dart';

enum ContentType {
  Event,
  Message,
  DJNotes,
  MansaSeva_txt,
  Meditation,
  Journeys,
}

enum CottEventType {
  COTTRetreat,
  COTTDialogue,
  EIS,
  H2HConversation,
  CircleofSustenance,
  COTTSilenceRetreat,
}

enum SortContentType {
  mostLiked,
  mostViewed,
  mostRecent,
  oldest,
  alphabetical,
}

enum SharingType {
  sharing,
  notification,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) => firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case == ContentType:
      return ContentType.values.deserialize(value) as T?;
    case == CottEventType:
      return CottEventType.values.deserialize(value) as T?;
    case == SortContentType:
      return SortContentType.values.deserialize(value) as T?;
    case == SharingType:
      return SharingType.values.deserialize(value) as T?;
    default:
      return null;
  }
}
