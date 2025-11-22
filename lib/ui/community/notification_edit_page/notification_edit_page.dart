import '/data/services/supabase/supabase.dart';
import '/data/repositories/notification_repository.dart';
import '/ui/core/ui/flutter_flow_drop_down.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/ui/core/themes/app_theme.dart';
import '/utils/flutter_flow_util.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/ui/core/ui/form_field_controller.dart';
import '/index.dart';
import 'view_model/notification_edit_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotificationEditPage extends StatefulWidget {
  const NotificationEditPage({
    super.key,
    required this.sharingRow,
  });

  final CcViewNotificationsUsersRow? sharingRow;

  static String routeName = 'notificationEditPage';
  static String routePath = '/notificationEditPage';

  @override
  State<NotificationEditPage> createState() =>
      _NotificationEditPageState();
}

class _NotificationEditPageState
    extends State<NotificationEditPage> {
  late NotificationEditViewModel _viewModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'notificationEditPage'});
    _viewModel = NotificationEditViewModel(
      repository: context.read<NotificationRepository>(),
      sharingRow: widget.sharingRow!,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<NotificationEditViewModel>(
        builder: (context, viewModel, _) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: AppTheme.of(context).primaryBackground,
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
                  'Edit Notification',
                  style: AppTheme.of(context).titleLarge.override(
                        font: GoogleFonts.poppins(
                          fontWeight: AppTheme.of(context)
                              .titleLarge
                              .fontWeight,
                          fontStyle:
                              AppTheme.of(context).titleLarge.fontStyle,
                        ),
                        fontSize: 20.0,
                        letterSpacing: 0.0,
                      ),
                ),
                centerTitle: true,
                elevation: 2.0,
              ),
              body: SafeArea(
                top: true,
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, viewModel),
                        _buildForm(context, viewModel),
                        if (viewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 8.0, 8.0, 0.0),
                            child: Text(
                              viewModel.errorMessage!,
                              style: AppTheme.of(context)
                                  .labelMedium
                                  .copyWith(
                                    color: AppTheme.of(context).error,
                                  ),
                            ),
                          ),
                        _buildActions(context, viewModel),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, NotificationEditViewModel viewModel) {
    final sharing = viewModel.sharingRow;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 32.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valueOrDefault<String>(sharing.displayName, 'name'),
                  style: AppTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.normal,
                          fontStyle:
                              AppTheme.of(context).bodyLarge.fontStyle,
                        ),
                        color: AppTheme.of(context).secondary,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                      ),
                ),
                if (sharing.groupName != null && sharing.groupName!.isNotEmpty)
                  Text(
                    'From group ${sharing.groupName}',
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: AppTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: AppTheme.of(context).primary,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                Text(
                  viewModel.visibility == 'everyone'
                      ? 'Sharing for everyone'
                      : 'Sharing only for this group',
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.lexendDeca(
                          fontWeight: AppTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: AppTheme.of(context).primary,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, NotificationEditViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
          child: TextFormField(
            controller: viewModel.titleController,
            focusNode: viewModel.titleFocusNode,
            decoration: _inputDecoration(context, 'Title'),
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(
                    fontWeight:
                        AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        AppTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: AppTheme.of(context).secondary,
                  letterSpacing: 0.0,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
          child: TextFormField(
            controller: viewModel.descriptionController,
            focusNode: viewModel.descriptionFocusNode,
            decoration: _inputDecoration(context, 'Details'),
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(
                    fontWeight:
                        AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        AppTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: AppTheme.of(context).secondary,
                  letterSpacing: 0.0,
                ),
            maxLines: 12,
          ),
        ),
        if (viewModel.canSelectVisibility)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 0.0, 4.0),
            child: Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 16.0, 0.0),
                  child: Text(
                    'Visibility',
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: AppTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: AppTheme.of(context).primary,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                FlutterFlowDropDown<String>(
                  controller: FormFieldController<String>(viewModel.visibility),
                  options: const ['group_only', 'everyone'],
                  optionLabels: const [
                    'Sharing only for this group',
                    'Sharing for everyone'
                  ],
                  onChanged: viewModel.setVisibility,
                  width: 180.0,
                  height: 50.0,
                  textStyle: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.lexendDeca(
                          fontWeight: AppTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: AppTheme.of(context).secondary,
                        letterSpacing: 0.0,
                      ),
                  fillColor: AppTheme.of(context).primaryBackground,
                  elevation: 2.0,
                  borderColor: AppTheme.of(context).alternate,
                  borderWidth: 1.0,
                  borderRadius: 16.0,
                  margin: const EdgeInsetsDirectional.fromSTEB(
                      12.0, 4.0, 12.0, 4.0),
                  hidesUnderline: true,
                ),
              ],
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTheme.of(context).labelLarge.override(
            font: GoogleFonts.poppins(
              fontWeight: AppTheme.of(context).labelLarge.fontWeight,
              fontStyle: AppTheme.of(context).labelLarge.fontStyle,
            ),
            color: AppTheme.of(context).primary,
            fontSize: 16.0,
            letterSpacing: 0.0,
          ),
      hintStyle: AppTheme.of(context).bodySmall.override(
            font: GoogleFonts.lexendDeca(
              fontWeight: AppTheme.of(context).bodySmall.fontWeight,
              fontStyle: AppTheme.of(context).bodySmall.fontStyle,
            ),
            color: AppTheme.of(context).alternate,
            letterSpacing: 0.0,
          ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppTheme.of(context).alternate,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppTheme.of(context).alternate,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
    );
  }

  Widget _buildActions(
      BuildContext context, NotificationEditViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: FFButtonWidget(
              onPressed: () => context.pushNamed(CommunityPage.routeName),
              text: 'Cancel',
              options: FFButtonOptions(
                height: 40.0,
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                color: AppTheme.of(context).primaryBackground,
                textStyle: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            AppTheme.of(context).labelLarge.fontWeight,
                        fontStyle:
                            AppTheme.of(context).labelLarge.fontStyle,
                      ),
                      color: AppTheme.of(context).secondary,
                      letterSpacing: 0.0,
                    ),
                elevation: 0.0,
                borderSide: BorderSide(
                  color: AppTheme.of(context).secondaryBackground,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          FFButtonWidget(
            onPressed: viewModel.isSaving
                ? null
                : () async {
                    final success = await viewModel.saveNotification();
                    if (!success || !context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Notification updated with success',
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                          ),
                        ),
                        backgroundColor: AppTheme.of(context).secondary,
                      ),
                    );
                    context.goNamed(
                      CommunityPage.routeName,
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 0),
                        ),
                      },
                    );
                  },
            text: viewModel.isSaving ? 'Saving...' : 'Save Notification',
            options: FFButtonOptions(
              height: 40.0,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              color: AppTheme.of(context).primary,
              textStyle: AppTheme.of(context).labelLarge.override(
                    font: GoogleFonts.poppins(
                      fontWeight:
                          AppTheme.of(context).labelLarge.fontWeight,
                      fontStyle:
                          AppTheme.of(context).labelLarge.fontStyle,
                    ),
                    color: AppTheme.of(context).primaryBackground,
                    letterSpacing: 0.0,
                  ),
              elevation: 1.0,
              borderSide: BorderSide(
                color: AppTheme.of(context).secondaryBackground,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ],
      ),
    );
  }
}
