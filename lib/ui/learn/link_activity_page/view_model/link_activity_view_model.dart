import 'package:flutter/foundation.dart';
import 'package:gw_community/data/repositories/step_activity_link_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/portal_activity_link.dart';

enum LinkActivityPhase { journey, step, form }

class LinkActivityViewModel extends ChangeNotifier {
  LinkActivityViewModel({
    required ViewContentRow content,
    required this.isAdmin,
    required this.userId,
    StepActivityLinkRepository? repository,
  })  : _content = content,
        _repository = repository ?? StepActivityLinkRepository();

  final ViewContentRow _content;
  final bool isAdmin;
  final String userId;
  final StepActivityLinkRepository _repository;

  LinkActivityPhase phase = LinkActivityPhase.journey;
  bool loading = true;
  bool saving = false;
  bool loadFailed = false;
  bool saveFailed = false;
  PortalActivityValidation? validationError;

  List<CcJourneysRow> journeys = [];
  List<CcJourneyStepsRow> steps = [];
  CcJourneysRow? selectedJourney;
  CcJourneyStepsRow? selectedStep;
  PortalActivityDraft? draft;
  int? suggestedOrder;
  String search = '';

  String get contentTitle => _content.title ?? '';

  List<CcJourneysRow> get visibleJourneys {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return journeys;
    return journeys
        .where((journey) => (journey.title ?? '').toLowerCase().contains(query))
        .toList();
  }

  List<CcJourneyStepsRow> get visibleSteps {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return steps;
    return steps.where((step) {
      final title = (step.title ?? '').toLowerCase();
      return title.contains(query) || '${step.stepNumber}'.contains(query);
    }).toList();
  }

  Future<void> load() async {
    loading = true;
    loadFailed = false;
    notifyListeners();
    try {
      final media = _content.contentId == null
          ? null
          : await _repository.portalMedia(_content.contentId!);
      draft = _draft(media: media);
      journeys = await _repository.journeysForLinker(
        isAdmin: isAdmin,
        userId: userId,
      );
    } catch (error) {
      debugPrint('LinkActivityViewModel.load: $error');
      loadFailed = true;
    }
    loading = false;
    notifyListeners();
  }

  Future<void> selectJourney(CcJourneysRow journey) async {
    selectedJourney = journey;
    selectedStep = null;
    steps = [];
    phase = LinkActivityPhase.step;
    search = '';
    loading = true;
    loadFailed = false;
    notifyListeners();
    try {
      steps = await _repository.stepsForJourney(journey.id);
    } catch (error) {
      debugPrint('LinkActivityViewModel.selectJourney: $error');
      loadFailed = true;
    }
    loading = false;
    notifyListeners();
  }

  Future<void> selectStep(CcJourneyStepsRow step) async {
    selectedStep = step;
    suggestedOrder = null;
    validationError = null;
    saveFailed = false;
    phase = LinkActivityPhase.form;
    search = '';
    loading = true;
    notifyListeners();
    try {
      suggestedOrder = await _repository.nextOrder(step.id);
      loadFailed = false;
    } catch (error) {
      debugPrint('LinkActivityViewModel.selectStep: $error');
      loadFailed = true;
    }
    loading = false;
    notifyListeners();
  }

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  void back() {
    validationError = null;
    saveFailed = false;
    search = '';
    if (phase == LinkActivityPhase.form) {
      phase = LinkActivityPhase.step;
    } else if (phase == LinkActivityPhase.step) {
      phase = LinkActivityPhase.journey;
      selectedJourney = null;
      steps = [];
    }
    notifyListeners();
  }

  Future<bool> save(PortalActivityInput input) async {
    final selected = selectedStep;
    final error = input.validate();
    validationError = error;
    saveFailed = false;
    if (error != null || selected == null) {
      notifyListeners();
      return false;
    }

    saving = true;
    notifyListeners();
    try {
      await _repository.createActivity(stepId: selected.id, input: input);
      saving = false;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('LinkActivityViewModel.save: $error');
      saving = false;
      saveFailed = true;
      notifyListeners();
      return false;
    }
  }

  PortalActivityDraft _draft({PortalItemMedia? media}) {
    return portalActivityDraftFromContent(
      midiaType: _content.midiaType,
      audioUrl: filledPortalValue(
        listed: _content.audioUrl,
        stored: media?.audioUrl,
      ),
      midiaFileUrl: filledPortalValue(
        listed: _content.midiaFileUrl,
        stored: media?.midiaFileUrl,
      ),
      videoUrl: filledPortalValue(stored: media?.videoUrl),
      text: filledPortalValue(listed: _content.text, stored: media?.text),
      transcript: filledPortalValue(
        listed: _content.transcript,
        stored: media?.transcript,
      ),
      filenameRecorded: filledPortalValue(
        listed: _content.filenameRecorded,
        stored: media?.filenameRecorded,
      ),
      filenameSelected: filledPortalValue(
        listed: _content.filenameSelected,
        stored: media?.filenameSelected,
      ),
      audioDuration: filledPortalValue(
        listed: _content.audioDuration,
        stored: media?.audioDuration,
      ),
    );
  }
}
