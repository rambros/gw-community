import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/models/journey_step_group.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class JourneyIntroWidget extends StatefulWidget {
  const JourneyIntroWidget({
    super.key,
    required this.journey,
    required this.groupedSteps,
    required this.onStart,
    this.isJourneyStarted = false,
    this.showStartButton = true,
  });

  final CcJourneysRow journey;
  final List<JourneyStepGroup<CcJourneyStepsRow>> groupedSteps;
  final VoidCallback onStart;
  final bool isJourneyStarted;
  final bool showStartButton;

  @override
  State<JourneyIntroWidget> createState() => _JourneyIntroWidgetState();
}

class _JourneyIntroWidgetState extends State<JourneyIntroWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      scrollDirection: Axis.vertical,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.journey.title ?? 'Journey Title',
                style: AppTheme.of(context).journey.sectionTitle.override(
                      color: AppTheme.of(context).tertiary,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
          child: MarkdownBody(
            data: widget.journey.description ?? 'Description',
            onTapLink: (text, href, title) {
              if (href != null) {
                launchURL(href);
              }
            },
            styleSheet: MarkdownStyleSheet(
              p: GoogleFonts.lexendDeca(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14.0,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
              strong: GoogleFonts.lexendDeca(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              em: GoogleFonts.lexendDeca(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14.0,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              h1: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).tertiary,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              h2: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).tertiary,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              h3: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).tertiary,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
              a: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).primary,
                fontSize: 14.0,
                decoration: TextDecoration.underline,
              ),
              listBullet: GoogleFonts.lexendDeca(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14.0,
              ),
            ),
          ),
        ),
        // Steps Section
        if (widget.groupedSteps.any((group) => group.steps.isNotEmpty))
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                  child: Text(
                        context.l10n.journeyContents,
                    style: AppTheme.of(context).journey.sectionTitle.override(
                          color: AppTheme.of(context).tertiary,
                          fontSize: 18.0,
                        ),
                  ),
                ),
                ..._buildGroupedSteps(context),
              ],
            ),
          ),
        // Start Button - placed after Steps section
        if (widget.showStartButton)
          Padding(
            padding: const EdgeInsets.all(32.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: widget.onStart,
                    text: widget.isJourneyStarted
                        ? context.l10n.resume
                        : context.l10n.start,
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: AppTheme.of(context).primary,
                      textStyle: AppTheme.of(context).journey.buttonText.override(
                            color: AppTheme.of(context).primaryBackground,
                          ),
                      elevation: 1.0,
                      borderSide: BorderSide(
                        color: AppTheme.of(context).secondary,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedSteps(BuildContext context) {
    return [
      for (var groupIndex = 0; groupIndex < widget.groupedSteps.length; groupIndex++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: widget.groupedSteps[groupIndex].hasHeader
              ? _buildSectionCard(
                  context,
                  title: widget.groupedSteps[groupIndex].title!,
                  steps: widget.groupedSteps[groupIndex].steps,
                  firstNumber: firstNumberOfGroup(widget.groupedSteps, groupIndex),
                  initiallyExpanded: groupIndex == 0,
                )
              : _sectionContainer(
                  context,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _buildFlatStepList(
                      context,
                      widget.groupedSteps[groupIndex].steps,
                      firstNumberOfGroup(widget.groupedSteps, groupIndex),
                    ),
                  ),
                ),
        ),
    ];
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<CcJourneyStepsRow> steps,
    required int firstNumber,
    required bool initiallyExpanded,
    bool collapsible = true,
  }) {
    final theme = AppTheme.of(context);
    final stepCountLabel = context.l10n.stepsCount(steps.length);

    final content = steps.isEmpty
        ? const SizedBox.shrink()
        : _buildFlatStepList(context, steps, firstNumber);

    if (!collapsible) {
      return _sectionContainer(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, title: title, stepCountLabel: stepCountLabel),
            const SizedBox(height: 8.0),
            content,
          ],
        ),
      );
    }

    return _sectionContainer(
      context,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            childrenPadding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
            title: _buildSectionHeader(
              context,
              title: title,
              stepCountLabel: stepCountLabel,
              compact: true,
            ),
            iconColor: theme.tertiary,
            collapsedIconColor: theme.tertiary,
            children: [content],
          ),
        ),
      ),
    );
  }

  Widget _sectionContainer(BuildContext context, {required Widget child}) {
    final theme = AppTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.45),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: child,
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String stepCountLabel,
    bool compact = false,
  }) {
    final theme = AppTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTheme.of(context).journey.bodyText.override(
                  color: theme.tertiary,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 16.0 : 17.0,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999.0),
          ),
          child: Text(
            stepCountLabel,
            style: AppTheme.of(context).journey.captionSmall.override(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlatStepList(
    BuildContext context,
    List<CcJourneyStepsRow> steps,
    int firstNumber,
  ) {
    final theme = AppTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8.0),
        border: Border(
          left: BorderSide(
            color: theme.primary,
            width: 3.0,
          ),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: steps.length,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(
            height: 1.0,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        itemBuilder: (context, index) {
          final step = steps[index];
          final stepTitle = step.title?.trim() ?? 'Step ${firstNumber + index}';
          final stepDescription = step.description?.trim();
          final showDescription = stepDescription != null &&
              stepDescription.isNotEmpty &&
              stepDescription.toLowerCase() != stepTitle.toLowerCase();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28.0,
                height: 28.0,
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.primary,
                    width: 2.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${firstNumber + index}',
                    style: AppTheme.of(context).journey.stepNumber.override(
                          color: theme.secondary,
                          fontSize: 13.0,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stepTitle,
                      style: AppTheme.of(context).journey.stepTitle.override(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (showDescription)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                        child: Text(
                          stepDescription,
                          style: AppTheme.of(context).journey.stepDescription.override(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 13.0,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
