import 'package:gw_community/data/services/supabase/database/database.dart';

class CcSettingsTable extends SupabaseTable<CcSettingsRow> {
  @override
  String get tableName => 'cc_settings';

  @override
  CcSettingsRow createRow(Map<String, dynamic> data) => CcSettingsRow(data);
}

class CcSettingsRow extends SupabaseDataRow {
  CcSettingsRow(super.data);

  @override
  SupabaseTable get table => CcSettingsTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get settingKey => getField<String>('setting_key');
  set settingKey(String? value) => setField<String>('setting_key', value);

  String? get settingName => getField<String>('setting_name');
  set settingName(String? value) => setField<String>('setting_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get value => getField<String>('value');
  set value(String? value) => setField<String>('value', value);

  String? get valueType => getField<String>('value_type');
  set valueType(String? value) => setField<String>('value_type', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  bool? get isEncrypted => getField<bool>('is_encrypted');
  set isEncrypted(bool? value) => setField<bool>('is_encrypted', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
