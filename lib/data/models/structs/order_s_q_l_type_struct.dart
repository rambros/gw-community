// ignore_for_file: unnecessary_getters_setters

import '/data/models/schema_util.dart';
import '/utils/flutter_flow_util.dart';
import 'index.dart';

class OrderSQLTypeStruct extends BaseStruct {
  OrderSQLTypeStruct({
    String? column,
    bool? asc,
  })  : _column = column,
        _asc = asc;

  // "column" field.
  String? _column;
  String get column => _column ?? '';
  set column(String? val) => _column = val;

  bool hasColumn() => _column != null;

  // "asc" field.
  bool? _asc;
  bool get asc => _asc ?? false;
  set asc(bool? val) => _asc = val;

  bool hasAsc() => _asc != null;

  static OrderSQLTypeStruct fromMap(Map<String, dynamic> data) =>
      OrderSQLTypeStruct(
        column: data['column'] as String?,
        asc: data['asc'] as bool?,
      );

  static OrderSQLTypeStruct? maybeFromMap(dynamic data) => data is Map
      ? OrderSQLTypeStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'column': _column,
        'asc': _asc,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'column': serializeParam(
          _column,
          ParamType.String,
        ),
        'asc': serializeParam(
          _asc,
          ParamType.bool,
        ),
      }.withoutNulls;

  static OrderSQLTypeStruct fromSerializableMap(Map<String, dynamic> data) =>
      OrderSQLTypeStruct(
        column: deserializeParam(
          data['column'],
          ParamType.String,
          false,
        ),
        asc: deserializeParam(
          data['asc'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'OrderSQLTypeStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is OrderSQLTypeStruct &&
        column == other.column &&
        asc == other.asc;
  }

  @override
  int get hashCode => const ListEquality().hash([column, asc]);
}

OrderSQLTypeStruct createOrderSQLTypeStruct({
  String? column,
  bool? asc,
}) =>
    OrderSQLTypeStruct(
      column: column,
      asc: asc,
    );
