import '/auth/supabase_auth/auth_util.dart';
import '/components/user_avatar/user_avatar_widget.dart';
import '/data/repositories/notification_repository.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'view_model/add_notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotificationAddPage extends StatefulWidget {
  const NotificationAddPage({
    super.key,
    this.groupId,
    this.groupName,
    String? privacy,
  }) : privacy = privacy ?? 'public';

  final int? groupId;
  final String? groupName;
  final String privacy;

  static String routeName = 'notificationAddPage';
  static String routePath = '/notificationAddPage';

  @override
  State<NotificationAddPage> createState() => _NotificationAddPageState();
}

class _NotificationAddPageState extends State<NotificationAddPage> {
  late AddNotificationViewModel _viewModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'notificationAddPage'});
    _viewModel = AddNotificationViewModel(
      repository: context.read<NotificationRepository>(),
      currentUserUid: currentUserUid,
      groupId: widget.groupId,
      groupName: widget.groupName,
      privacy: widget.privacy,
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
      child: Consumer<AddNotificationViewModel>(
        builder: (context, viewModel, _) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              appBar: AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
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
                  'New Notification',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                          fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
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
                child: viewModel.isLoadingUser && viewModel.currentUser == null
                    ? _buildLoadingIndicator(context)
                    : Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context, viewModel),
                              _buildForm(context, viewModel),
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

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50.0,
        height: 50.0,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            FlutterFlowTheme.of(context).primary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AddNotificationViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
      child: Row(
        children: [
          UserAvatarWidget(
            imageUrl: viewModel.currentUser?.photoUrl,
            fullName: viewModel.currentUser?.fullName,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valueOrDefault<String>(viewModel.currentUser?.displayName, 'name'),
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.normal,
                            fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).secondary,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  if (widget.groupId != null)
                    Text(
                      'From group ${widget.groupName}',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexendDeca(
                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).secondary,
                            letterSpacing: 0.0,
                          ),
                    ),
                  Text(
                    viewModel.canSelectVisibility && viewModel.visibility != 'everyone'
                        ? 'Sharing only for this group'
                        : 'Sharing for everyone',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, AddNotificationViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
          child: TextFormField(
            controller: viewModel.titleController,
            focusNode: viewModel.titleFocusNode,
            decoration: _inputDecoration(context, 'Title'),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(
                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondary,
                  letterSpacing: 0.0,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
          child: TextFormField(
            controller: viewModel.experienceController,
            focusNode: viewModel.experienceFocusNode,
            decoration: _inputDecoration(context, 'Message'),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(
                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondary,
                  letterSpacing: 0.0,
                ),
            maxLines: 14,
          ),
        ),
        if (viewModel.canSelectVisibility)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 16.0, 0.0),
                  child: Text(
                    'Visibility',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                FlutterFlowDropDown<String>(
                  controller: FormFieldController<String>(viewModel.visibility),
                  options: const ['group_only', 'everyone'],
                  optionLabels: const ['Group only', 'Everyone'],
                  onChanged: viewModel.setVisibility,
                  width: 180.0,
                  height: 50.0,
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.lexendDeca(
                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).secondary,
                        letterSpacing: 0.0,
                      ),
                  fillColor: FlutterFlowTheme.of(context).primaryBackground,
                  elevation: 2.0,
                  borderColor: FlutterFlowTheme.of(context).alternate,
                  borderWidth: 1.0,
                  borderRadius: 16.0,
                  margin: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                  hidesUnderline: true,
                ),
              ],
            ),
          ),
        if (viewModel.errorMessage != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
            child: Text(
              viewModel.errorMessage!,
              style: FlutterFlowTheme.of(context).labelMedium.copyWith(
                    color: FlutterFlowTheme.of(context).error,
                  ),
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: FlutterFlowTheme.of(context).labelLarge.override(
            font: GoogleFonts.poppins(
              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
            ),
            color: FlutterFlowTheme.of(context).primary,
            fontSize: 16.0,
            letterSpacing: 0.0,
          ),
      hintStyle: FlutterFlowTheme.of(context).bodySmall.override(
            font: GoogleFonts.lexendDeca(
              fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
            ),
            color: FlutterFlowTheme.of(context).alternate,
            letterSpacing: 0.0,
          ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
    );
  }

  Widget _buildActions(BuildContext context, AddNotificationViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 32.0, 16.0, 16.0),
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
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                color: FlutterFlowTheme.of(context).primaryBackground,
                textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                        fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondary,
                      letterSpacing: 0.0,
                    ),
                elevation: 0.0,
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
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
                          'Notification created with success',
                          style: TextStyle(
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                        backgroundColor: FlutterFlowTheme.of(context).secondary,
                      ),
                    );
                    context.pushNamed(CommunityPage.routeName);
                  },
            text: viewModel.isSaving ? 'Saving...' : 'Add Notification',
            options: FFButtonOptions(
              height: 40.0,
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                      fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    letterSpacing: 0.0,
                  ),
              elevation: 1.0,
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).secondaryBackground,
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
