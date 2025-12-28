import 'package:gw_community/data/services/supabase/database/database.dart';

class CcSupportRequestsTable extends SupabaseTable<CcSupportRequestsRow> {
  @override
  String get tableName => 'cc_support_requests';

  @override
  CcSupportRequestsRow createRow(Map<String, dynamic> data) =>
      CcSupportRequestsRow(data);
}

class CcSupportRequestsRow extends SupabaseDataRow {
  CcSupportRequestsRow(super.data);

  @override
  SupabaseTable get table => CcSupportRequestsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get requestNumber => getField<String>('request_number')!;
  set requestNumber(String value) => setField<String>('request_number', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get priority => getField<String>('priority');
  set priority(String? value) => setField<String>('priority', value);

  // Member info (membro da comunidade que criou o request)
  String get memberId => getField<String>('member_id')!;
  set memberId(String value) => setField<String>('member_id', value);

  String? get userName => getField<String>('user_name');
  set userName(String? value) => setField<String>('user_name', value);

  String? get userEmail => getField<String>('user_email');
  set userEmail(String? value) => setField<String>('user_email', value);

  // Context
  String? get contextType => getField<String>('context_type');
  set contextType(String? value) => setField<String>('context_type', value);

  int? get contextId => getField<int>('context_id');
  set contextId(int? value) => setField<int>('context_id', value);

  String? get contextTitle => getField<String>('context_title');
  set contextTitle(String? value) => setField<String>('context_title', value);

  // Admin assignment
  String? get assignedTo => getField<String>('assigned_to');
  set assignedTo(String? value) => setField<String>('assigned_to', value);

  String? get assignedName => getField<String>('assigned_name');
  set assignedName(String? value) => setField<String>('assigned_name', value);

  // Metadata
  int get messageCount => getField<int>('message_count') ?? 0;
  set messageCount(int value) => setField<int>('message_count', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  DateTime? get resolvedAt => getField<DateTime>('resolved_at');
  set resolvedAt(DateTime? value) => setField<DateTime>('resolved_at', value);

  String? get titleSearch => getField<String>('title_search');
  set titleSearch(String? value) => setField<String>('title_search', value);

  // Helper getters for status
  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isAwaitingUser => status == 'awaiting_user';
  bool get isResolved => status == 'resolved';
  bool get isClosed => isResolved;

  // Helper getter for display status
  String get displayStatus {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'Being Reviewed';
      case 'awaiting_user':
        return 'Needs Your Response';
      case 'resolved':
        return 'Completed';
      default:
        return status;
    }
  }

  // Helper getter for display category
  String get displayCategory {
    switch (category) {
      case 'journey':
        return 'Journey';
      case 'community':
        return 'Community';
      case 'account':
        return 'Account';
      case 'technical':
        return 'Technical';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }
}
