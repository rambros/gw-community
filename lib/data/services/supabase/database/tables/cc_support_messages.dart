import 'package:gw_community/data/services/supabase/database/database.dart';

class CcSupportMessagesTable extends SupabaseTable<CcSupportMessagesRow> {
  @override
  String get tableName => 'cc_support_messages';

  @override
  CcSupportMessagesRow createRow(Map<String, dynamic> data) =>
      CcSupportMessagesRow(data);
}

class CcSupportMessagesRow extends SupabaseDataRow {
  CcSupportMessagesRow(super.data);

  @override
  SupabaseTable get table => CcSupportMessagesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get requestId => getField<int>('request_id')!;
  set requestId(int value) => setField<int>('request_id', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  // Author info
  String get authorId => getField<String>('author_id')!;
  set authorId(String value) => setField<String>('author_id', value);

  String get authorName => getField<String>('author_name')!;
  set authorName(String value) => setField<String>('author_name', value);

  String get authorType => getField<String>('author_type')!;
  set authorType(String value) => setField<String>('author_type', value);

  String? get authorPhoto => getField<String>('author_photo');
  set authorPhoto(String? value) => setField<String>('author_photo', value);

  // Image attachment
  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  String? get imageName => getField<String>('image_name');
  set imageName(String? value) => setField<String>('image_name', value);

  // Metadata
  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  bool get isRead => getField<bool>('is_read') ?? false;
  set isRead(bool value) => setField<bool>('is_read', value);

  // Helper getters
  bool get isFromUser => authorType == 'user';
  bool get isFromAdmin => authorType == 'admin';
  bool get isFromSystem => authorType == 'system';
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  // Helper getter for display author type
  String get displayAuthorType {
    switch (authorType) {
      case 'user':
        return 'You';
      case 'admin':
        return 'Support';
      case 'system':
        return 'System';
      default:
        return authorType;
    }
  }
}
