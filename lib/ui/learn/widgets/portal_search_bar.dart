import 'package:flutter/material.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';

class PortalSearchBar extends StatelessWidget {
  const PortalSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
    required this.onFilter,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onFilter;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                autofocus: autofocus,
                onFieldSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                style: theme.bodyMedium.override(color: theme.secondary),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: theme.bodyMedium.override(color: theme.secondaryText),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search_rounded, color: theme.primary),
                    onPressed: () => onSubmitted(controller.text),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 8.0, 0.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.alternate, width: 1.5),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              context.l10n.orSeparator,
              style: theme.bodyMedium.override(
                color: theme.primary,
                fontSize: 16.0,
              ),
            ),
          ),
          FFButtonWidget(
            onPressed: onFilter,
            text: context.l10n.filter,
            icon: const Icon(Icons.filter_alt, size: 15.0),
            options: FFButtonOptions(
              height: 44.0,
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              color: theme.primary,
              textStyle: theme.labelLarge.override(color: Colors.white),
              elevation: 1.0,
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle portalSectionTitleStyle(BuildContext context) {
  return AppTheme.of(context).titleSmall.override(
        color: AppTheme.of(context).secondary,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      );
}

BoxDecoration portalCardDecoration(BuildContext context, {Color? color}) {
  return BoxDecoration(
    color: color ?? AppTheme.of(context).primaryBackground,
    boxShadow: const [
      BoxShadow(
        blurRadius: 15.0,
        color: Color(0x26000000),
        offset: Offset(0.0, 7.0),
        spreadRadius: 3.0,
      ),
    ],
    borderRadius: BorderRadius.circular(12.0),
    border: Border.all(
      color: const Color(0xFFF5FBFB),
    ),
  );
}
