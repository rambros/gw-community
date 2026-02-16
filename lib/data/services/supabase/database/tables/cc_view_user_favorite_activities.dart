import 'package:gw_community/data/services/supabase/database/database.dart';

class CcViewUserFavoriteActivitiesTable extends SupabaseTable<CcViewUserFavoriteActivitiesRow> {
  @override
  String get tableName => 'cc_view_user_favorite_activities';

  @override
  CcViewUserFavoriteActivitiesRow createRow(Map<String, dynamic> data) => CcViewUserFavoriteActivitiesRow(data);
}

class CcViewUserFavoriteActivitiesRow extends SupabaseDataRow {
  CcViewUserFavoriteActivitiesRow(super.data);

  @override
  SupabaseTable get table => CcViewUserFavoriteActivitiesTable();

  // Favorite fields
  int? get favoriteId => getField<int>('favorite_id');
  String? get memberId => getField<String>('member_id');
  DateTime? get favoritedAt => getField<DateTime>('favorited_at');

  // Activity fields (from cc_step_activities)
  int get id => getField<int>('id')!;
  int? get stepId => getField<int>('step_id');
  int? get orderInStep => getField<int>('order_in_step');
  String? get activityPrompt => getField<String>('activity_prompt');
  String? get activityType => getField<String>('activity_type');
  String? get activityLabel => getField<String>('activity_label');
  String? get text => getField<String>('text');
  String? get audioUrl => getField<String>('audio_url');
  String? get audioFilename => getField<String>('audio_filename');
  String? get audioDuration => getField<String>('audio_duration');
  String? get videoUrl => getField<String>('video_url');
  String? get journal => getField<String>('journal');
  String? get journeyTitle => getField<String>('journey_title');
  int? get stepNumber => getField<int>('step_number');
  String? get stepTitle => getField<String>('step_title');
}
