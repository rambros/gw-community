import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/profile/user_journal_edit/user_journal_edit_page.dart';
import 'package:gw_community/ui/profile/user_journal_options/view_model/user_journal_options_view_model.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class UserJournalOptionsSheet extends StatefulWidget {
  const UserJournalOptionsSheet({
    super.key,
    required this.journalEntryRow,
  });

  final CcViewUserJournalRow? journalEntryRow;

  @override
  State<UserJournalOptionsSheet> createState() => _UserJournalOptionsSheetState();
}

class _UserJournalOptionsSheetState extends State<UserJournalOptionsSheet> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserJournalOptionsViewModel>();

    return Container(
      width: double.infinity,
      height: 270.0,
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 5.0,
            color: Color(0x3B1D2429),
            offset: Offset(
              0.0,
              -3.0,
            ),
          )
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FFButtonWidget(
              onPressed: () async {
                Navigator.pop(context);

                context.pushNamed(
                  UserJournalEditPage.routeName,
                  queryParameters: {
                    'userJournalEntryRow': serializeParam(
                      widget.journalEntryRow,
                      ParamType.SupabaseRow,
                    ),
                  }.withoutNulls,
                );
              },
              text: 'Edit ',
              icon: const Icon(
                Icons.edit,
                size: 22.0,
              ),
              options: FFButtonOptions(
                width: double.infinity,
                height: 60.0,
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: AppTheme.of(context).primaryBackground,
                textStyle: AppTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontStyle: AppTheme.of(context).bodyLarge.fontStyle,
                      ),
                      color: AppTheme.of(context).secondary,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: AppTheme.of(context).bodyLarge.fontStyle,
                    ),
                elevation: 2.0,
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
              child: FFButtonWidget(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        var confirmDialogResponse = await showDialog<bool>(
                              context: context,
                              builder: (alertDialogContext) {
                                return WebViewAware(
                                  child: AlertDialog(
                                    title: const Text('Deletion of journal entry'),
                                    content: const Text('Confirm deletion of this entry?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(alertDialogContext, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(alertDialogContext, true),
                                        child: const Text('Confirm'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ) ??
                            false;
                        if (confirmDialogResponse) {
                          if (widget.journalEntryRow?.userActivityId != null) {
                            await viewModel.clearJournalEntry(widget.journalEntryRow!.userActivityId!);
                            if (!context.mounted) return;
                            if (viewModel.errorMessage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Journal saved',
                                    style: TextStyle(
                                      color: AppTheme.of(context).primaryText,
                                    ),
                                  ),
                                  duration: const Duration(milliseconds: 4000),
                                  backgroundColor: AppTheme.of(context).secondary,
                                ),
                              );
                              context.safePop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    viewModel.errorMessage!,
                                    style: TextStyle(
                                      color: AppTheme.of(context).error,
                                    ),
                                  ),
                                  duration: const Duration(milliseconds: 4000),
                                  backgroundColor: AppTheme.of(context).secondary,
                                ),
                              );
                            }
                          }
                        }
                      },
                text: viewModel.isLoading ? 'Clearing...' : 'Clear entry',
                icon: const Icon(
                  Icons.delete,
                  size: 22.0,
                ),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 60.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: AppTheme.of(context).primaryBackground,
                  textStyle: AppTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontStyle: AppTheme.of(context).bodyLarge.fontStyle,
                        ),
                        color: AppTheme.of(context).error,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: AppTheme.of(context).bodyLarge.fontStyle,
                      ),
                  elevation: 2.0,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
              child: FFButtonWidget(
                onPressed: () async {
                  context.pop();
                  Navigator.pop(context);
                },
                text: 'Cancel',
                icon: const Icon(
                  Icons.cancel,
                  size: 22.0,
                ),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 60.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconColor: AppTheme.of(context).secondary,
                  color: AppTheme.of(context).primaryBackground,
                  textStyle: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.lexendDeca(
                          fontWeight: FontWeight.normal,
                          fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                        ),
                        color: AppTheme.of(context).secondary,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.normal,
                        fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                      ),
                  elevation: 0.0,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 0.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
