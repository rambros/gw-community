import 'package:flutter/material.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_pdf_viewer.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/ui/journey/widgets/journey_locale_scope.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class StepPdfPage extends StatelessWidget {
  const StepPdfPage({
    super.key,
    required this.activityRow,
    this.fixedLanguage,
  });

  final CcViewUserActivitiesRow? activityRow;
  final String? fixedLanguage;

  static String routeName = 'stepPdfPage';
  static String routePath = '/stepPdfPage';

  @override
  Widget build(BuildContext context) {
    final activity = activityRow;
    final prompt = (activity?.activityPrompt ?? '').trim();
    final pdfUrl = (activity?.pdfUrl ?? '').trim();

    return JourneyLocaleScope(
      fixedLanguage: fixedLanguage,
      builder: (context) => Scaffold(
        backgroundColor: AppTheme.of(context).secondary,
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            localizedJourneyActivityLabel(
              context.l10n,
              activity?.activityLabel,
            ),
            style: AppTheme.of(context).journey.pageTitle,
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (prompt.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
                  child: Text(
                    prompt,
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).journey.stepTitle.override(
                          color: AppTheme.of(context).tertiary,
                        ),
                  ),
                ),
              Expanded(
                child: pdfUrl.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.activityPdfUnavailable,
                          textAlign: TextAlign.center,
                          style: AppTheme.of(context)
                              .journey
                              .stepDescription
                              .override(
                                color: AppTheme.of(context).primaryText,
                              ),
                        ),
                      )
                    : FlutterFlowPdfViewer(
                        networkPath: pdfUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
