// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CottEventStruct extends BaseStruct {
  CottEventStruct({
    int? id,
    CottEventType? eventType,
    String? theme,
    List<String>? speakers,
    String? local,
    String? region,
    String? year,
  })  : _id = id,
        _eventType = eventType,
        _theme = theme,
        _speakers = speakers,
        _local = local,
        _region = region,
        _year = year;

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "eventType" field.
  CottEventType? _eventType;
  CottEventType? get eventType => _eventType;
  set eventType(CottEventType? val) => _eventType = val;

  bool hasEventType() => _eventType != null;

  // "theme" field.
  String? _theme;
  String get theme => _theme ?? '';
  set theme(String? val) => _theme = val;

  bool hasTheme() => _theme != null;

  // "speakers" field.
  List<String>? _speakers;
  List<String> get speakers => _speakers ?? const [];
  set speakers(List<String>? val) => _speakers = val;

  void updateSpeakers(Function(List<String>) updateFn) {
    updateFn(_speakers ??= []);
  }

  bool hasSpeakers() => _speakers != null;

  // "local" field.
  String? _local;
  String get local => _local ?? '';
  set local(String? val) => _local = val;

  bool hasLocal() => _local != null;

  // "region" field.
  String? _region;
  String get region => _region ?? '';
  set region(String? val) => _region = val;

  bool hasRegion() => _region != null;

  // "year" field.
  String? _year;
  String get year => _year ?? '';
  set year(String? val) => _year = val;

  bool hasYear() => _year != null;

  static CottEventStruct fromMap(Map<String, dynamic> data) => CottEventStruct(
        id: castToType<int>(data['id']),
        eventType: data['eventType'] is CottEventType
            ? data['eventType']
            : deserializeEnum<CottEventType>(data['eventType']),
        theme: data['theme'] as String?,
        speakers: getDataList(data['speakers']),
        local: data['local'] as String?,
        region: data['region'] as String?,
        year: data['year'] as String?,
      );

  static CottEventStruct? maybeFromMap(dynamic data) => data is Map
      ? CottEventStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'eventType': _eventType?.serialize(),
        'theme': _theme,
        'speakers': _speakers,
        'local': _local,
        'region': _region,
        'year': _year,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'eventType': serializeParam(
          _eventType,
          ParamType.Enum,
        ),
        'theme': serializeParam(
          _theme,
          ParamType.String,
        ),
        'speakers': serializeParam(
          _speakers,
          ParamType.String,
          isList: true,
        ),
        'local': serializeParam(
          _local,
          ParamType.String,
        ),
        'region': serializeParam(
          _region,
          ParamType.String,
        ),
        'year': serializeParam(
          _year,
          ParamType.String,
        ),
      }.withoutNulls;

  static CottEventStruct fromSerializableMap(Map<String, dynamic> data) =>
      CottEventStruct(
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        eventType: deserializeParam<CottEventType>(
          data['eventType'],
          ParamType.Enum,
          false,
        ),
        theme: deserializeParam(
          data['theme'],
          ParamType.String,
          false,
        ),
        speakers: deserializeParam<String>(
          data['speakers'],
          ParamType.String,
          true,
        ),
        local: deserializeParam(
          data['local'],
          ParamType.String,
          false,
        ),
        region: deserializeParam(
          data['region'],
          ParamType.String,
          false,
        ),
        year: deserializeParam(
          data['year'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CottEventStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is CottEventStruct &&
        id == other.id &&
        eventType == other.eventType &&
        theme == other.theme &&
        listEquality.equals(speakers, other.speakers) &&
        local == other.local &&
        region == other.region &&
        year == other.year;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([id, eventType, theme, speakers, local, region, year]);
}

CottEventStruct createCottEventStruct({
  int? id,
  CottEventType? eventType,
  String? theme,
  String? local,
  String? region,
  String? year,
}) =>
    CottEventStruct(
      id: id,
      eventType: eventType,
      theme: theme,
      local: local,
      region: region,
      year: year,
    );
