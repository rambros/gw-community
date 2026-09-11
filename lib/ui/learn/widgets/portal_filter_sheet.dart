import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_drop_down.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/ui/form_field_controller.dart';
import 'package:gw_community/ui/learn/widgets/portal_search_bar.dart';

Future<void> showPortalFilterSheet({
  required BuildContext context,
  required String title,
  required Widget Function(BuildContext context, void Function(void Function()) setModalState) buildFields,
  required Future<void> Function() onApply,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            final theme = AppTheme.of(context);
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.alternate,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(title, style: portalSectionTitleStyle(context)),
                    const SizedBox(height: 20),
                    buildFields(context, setModalState),
                    const SizedBox(height: 24),
                    FFButtonWidget(
                      onPressed: () async {
                        await onApply();
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      text: context.l10n.applyFilters,
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 48,
                        color: theme.primary,
                        textStyle: theme.labelLarge.override(color: Colors.white),
                        elevation: 0,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class PortalFilterDropdown<T> extends StatelessWidget {
  const PortalFilterDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.optionLabels,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.multiSelectController,
    this.onMultiSelectChanged,
    this.isSearchable = false,
    this.isMultiSelect = false,
    this.searchHintText,
    this.hasValue = false,
    this.onClear,
  });

  final String label;
  final FormFieldController<T>? controller;
  final FormFieldController<List<T>?>? multiSelectController;
  final List<T> options;
  final List<String> optionLabels;
  final String hintText;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<List<T>?>? onMultiSelectChanged;
  final bool isSearchable;
  final bool isMultiSelect;
  final String? searchHintText;
  final bool hasValue;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.bodySmall.override(
                      color: theme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (hasValue && onClear != null)
                  IconButton(
                    onPressed: onClear,
                    icon: Icon(Icons.close, color: theme.primary, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    tooltip: context.l10n.clearNamedFilter(label),
                  ),
              ],
            ),
          ),
          FlutterFlowDropDown<T>(
            controller: isMultiSelect ? null : controller,
            multiSelectController: isMultiSelect ? multiSelectController : null,
            options: options,
            optionLabels: optionLabels,
            onChanged: isMultiSelect ? null : onChanged,
            onMultiSelectChanged: isMultiSelect ? onMultiSelectChanged : null,
            isMultiSelect: isMultiSelect,
            width: double.infinity,
            height: 50,
            textStyle: theme.bodyMedium.override(
              font: GoogleFonts.lexendDeca(),
              color: theme.secondary,
            ),
            hintText: hintText,
            searchHintText: searchHintText,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.secondaryText,
              size: 24,
            ),
            fillColor: Colors.white,
            elevation: 0,
            borderColor: theme.alternate,
            borderWidth: 1.5,
            borderRadius: 12,
            margin: const EdgeInsetsDirectional.fromSTEB(16, 4, 12, 4),
            hidesUnderline: true,
            isOverButton: false,
            isSearchable: isSearchable,
            maxHeight: 280,
          ),
        ],
      ),
    );
  }
}
