import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/domain/community/event_recurrence.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_drop_down.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/ui/form_field_controller.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class EventRecurrenceFields extends StatelessWidget {
  const EventRecurrenceFields({
    super.key,
    required this.recurrence,
    required this.until,
    required this.onRecurrenceChanged,
    required this.onUntilChanged,
  });

  final String recurrence;
  final DateTime? until;
  final ValueChanged<String?> onRecurrenceChanged;
  final ValueChanged<DateTime?> onUntilChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repeats = EventRecurrence.repeats(recurrence);
    final untilText = until == null
        ? ''
        : dateTimeFormat(
            'd/M/y',
            until,
            locale: FFLocalizations.of(context).languageCode,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
          child: FlutterFlowDropDown<String>(
            controller: FormFieldController<String>(recurrence),
            options: const [
              EventRecurrence.none,
              EventRecurrence.weekly,
              EventRecurrence.biweekly,
              EventRecurrence.monthly,
            ],
            optionLabels: [
              l10n.doesNotRepeat,
              l10n.repeatsWeekly,
              l10n.repeatsEveryTwoWeeks,
              l10n.repeatsMonthly,
            ],
            onChanged: onRecurrenceChanged,
            textStyle: AppTheme.of(context).bodyMedium,
            hintText: l10n.repeats,
            fillColor: AppTheme.of(context).primaryBackground,
            elevation: 2.0,
            borderColor: AppTheme.of(context).alternate,
            borderWidth: 1.0,
            borderRadius: 16.0,
            margin: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
          ),
        ),
        if (repeats) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 4.0),
            child: Text(
              l10n.recurrenceShowsNext,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.poppins(),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
            child: Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.repeatUntilOptional,
                      labelStyle: AppTheme.of(context).labelLarge.override(
                            font: GoogleFonts.poppins(),
                            color: AppTheme.of(context).primary,
                          ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.of(context).alternate),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: Text(
                      untilText.isEmpty ? '—' : untilText,
                      style: AppTheme.of(context).bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                FFButtonWidget(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: until ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2050),
                    );
                    if (picked != null) {
                      onUntilChanged(DateTime(picked.year, picked.month, picked.day));
                    }
                  },
                  text: l10n.selectDate,
                  options: FFButtonOptions(
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    color: AppTheme.of(context).primary,
                    textStyle: AppTheme.of(context).labelMedium.override(
                          font: GoogleFonts.poppins(),
                          color: AppTheme.of(context).primaryBackground,
                        ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ],
            ),
          ),
          if (until != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => onUntilChanged(null),
                child: Text(l10n.clearDate),
              ),
            ),
        ],
      ],
    );
  }
}
