import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/portal_activity_link.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/learn/link_activity_page/view_model/link_activity_view_model.dart';
import 'package:provider/provider.dart';

Future<void> openLinkActivityPage(
  BuildContext context,
  ViewContentRow content,
) {
  final appState = Provider.of<FFAppState>(context, listen: false);
  if (!appState.loginUser.roles.hasAdminOrGroupManager) return Future.value();
  final userId = SupaFlow.client.auth.currentUser?.id ?? '';
  if (userId.isEmpty || content.contentId == null) return Future.value();

  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => LinkActivityPage(
        content: content,
        isAdmin: appState.loginUser.roles.hasAdmin,
        userId: userId,
      ),
    ),
  );
}

class LinkActivityPage extends StatelessWidget {
  const LinkActivityPage({
    super.key,
    required this.content,
    required this.isAdmin,
    required this.userId,
  });

  final ViewContentRow content;
  final bool isAdmin;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LinkActivityViewModel(
        content: content,
        isAdmin: isAdmin,
        userId: userId,
      )..load(),
      child: const _LinkActivityView(),
    );
  }
}

class _LinkActivityView extends StatefulWidget {
  const _LinkActivityView();

  @override
  State<_LinkActivityView> createState() => _LinkActivityViewState();
}

class _LinkActivityViewState extends State<_LinkActivityView> {
  final _label = ValueNotifier<String?>(null);
  final _search = TextEditingController();
  final _customLabel = TextEditingController();
  final _prompt = TextEditingController();
  final _order = TextEditingController();
  final _audioUrl = TextEditingController();
  final _audioFilename = TextEditingController();
  final _audioDuration = TextEditingController();
  final _transcript = TextEditingController();
  final _videoUrl = TextEditingController();
  final _pdfUrl = TextEditingController();
  var _required = true;
  var _formReady = false;
  int? _orderStepId;

  @override
  void dispose() {
    _label.dispose();
    _search.dispose();
    _customLabel.dispose();
    _prompt.dispose();
    _order.dispose();
    _audioUrl.dispose();
    _audioFilename.dispose();
    _audioDuration.dispose();
    _transcript.dispose();
    _videoUrl.dispose();
    _pdfUrl.dispose();
    super.dispose();
  }

  void _prepareForm(LinkActivityViewModel viewModel) {
    final draft = viewModel.draft;
    if (_formReady || draft == null) return;
    _prompt.text = viewModel.contentTitle;
    _audioUrl.text = draft.audioUrl ?? '';
    _audioFilename.text = draft.audioFilename ?? '';
    _audioDuration.text = draft.audioDuration ?? '';
    _transcript.text = draft.transcript ?? '';
    _videoUrl.text = draft.videoUrl ?? '';
    _pdfUrl.text = draft.pdfUrl ?? '';
    _formReady = true;
  }

  void _applyOrder(LinkActivityViewModel viewModel) {
    final stepId = viewModel.selectedStep?.id;
    final order = viewModel.suggestedOrder;
    if (stepId == null || order == null || _orderStepId == stepId) return;
    _order.text = '$order';
    _orderStepId = stepId;
  }

