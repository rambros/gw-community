import '/backend/supabase/supabase.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_util.dart';

/// Repository responsável por todas as operações de dados relacionadas a eventos.
class EventRepository {
  Future<CcEventsRow?> getEventById(int id) async {
    final result = await CcEventsTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', id),
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<CcUsersRow>> getParticipants(int eventId) async {
    final result = await actions.getListParticipants(eventId.toString());
    return result.toList().cast<CcUsersRow>();
  }

  Future<void> registerUser({
    required int eventId,
    required String userId,
  }) async {
    await CcEventRegistrationsTable().insert({
      'user_id': userId,
      'event_id': eventId,
    });
  }

  Future<void> unregisterUser({
    required int eventId,
    required String userId,
  }) async {
    await CcEventRegistrationsTable().delete(
      matchingRows: (rows) => rows.eqOrNull('user_id', userId).eqOrNull('event_id', eventId),
    );
  }

  Future<void> deleteEvent(int eventId) async {
    await CcEventsTable().delete(
      matchingRows: (rows) => rows.eqOrNull('id', eventId),
    );
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required String facilitatorName,
    required String facilitatorId,
    required DateTime eventDate,
    required DateTime eventTime,
    required int durationMinutes,
    required String status,
    required String visibility,
    String? registrationUrl,
    int? groupId,
  }) async {
    await CcEventsTable().insert({
      'title': title,
      'description': description,
      'group_id': groupId,
      'event_date': supaSerialize<DateTime>(eventDate),
      'duration': durationMinutes,
      'event_page_url': registrationUrl,
      'event_status': status,
      'date_created': supaSerialize<DateTime>(getCurrentTimestamp),
      'event_time': supaSerialize<PostgresTime>(PostgresTime(eventTime)),
      'facilitator_name': facilitatorName,
      'facilitator_id': facilitatorId,
      'visibility': visibility,
    });
  }

  Future<void> updateEvent({
    required int id,
    required String title,
    required String description,
    required String facilitatorName,
    required String facilitatorId,
    required DateTime eventDate,
    required DateTime eventTime,
    required int durationMinutes,
    required String status,
    required String visibility,
    String? registrationUrl,
  }) async {
    await CcEventsTable().update(
      data: {
        'title': title,
        'description': description,
        'event_date': supaSerialize<DateTime>(eventDate),
        'duration': durationMinutes,
        'event_page_url': registrationUrl,
        'event_status': status,
        'event_time': supaSerialize<PostgresTime>(PostgresTime(eventTime)),
        'facilitator_name': facilitatorName,
        'facilitator_id': facilitatorId,
        'visibility': visibility,
      },
      matchingRows: (rows) => rows.eqOrNull('id', id),
    );
  }

  Stream<List<CcEventsRow>> getEventsStream(int groupId) {
    return SupaFlow.client
        .from("cc_events")
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('event_date')
        .map((list) => list.map((item) => CcEventsRow(item)).toList());
  }
}
