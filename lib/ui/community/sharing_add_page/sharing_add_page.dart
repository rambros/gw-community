import '/auth/supabase_auth/auth_util.dart';
import '/components/user_avatar/user_avatar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/ui/community/sharing_add_page/view_model/sharing_add_view_model.dart';
import '/data/repositories/sharing_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Página de adicionar novo Sharing
/// Refatorada para seguir arquitetura MVVM estilo Compass
class SharingAddPage extends StatelessWidget {
  const SharingAddPage({
    super.key,
    this.groupId,
    this.groupName,
    String? privacy,
  }) : privacy = privacy ?? 'public';

  final int? groupId;
  final String? groupName;
  final String privacy;

  static String routeName = 'sharingAddPage';
  static String routePath = '/sharingAddPage';

  @override
  Widget build(BuildContext context) {
    // Provider local para o formulário
    return ChangeNotifierProvider(
      create: (_) => SharingAddViewModel(
        repository: context.read<SharingRepository>(),
        currentUserUid: currentUserUid,
        groupId: groupId,
        groupName: groupName,
        privacy: privacy,
      ),
      child: const _SharingAddPageContent(),
    );
  }
}

class _SharingAddPageContent extends StatelessWidget {
  const _SharingAddPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SharingAddViewModel>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: _buildAppBar(context),
        body: _buildBody(context, viewModel),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
        'New Sharing',
        style: FlutterFlowTheme.of(context).titleLarge.override(
              font: GoogleFonts.poppins(
                fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
              ),
              fontSize: 20.0,
              letterSpacing: 0.0,
              fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
            ),
      ),
      actions: const [],
      centerTitle: true,
      elevation: 2.0,
    );
  }

  Widget _buildBody(BuildContext context, SharingAddViewModel viewModel) {
    // Loading state
    if (viewModel.isLoading) {
      return Center(
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: SpinKitRipple(
            color: FlutterFlowTheme.of(context).primary,
            size: 50.0,
          ),
        ),
      );
    }

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

              // Campo de título
              _buildTitleField(context, viewModel),

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

  Widget _buildHeader(BuildContext context, SharingAddViewModel viewModel) {
    final user = viewModel.currentUser;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          UserAvatarWidget(
            imageUrl: user?.photoUrl,
            fullName: user?.fullName,
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
                    valueOrDefault<String>(user?.displayName, 'name'),
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.normal),
                          color: FlutterFlowTheme.of(context).secondary,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  if (viewModel.groupId != null)
                    Text(
                      'From group ${viewModel.groupName}',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexendDeca(),
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  Text(
                    viewModel.visibilityText,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(),
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

  Widget _buildTitleField(BuildContext context, SharingAddViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
      child: TextFormField(
        controller: viewModel.titleController,
        focusNode: viewModel.titleFocusNode,
        autofocus: false,
        obscureText: false,
        decoration: InputDecoration(
          labelText: 'Title',
          labelStyle: FlutterFlowTheme.of(context).labelLarge.override(
                font: GoogleFonts.poppins(),
                color: FlutterFlowTheme.of(context).primary,
                fontSize: 18.0,
                letterSpacing: 0.0,
              ),
          hintText: '[Some title for your experience...]',
          hintStyle: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.lexendDeca(),
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
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lexendDeca(),
              color: FlutterFlowTheme.of(context).secondary,
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
        maxLines: 2,
        validator: viewModel.validateTitle,
      ),
    );
  }

  Widget _buildTextField(BuildContext context, SharingAddViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 4.0),
      child: TextFormField(
        controller: viewModel.textController,
        focusNode: viewModel.textFocusNode,
        autofocus: false,
        obscureText: false,
        decoration: InputDecoration(
          labelText: 'Experience',
          labelStyle: FlutterFlowTheme.of(context).labelLarge.override(
                font: GoogleFonts.poppins(),
                color: FlutterFlowTheme.of(context).primary,
                fontSize: 18.0,
                letterSpacing: 0.0,
              ),
          hintText: '[your experience...]',
          hintStyle: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.lexendDeca(),
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
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lexendDeca(),
              color: FlutterFlowTheme.of(context).secondary,
              letterSpacing: 0.0,
            ),
        maxLines: 20,
        validator: viewModel.validateText,
      ),
    );
  }

  Widget _buildVisibilityDropdown(BuildContext context, SharingAddViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 0.0, 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 16.0, 0.0),
            child: Text(
              'Visibility',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: FlutterFlowTheme.of(context).primary,
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
            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(),
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
            fillColor: FlutterFlowTheme.of(context).primaryBackground,
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

  Widget _buildErrorMessage(BuildContext context, SharingAddViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        viewModel.errorMessage!,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lexendDeca(),
              color: FlutterFlowTheme.of(context).error,
              letterSpacing: 0.0,
            ),
      ),
    );
  }

  Widget _buildSuccessMessage(BuildContext context, SharingAddViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        viewModel.successMessage!,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lexendDeca(),
              color: FlutterFlowTheme.of(context).success,
              letterSpacing: 0.0,
            ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, SharingAddViewModel viewModel) {
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
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                iconPadding: const EdgeInsets.all(0.0),
                color: FlutterFlowTheme.of(context).primaryBackground,
                textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(),
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
          // Botão Add Sharing
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: FFButtonWidget(
              onPressed: viewModel.isSaving || !viewModel.canSave() ? null : () => viewModel.saveCommand(context),
              text: viewModel.isSaving ? 'Saving...' : 'Add Sharing',
              options: FFButtonOptions(
                height: 40.0,
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(),
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
          ),
        ],
      ),
    );
  }
}