  Future<void> _save(LinkActivityViewModel viewModel) async {
    final draft = viewModel.draft;
    if (draft == null) return;
    final label = resolvePortalActivityLabel(
          dropdownValue: _label.value,
          customText: _customLabel.text,
        ) ??
        '';
    final saved = await viewModel.save(
      PortalActivityInput(
        label: label,
        prompt: _prompt.text,
        activityType: draft.activityType,
        isRequired: _required,
        orderInStep: int.tryParse(_order.text.trim()),
        audioUrl: _audioUrl.text,
        audioFilename: _audioFilename.text,
        audioDuration: _audioDuration.text,
        transcript: _transcript.text,
        videoUrl: _videoUrl.text,
        pdfUrl: _pdfUrl.text,
        text: draft.text,
      ),
    );
    if (!saved || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.activityLinkedToStep)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final viewModel = context.watch<LinkActivityViewModel>();
    _prepareForm(viewModel);
    _applyOrder(viewModel);

    return PopScope(
      canPop: viewModel.phase == LinkActivityPhase.journey,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _search.clear();
          viewModel.back();
        }
      },
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          title: Text(
            context.l10n.linkToJourneys,
            style: theme.headlineMedium.override(color: Colors.white, fontSize: 18),
          ),
          centerTitle: true,
            leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (viewModel.phase == LinkActivityPhase.journey) {
                Navigator.of(context).pop();
              } else {
                _search.clear();
                viewModel.back();
              }
            },
          ),
        ),
        body: viewModel.loading
            ? Center(child: CircularProgressIndicator(color: theme.primary))
            : switch (viewModel.phase) {
                LinkActivityPhase.journey => _Picker(
                    title: context.l10n.selectJourney,
                    subtitle: viewModel.contentTitle,
                    searchHint: context.l10n.searchJourneys,
                    search: _search,
                    onSearch: viewModel.setSearch,
                    empty: viewModel.loadFailed
                        ? context.l10n.couldNotLoadLinkActivity
                        : viewModel.journeys.isEmpty
                            ? (viewModel.isAdmin
                                ? context.l10n.noJourneysAvailable
                                : context.l10n.noJourneysToLink)
                            : context.l10n.noJourneysMatch(viewModel.search.trim()),
                    itemCount: viewModel.visibleJourneys.length,
                    itemBuilder: (index) {
                      final journey = viewModel.visibleJourneys[index];
                      return _ChoiceTile(
                        title: journey.title ?? '',
                        onTap: () {
                          _search.clear();
                          viewModel.selectJourney(journey);
                        },
                      );
                    },
                  ),
                LinkActivityPhase.step => _Picker(
                    title: context.l10n.selectStep,
                    subtitle: viewModel.selectedJourney?.title ?? '',
                    searchHint: context.l10n.searchSteps,
                    search: _search,
                    onSearch: viewModel.setSearch,
                    empty: viewModel.loadFailed
                        ? context.l10n.couldNotLoadLinkActivity
                        : viewModel.steps.isEmpty
                            ? context.l10n.noStepsInJourney
                            : context.l10n.noStepsMatch(viewModel.search.trim()),
                    itemCount: viewModel.visibleSteps.length,
                    itemBuilder: (index) {
                      final step = viewModel.visibleSteps[index];
                      return _ChoiceTile(
                        title: step.title ?? '',
                        leading: context.l10n.stepNumberLabel(step.stepNumber),
                        onTap: () {
                          _search.clear();
                          viewModel.selectStep(step);
                        },
                      );
                    },
                  ),
                LinkActivityPhase.form => _Form(
                    viewModel: viewModel,
                    label: _label,
                    customLabel: _customLabel,
                    prompt: _prompt,
                    order: _order,
                    audioUrl: _audioUrl,
                    audioFilename: _audioFilename,
                    audioDuration: _audioDuration,
                    transcript: _transcript,
                    videoUrl: _videoUrl,
                    pdfUrl: _pdfUrl,
                    requiredActivity: _required,
                    onRequiredChanged: (value) => setState(() => _required = value),
                    onSave: () => _save(viewModel),
                  ),
              },
      ),
    );
  }
}

class _Picker extends StatelessWidget {
  const _Picker({
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.search,
    required this.onSearch,
    required this.empty,
    required this.itemCount,
    required this.itemBuilder,
  });

