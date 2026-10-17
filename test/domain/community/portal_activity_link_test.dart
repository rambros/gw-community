import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/domain/community/portal_activity_link.dart';

void main() {
  group('portalActivityDraftFromContent', () {
    test('maps an audio recording onto the audio fields', () {
      final draft = portalActivityDraftFromContent(
        midiaType: 'Audio',
        audioUrl: ' https://cdn.example/talk.mp3 ',
        midiaFileUrl: 'https://cdn.example/ignored.pdf',
        transcript: 'Hello',
        filenameRecorded: 'talk.mp3',
        audioDuration: '12:00',
      );

      expect(draft.activityType, 'audio');
      expect(draft.audioUrl, 'https://cdn.example/talk.mp3');
      expect(draft.audioFilename, 'talk.mp3');
      expect(draft.audioDuration, '12:00');
      expect(draft.transcript, 'Hello');
      expect(draft.videoUrl, isNull);
      expect(draft.pdfUrl, isNull);
    });

    test('uses the portal video url, then the media file', () {
      final fromPortal = portalActivityDraftFromContent(
        midiaType: 'Vídeo',
        videoUrl: 'https://cdn.example/talk.mp4',
        midiaFileUrl: 'https://cdn.example/other.mp4',
      );
      final fromFile = portalActivityDraftFromContent(
        midiaType: 'video',
        midiaFileUrl: 'https://cdn.example/other.mp4',
      );

      expect(fromPortal.activityType, 'video');
      expect(fromPortal.videoUrl, 'https://cdn.example/talk.mp4');
      expect(fromFile.videoUrl, 'https://cdn.example/other.mp4');
    });

    test('fills a missing list column from the stored library item', () {
      expect(
        filledPortalValue(listed: null, stored: ' Dear friends '),
        'Dear friends',
      );
      expect(
        filledPortalValue(
          listed: 'https://cdn.example/card.mp3',
          stored: 'https://cdn.example/stored.mp3',
        ),
        'https://cdn.example/card.mp3',
      );

      final draft = portalActivityDraftFromContent(
        midiaType: 'text',
        text: filledPortalValue(listed: null, stored: 'Dear friends'),
      );
      final input = PortalActivityInput(
        label: 'Inspiration',
        prompt: 'Whatever is inside gets expressed outside',
        activityType: draft.activityType,
        isRequired: false,
        orderInStep: 4,
        text: draft.text,
      );

      expect(input.validate(), isNull);
    });

    test('maps text and pdf, and treats a bare audio url as audio', () {
      final text = portalActivityDraftFromContent(
        midiaType: 'Texto',
        text: ' A message ',
      );
      final pdf = portalActivityDraftFromContent(
        midiaType: 'PDF',
        midiaFileUrl: 'https://cdn.example/notes.pdf',
      );
      final audioFallback = portalActivityDraftFromContent(
        audioUrl: 'https://cdn.example/talk.mp3',
      );

      expect(text.activityType, 'text');
      expect(text.text, 'A message');
      expect(pdf.activityType, 'pdf');
      expect(pdf.pdfUrl, 'https://cdn.example/notes.pdf');
      expect(audioFallback.activityType, 'audio');
      expect(audioFallback.audioUrl, 'https://cdn.example/talk.mp3');
    });
  });

  group('PortalActivityInput.validate', () {
    PortalActivityInput input({
      String label = 'Meditation',
      String prompt = 'Listen',
      String activityType = 'audio',
      String? audioUrl = 'https://cdn.example/talk.mp3',
      int? orderInStep = 2,
    }) {
      return PortalActivityInput(
        label: label,
        prompt: prompt,
        activityType: activityType,
        isRequired: true,
        orderInStep: orderInStep,
        audioUrl: audioUrl,
      );
    }

    test('accepts a complete audio activity and an empty order', () {
      expect(input().validate(), isNull);
      expect(input(orderInStep: null).validate(), isNull);
    });

    test('rejects a missing label, a long prompt, and missing media', () {
      expect(input(label: '  ').validate(), PortalActivityValidation.labelRequired);
      expect(
        input(label: 'x' * 41).validate(),
        PortalActivityValidation.labelTooLong,
      );
      expect(
        input(prompt: 'p' * 131).validate(),
        PortalActivityValidation.promptTooLong,
      );
      expect(
        input(audioUrl: '').validate(),
        PortalActivityValidation.mediaMissing,
      );
      expect(input(orderInStep: 0).validate(), PortalActivityValidation.orderInvalid);
    });
  });

  test('resolvePortalActivityLabel keeps presets and custom text', () {
    expect(
      resolvePortalActivityLabel(dropdownValue: 'Journal', customText: ''),
      'Journal',
    );
    expect(
      resolvePortalActivityLabel(
        dropdownValue: portalActivityCustomLabel,
        customText: ' Sharing ',
      ),
      'Sharing',
    );
    expect(
      resolvePortalActivityLabel(
        dropdownValue: portalActivityCustomLabel,
        customText: '  ',
      ),
      '',
    );
  });
}
