import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/sharing_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/sharing_edit_page/view_model/sharing_edit_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_drop_down.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/ui/form_field_controller.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

/// Página de edição de Sharing
/// Refatorada para seguir arquitetura MVVM estilo Compass
class SharingEditPage extends StatelessWidget {
  const SharingEditPage({
    super.key,
    required this.sharingRow,
  });

  final CcViewSharingsUsersRow? sharingRow;

  static String routeName = 'sharingEditPage';
  static String routePath = '/sharingEditPage';

  @override
  Widget build(BuildContext context) {
    if (sharingRow == null) {
      return const Scaffold(
        body: Center(
          child: Text('Experience not found'),
        ),
      );
    }

    // Provider local para o formulário
    return ChangeNotifierProvider(
      create: (_) => SharingEditViewModel(
        repository: context.read<SharingRepository>(),
        originalSharing: sharingRow!,
      ),
      child: const _SharingEditPageContent(),
    );
  }
}

class _SharingEditPageContent extends StatelessWidget {
  const _SharingEditPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SharingEditViewModel>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.of(context).primaryBackground,
        appBar: _buildAppBar(context),
        body: _buildBody(context, viewModel),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
        'Edit Experience',
        style: AppTheme.of(context).titleLarge.override(
              font: GoogleFonts.poppins(
                fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                fontStyle: AppTheme.of(context).titleLarge.fontStyle,
              ),
              fontSize: 20.0,
              letterSpacing: 0.0,
              fontWeight: AppTheme.of(context).titleLarge.fontWeight,
              fontStyle: AppTheme.of(context).titleLarge.fontStyle,
            ),
      ),
      actions: const [],
      centerTitle: true,
      elevation: 2.0,
    );
  }

  Widget _buildBody(BuildContext context, SharingEditViewModel viewModel) {
    return SafeArea(
      top: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com avatar e informações do usuário
              _buildHeader(context, viewModel),

              // Campo de texto/experiência
              _buildTextField(context, viewModel),

              // Dropdown de visibilidade (apenas se tiver grupo)
              if (viewModel.hasGroup) _buildVisibilityDropdown(context, viewModel),

              // Mensagens de erro/sucesso
              if (viewModel.errorMessage != null) _buildErrorMessage(context, viewModel),
              if (viewModel.successMessage != null) _buildSuccessMessage(context, viewModel),

              // Botões de ação
              _buildActions(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SharingEditViewModel viewModel) {
    final sharing = viewModel.originalSharing;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Draft indicator badge
          if (viewModel.isDraft)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_note,
                      size: 18,
                      color: Color(0xFF1976D2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Draft - Not published yet',
                      style: GoogleFonts.lexendDeca(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              UserAvatar(
                imageUrl: sharing.photoUrl,
                fullName: sharing.fullName,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        valueOrDefault<String>(sharing.displayName, 'name'),
                        style: AppTheme.of(context).bodyLarge.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.normal),
                              color: AppTheme.of(context).secondary,
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      if (sharing.groupName != null && sharing.groupName != '')
                        Text(
                          'From group ${sharing.groupName}',
                          style: AppTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.lexendDeca(),
                                color: AppTheme.of(context).primary,
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      _buildVisibilityText(context, viewModel),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityText(BuildContext context, SharingEditViewModel viewModel) {
    final isEveryone = viewModel.visibility == 'everyone';
    final hasGroup = viewModel.hasGroup;

    if (!hasGroup && !isEveryone) {
      return const SizedBox.shrink();
    }

    return Text(
      isEveryone ? 'Visible to everyone' : 'Visible only for this group',
      style: AppTheme.of(context).bodyMedium.override(
            font: GoogleFonts.lexendDeca(),
            color: AppTheme.of(context).primary,
            fontSize: 12.0,
            letterSpacing: 0.0,
          ),
    );
  }

  Widget _buildTextField(BuildContext context, SharingEditViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
      child: TextFormField(
        controller: viewModel.textController,
        focusNode: viewModel.textFocusNode,
        autofocus: false,
        obscureText: false,
        decoration: InputDecoration(
          labelText: 'Experience',
          labelStyle: AppTheme.of(context).labelLarge.override(
                font: GoogleFonts.poppins(),
                color: AppTheme.of(context).primary,
                fontSize: 18.0,
                letterSpacing: 0.0,
              ),
          hintText: '[your experience...]',
          hintStyle: AppTheme.of(context).bodySmall.override(
                font: GoogleFonts.lexendDeca(),
                color: AppTheme.of(context).secondary,
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
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
            borderRadius: BorderRadius.circular(16.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
            borderRadius: BorderRadius.circular(16.0),
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
        ),
        style: AppTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lexendDeca(),
              color: AppTheme.of(context).secondary,
              letterSpacing: 0.0,
            ),
        maxLines: 20,
        validator: viewModel.validateText,
      ),
    );
  }

  Widget _buildVisibilityDropdown(BuildContext context, SharingEditViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 0.0, 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 16.0, 0.0),
            child: Text(
              'Visibility',
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).primary,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          FlutterFlowDropDown<String>(
            controller: FormFieldController<String>(viewModel.visibility),
            options: List<String>.from(['everyone', 'group_only']),
            optionLabels: const ['Everyone', 'Only this group'],
            onChanged: viewModel.setVisibility,
            width: 180.0,
            height: 50.0,
            textStyle: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(),
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
            fillColor: AppTheme.of(context).primaryBackground,
            elevation: 2.0,
            borderColor: Colors.transparent,
            borderWidth: 0.0,
            borderRadius: 0.0,
            margin: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
            hidesUnderline: true,
            isSearchable: false,
            isMultiSelect: false,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, SharingEditViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        viewModel.errorMessage!,
        style: AppTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lexendDeca(),
              color: AppTheme.of(context).error,
              letterSpacing: 0.0,
            ),
      ),
    );
  }

  Widget _buildSuccessMessage(BuildContext context, SharingEditViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        viewModel.successMessage!,
        style: AppTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lexendDeca(),
              color: AppTheme.of(context).success,
              letterSpacing: 0.0,
            ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, SharingEditViewModel viewModel) {
    // Texto do botão principal depende do status atual
    final publishButtonText = viewModel.isDraft ? 'Publish' : 'Save';


    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botão Cancel
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: FFButtonWidget(
              onPressed: viewModel.isSaving ? null : () => viewModel.cancelCommand(context),
              text: 'Cancel',
              options: FFButtonOptions(
                height: 40.0,
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding: const EdgeInsets.all(0.0),
                color: AppTheme.of(context).primaryBackground,
                textStyle: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(),
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
          // Botão Save Draft
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: FFButtonWidget(
              onPressed: viewModel.isSaving || !viewModel.canSave()
                  ? null
                  : () async {
                      final success = await viewModel.saveDraftCommand(context);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Draft saved'),
                            backgroundColor: AppTheme.of(context).success,
                          ),
                        );
                      }
                    },
              text: 'Save Draft',
              options: FFButtonOptions(
                height: 40.0,
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding: const EdgeInsets.all(0.0),
                color: AppTheme.of(context).primaryBackground,
                textStyle: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(),
                      color: AppTheme.of(context).primary,
                      letterSpacing: 0.0,
                    ),
                elevation: 0.0,
                borderSide: BorderSide(
                  color: AppTheme.of(context).primary,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          // Botão Save/Publish
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: FFButtonWidget(
              onPressed: viewModel.isSaving || !viewModel.canSave() ? null : () => viewModel.saveCommand(context),
              text: viewModel.isSaving ? 'Saving...' : publishButtonText,
              options: FFButtonOptions(
                height: 40.0,
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: AppTheme.of(context).primary,
                textStyle: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(),
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
          ),
        ],
      ),
    );
  }
}
