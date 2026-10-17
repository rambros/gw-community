import 'package:flutter/foundation.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/portal_activity_link.dart';

/// Media stored on the library item. List cards do not load every column.
class PortalItemMedia {
  const PortalItemMedia({
    this.text,
    this.videoUrl,
    this.audioUrl,
    this.midiaFileUrl,
    this.transcript,
    this.filenameRecorded,
    this.filenameSelected,
    this.audioDuration,
  });

  final String? text;
  final String? videoUrl;
  final String? audioUrl;
  final String? midiaFileUrl;
  final String? transcript;
  final String? filenameRecorded;
  final String? filenameSelected;
  final String? audioDuration;
}

class StepActivityLinkRepository {
  Future<List<CcJourneysRow>> journeysForLinker({
    required bool isAdmin,
    required String userId,
  }) async {
    if (isAdmin) {
      return CcJourneysTable().queryRows(
        queryFn: (query) => query.order('title', ascending: true),
      );
    }

    final groupIds = await _managedGroupIds(userId);
    if (groupIds.isEmpty) return [];

    final rows = await SupaFlow.client
        .from('cc_group_journeys')
        .select('journey_id, cc_journeys!inner(*)')
        .inFilter('group_id', groupIds)
        .isFilter('deleted_at', null);

    final journeys = <int, CcJourneysRow>{};
    for (final row in rows as List) {
      final data = row['cc_journeys'];
      if (data is! Map) continue;
      final journey = CcJourneysRow(Map<String, dynamic>.from(data));
      journeys[journey.id] = journey;
    }

    final list = journeys.values.toList()
      ..sort(
        (a, b) => (a.title ?? '').toLowerCase().compareTo(
              (b.title ?? '').toLowerCase(),
            ),
      );
    return list;
  }

  Future<List<CcJourneyStepsRow>> stepsForJourney(int journeyId) {
    return CcJourneyStepsTable().queryRows(
      queryFn: (query) => query
          .eq('journey_id', journeyId)
          .order('step_number', ascending: true),
    );
  }

  Future<PortalItemMedia?> portalMedia(int portalItemId) async {
    final row = await SupaFlow.client
        .from('portal_item')
        .select(
          'text, video_url, audio_url, midia_file_url, transcript, '
          'filename_recorded, filename_selected, audio_duration',
        )
        .eq('id', portalItemId)
        .maybeSingle();
    if (row == null) return null;
    return PortalItemMedia(
      text: _filled(row['text'] as String?),
      videoUrl: _filled(row['video_url'] as String?),
      audioUrl: _filled(row['audio_url'] as String?),
      midiaFileUrl: _filled(row['midia_file_url'] as String?),
      transcript: _filled(row['transcript'] as String?),
      filenameRecorded: _filled(row['filename_recorded'] as String?),
      filenameSelected: _filled(row['filename_selected'] as String?),
      audioDuration: _filled(row['audio_duration'] as String?),
    );
  }

  Future<int> nextOrder(int stepId) async {
    final response = await SupaFlow.client.rpc(
      'next_step_activity_order',
      params: {'p_step_id': stepId},
    );
    return _asInt(response);
  }

  Future<int> createActivity({
    required int stepId,
    required PortalActivityInput input,
  }) async {
    final response = await SupaFlow.client.rpc(
      'create_step_activity_from_content',
      params: {
        'p_step_id': stepId,
        'p_activity_label': input.label.trim(),
        'p_activity_prompt': input.prompt.trim(),
        'p_activity_type': input.activityType,
        'p_is_required': input.isRequired,
        if (input.orderInStep != null) 'p_order_in_step': input.orderInStep,
        if (_filled(input.audioUrl) != null) 'p_audio_url': input.audioUrl!.trim(),
        if (_filled(input.audioFilename) != null)
          'p_audio_filename': input.audioFilename!.trim(),
        if (_filled(input.audioDuration) != null)
          'p_audio_duration': input.audioDuration!.trim(),
        if (_filled(input.transcript) != null)
          'p_transcript': input.transcript!.trim(),
        if (_filled(input.videoUrl) != null) 'p_video_url': input.videoUrl!.trim(),
        if (_filled(input.pdfUrl) != null) 'p_pdf_url': input.pdfUrl!.trim(),
        if (_filled(input.text) != null) 'p_text': input.text!.trim(),
      },
    );
    return _asInt(response);
  }

  Future<List<int>> _managedGroupIds(String userId) async {
    try {
      final rows = await CcGroupMembersTable().queryRows(
        queryFn: (query) => query.eq('user_id', userId),
      );
      return rows.where((row) {
        final role = UserRole.fromString(row.userRole);
        return role == UserRole.groupManager || role == UserRole.admin;
      })
          .map((row) => row.groupId)
          .whereType<int>()
          .toList();
    } catch (error) {
      debugPrint('StepActivityLinkRepository._managedGroupIds: $error');
      return [];
    }
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.parse(value.toString());
  }

  String? _filled(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    return trimmed;
  }
}
