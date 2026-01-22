import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

import 'package:gw_community/ui/community/announcement_edit_page/view_model/announcement_edit_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';

import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:provider/provider.dart';

class AnnouncementEditPage extends StatefulWidget {
  const AnnouncementEditPage({
    super.key,
    required this.experienceRow,
  });

  final CcViewNotificationsUsersRow? experienceRow;

  static String routeName = 'announcementEditPage';
  static String routePath = '/announcementEditPage';

  @override
  State<AnnouncementEditPage> createState() => _AnnouncementEditPageState();
}

class _AnnouncementEditPageState extends State<AnnouncementEditPage> {
  late AnnouncementEditViewModel _viewModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'announcementEditPage'});
    _viewModel = AnnouncementEditViewModel(
      repository: context.read<AnnouncementRepository>(),
      experienceRow: widget.experienceRow!,
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
      child: Consumer<AnnouncementEditViewModel>(
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
                  'Edit Announcement',
                  style: AppTheme.of(context).titleLarge.override(
                        font: GoogleFonts.poppins(
                          fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                          fontStyle: AppTheme.of(context).titleLarge.fontStyle,
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
                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, viewModel),
                        _buildForm(context, viewModel),
                        if (viewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
                            child: Text(
                              viewModel.errorMessage!,
                              style: AppTheme.of(context).labelMedium.copyWith(
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

  Widget _buildHeader(BuildContext context, AnnouncementEditViewModel viewModel) {
    final experience = viewModel.experienceRow;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 32.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valueOrDefault<String>(experience.displayName, 'name'),
                  style: AppTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.normal,
                          fontStyle: AppTheme.of(context).bodyLarge.fontStyle,
                        ),
                        color: AppTheme.of(context).secondary,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                      ),
                ),
                if (experience.groupName != null && experience.groupName!.isNotEmpty)
                  Text(
                    'From group ${experience.groupName}',
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
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

  Widget _buildForm(BuildContext context, AnnouncementEditViewModel viewModel) {
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
                    fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
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
                    fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: AppTheme.of(context).secondary,
                  letterSpacing: 0.0,
                ),
            maxLines: 12,
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

  Widget _buildActions(BuildContext context, AnnouncementEditViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: FFButtonWidget(
              onPressed: () => context.pop(),
              text: 'Cancel',
              options: FFButtonOptions(
                height: 40.0,
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                color: AppTheme.of(context).primaryBackground,
                textStyle: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(
                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
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
                    final success = await viewModel.saveAnnouncement();
                    if (!success || !context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Announcement updated with success',
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                          ),
                        ),
                        backgroundColor: AppTheme.of(context).secondary,
                      ),
                    );
                    // Retorna true para indicar que o anúncio foi editado
                    // A AnnouncementViewPage vai receber esse valor e também fazer pop
                    if (context.mounted) {
                      context.pop(true);
                    }
                  },
            text: viewModel.isSaving ? 'Saving...' : 'Save Announcement',
            options: FFButtonOptions(
              height: 40.0,
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              color: AppTheme.of(context).primary,
              textStyle: AppTheme.of(context).labelLarge.override(
                    font: GoogleFonts.poppins(
                      fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                      fontStyle: AppTheme.of(context).labelLarge.fontStyle,
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