  final String title;
  final String subtitle;
  final String searchHint;
  final TextEditingController search;
  final ValueChanged<String> onSearch;
  final String empty;
  final int itemCount;
  final Widget Function(int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lexendDeca(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 13,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: search,
            decoration: InputDecoration(
              hintText: searchHint,
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: onSearch,
          ),
        ),
        Expanded(
          child: itemCount == 0
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    empty,
                    style: GoogleFonts.lexendDeca(color: theme.secondaryText),
                  ),
                )
              : ListView.separated(
                  itemCount: itemCount,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) => itemBuilder(index),
                ),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.onTap,
    this.leading,
  });

  final String title;
  final String? leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: GoogleFonts.lexendDeca(fontSize: 15)),
      subtitle: leading == null
          ? null
          : Text(leading!, style: GoogleFonts.lexendDeca(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.viewModel,
    required this.label,
    required this.customLabel,
    required this.prompt,
    required this.order,
    required this.audioUrl,
    required this.audioFilename,
    required this.audioDuration,
    required this.transcript,
    required this.videoUrl,
    required this.pdfUrl,
    required this.requiredActivity,
    required this.onRequiredChanged,
    required this.onSave,
  });

  final LinkActivityViewModel viewModel;
  final ValueNotifier<String?> label;
  final TextEditingController customLabel;
  final TextEditingController prompt;
  final TextEditingController order;
  final TextEditingController audioUrl;
  final TextEditingController audioFilename;
  final TextEditingController audioDuration;
  final TextEditingController transcript;
  final TextEditingController videoUrl;
  final TextEditingController pdfUrl;
  final bool requiredActivity;
  final ValueChanged<bool> onRequiredChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = context.l10n;
    final type = viewModel.draft?.activityType ?? '';
    final error = _validationText(l10n, type, viewModel.validationError);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          viewModel.selectedStep?.title ?? '',
          style: GoogleFonts.lexendDeca(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          viewModel.contentTitle,
          style: GoogleFonts.lexendDeca(fontSize: 13, color: theme.secondaryText),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<String?>(
          valueListenable: label,
          builder: (context, value, _) {
            return Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: value,
                  decoration: InputDecoration(labelText: l10n.activityLabel),
                  items: [
                    for (final preset in portalActivityLabelPresets)
                      DropdownMenuItem(value: preset, child: Text(preset)),
                    DropdownMenuItem(
                      value: portalActivityCustomLabel,
                      child: Text(l10n.customActivityLabel),
                    ),
                  ],
                  onChanged: (next) => label.value = next,
                ),
                if (value == portalActivityCustomLabel) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: customLabel,
                    maxLength: portalActivityLabelMaxLength,
                    decoration: InputDecoration(labelText: l10n.activityLabelCustom),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: InputDecoration(labelText: l10n.activityTypeLabel),
          child: Text(_typeLabel(l10n, type)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: prompt,
          maxLength: portalActivityPromptMaxLength,
          decoration: InputDecoration(labelText: l10n.activityPromptLabel),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: order,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: l10n.activityOrder),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: requiredActivity,
          onChanged: onRequiredChanged,
          title: Text(l10n.required),
          subtitle: Text(
            requiredActivity ? l10n.activityRequiredHelp : l10n.activityOptionalHelp,
          ),
        ),
        ..._mediaFields(context, l10n, type),
        if (viewModel.loadFailed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.couldNotLoadLinkActivity),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(error, style: TextStyle(color: theme.error)),
          ),
        if (viewModel.saveFailed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.failedToLinkActivity, style: TextStyle(color: theme.error)),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: viewModel.saving ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: viewModel.saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(l10n.addActivity),
        ),
      ],
    );
  }

  List<Widget> _mediaFields(
    BuildContext context,
    AppLocalizations l10n,
    String type,
  ) {
    switch (type) {
      case 'audio':
        return [
          TextField(
            controller: audioUrl,
            decoration: InputDecoration(labelText: l10n.activityAudioUrl),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: audioFilename,
            decoration: InputDecoration(labelText: l10n.activityAudioFilename),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: audioDuration,
            decoration: InputDecoration(labelText: l10n.activityAudioDuration),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: transcript,
            minLines: 3,
            maxLines: 8,
            decoration: InputDecoration(labelText: l10n.transcript),
          ),
        ];
      case 'video':
        return [
          TextField(
            controller: videoUrl,
            decoration: InputDecoration(labelText: l10n.activityVideoUrl),
          ),
        ];
      case 'pdf':
        return [
          TextField(
            controller: pdfUrl,
            decoration: InputDecoration(labelText: l10n.activityPdfUrl),
          ),
        ];
      case 'text':
        final copied = (viewModel.draft?.text ?? '').trim().isNotEmpty;
        final theme = AppTheme.of(context);
        return [
          Text(
            copied
                ? l10n.activityLibraryTextCopied
                : l10n.activityLibraryTextMissing,
            style: GoogleFonts.lexendDeca(
              fontSize: 13,
              color: copied ? theme.secondaryText : theme.error,
            ),
          ),
        ];
      default:
        return const [];
    }
  }

  String _typeLabel(AppLocalizations l10n, String type) {
    return switch (type) {
      'audio' => l10n.activityTypeAudio,
      'video' => l10n.activityTypeVideo,
      'pdf' => l10n.activityTypePdf,
      'text' => l10n.activityTypeText,
      _ => type,
    };
  }

  String? _validationText(
    AppLocalizations l10n,
    String type,
    PortalActivityValidation? error,
  ) {
    return switch (error) {
      null => null,
      PortalActivityValidation.labelRequired => l10n.activityLabelRequired,
      PortalActivityValidation.labelTooLong => l10n.activityLabelTooLong,
      PortalActivityValidation.promptRequired => l10n.activityPromptRequired,
      PortalActivityValidation.promptTooLong => l10n.activityPromptTooLong,
      PortalActivityValidation.mediaMissing =>
        type == 'text' ? null : l10n.activityMediaMissing,
      PortalActivityValidation.orderInvalid => l10n.activityOrderInvalid,
    };
  }
}
