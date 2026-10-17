/// Activity label presets shared with the admin activity form.
const portalActivityLabelPresets = [
  'Meditation',
  'Inspiration',
  'Daily Practice',
  'Journal',
];

const portalActivityCustomLabel = '__custom__';

const portalActivityLabelMaxLength = 40;
const portalActivityPromptMaxLength = 130;

enum PortalActivityValidation {
  labelRequired,
  labelTooLong,
  promptRequired,
  promptTooLong,
  mediaMissing,
  orderInvalid,
}

/// Media copied from a portal item onto a new step activity.
class PortalActivityDraft {
  const PortalActivityDraft({
    required this.activityType,
    this.audioUrl,
    this.audioFilename,
    this.audioDuration,
    this.transcript,
    this.videoUrl,
    this.pdfUrl,
    this.text,
  });

  final String activityType;
  final String? audioUrl;
  final String? audioFilename;
  final String? audioDuration;
  final String? transcript;
  final String? videoUrl;
  final String? pdfUrl;
  final String? text;

  String? get mediaValue {
    switch (activityType) {
      case 'audio':
        return audioUrl;
      case 'video':
        return videoUrl;
      case 'pdf':
        return pdfUrl;
      case 'text':
        return text;
      default:
        return null;
    }
  }
}

class PortalActivityInput {
  const PortalActivityInput({
    required this.label,
    required this.prompt,
    required this.activityType,
    required this.isRequired,
    this.orderInStep,
    this.audioUrl,
    this.audioFilename,
    this.audioDuration,
    this.transcript,
    this.videoUrl,
    this.pdfUrl,
    this.text,
  });

  final String label;
  final String prompt;
  final String activityType;
  final bool isRequired;
  final int? orderInStep;
  final String? audioUrl;
  final String? audioFilename;
  final String? audioDuration;
  final String? transcript;
  final String? videoUrl;
  final String? pdfUrl;
  final String? text;

  PortalActivityValidation? validate() {
    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) return PortalActivityValidation.labelRequired;
    if (trimmedLabel.length > portalActivityLabelMaxLength) {
      return PortalActivityValidation.labelTooLong;
    }

    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) return PortalActivityValidation.promptRequired;
    if (trimmedPrompt.length > portalActivityPromptMaxLength) {
      return PortalActivityValidation.promptTooLong;
    }

    if (orderInStep != null && orderInStep! < 1) {
      return PortalActivityValidation.orderInvalid;
    }

    final media = switch (activityType) {
      'audio' => audioUrl,
      'video' => videoUrl,
      'pdf' => pdfUrl,
      'text' => text,
      _ => null,
    };
    if (media == null || media.trim().isEmpty) {
      return PortalActivityValidation.mediaMissing;
    }
    return null;
  }
}

/// Resolves a preset or a custom label. Empty custom text yields null.
String? resolvePortalActivityLabel({
  required String? dropdownValue,
  required String? customText,
}) {
  if (dropdownValue == null || dropdownValue.isEmpty) return null;
  if (dropdownValue == portalActivityCustomLabel) {
    final trimmed = customText?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    return trimmed;
  }
  if (portalActivityLabelPresets.contains(dropdownValue)) return dropdownValue;
  return null;
}

/// Uses the value already on the library card, then the stored library item.
///
/// List rows omit the text body and some media columns, so the link form
/// fills those gaps from `portal_item` before building the activity.
String? filledPortalValue({String? listed, String? stored}) {
  return _filled(listed) ?? _filled(stored);
}

/// Maps a portal item the same way group linking classifies its file.
///
/// Audio, video, and text come from [midiaType]. Anything else is a PDF,
/// unless the item already has an audio URL.
PortalActivityDraft portalActivityDraftFromContent({
  String? midiaType,
  String? audioUrl,
  String? midiaFileUrl,
  String? videoUrl,
  String? text,
  String? transcript,
  String? filenameRecorded,
  String? filenameSelected,
  String? audioDuration,
}) {
  final type = _activityType(midiaType, audioUrl);
  switch (type) {
    case 'audio':
      return PortalActivityDraft(
        activityType: type,
        audioUrl: _filled(audioUrl),
        audioFilename: _filled(filenameRecorded) ?? _filled(filenameSelected),
        audioDuration: _filled(audioDuration),
        transcript: _filled(transcript),
      );
    case 'video':
      return PortalActivityDraft(
        activityType: type,
        videoUrl: _filled(videoUrl) ?? _filled(midiaFileUrl),
      );
    case 'text':
      return PortalActivityDraft(
        activityType: type,
        text: _filled(text),
      );
    default:
      return PortalActivityDraft(
        activityType: 'pdf',
        pdfUrl: _filled(midiaFileUrl),
      );
  }
}

String _activityType(String? midiaType, String? audioUrl) {
  final type = (midiaType ?? '').toLowerCase();
  if (type.contains('audio') || type.contains('áudio')) return 'audio';
  if (type.contains('video') || type.contains('vídeo')) return 'video';
  if (type.contains('text') || type.contains('texto')) return 'text';
  if (_filled(audioUrl) != null) return 'audio';
  return 'pdf';
}

String? _filled(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  return trimmed;
}
