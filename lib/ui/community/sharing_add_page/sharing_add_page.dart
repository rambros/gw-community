import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/sharing_repository.dart';
import 'package:gw_community/ui/community/sharing_add_page/view_model/sharing_add_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
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
        currentUserUid: context.currentUserIdOrEmpty,
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
        'New Experience',
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

  Widget _buildBody(BuildContext context, SharingAddViewModel viewModel) {
    // Loading state
    if (viewModel.isLoading) {
      return Center(
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: SpinKitRipple(
            color: AppTheme.of(context).primary,
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

              // Campo de texto/experiência
              _buildTextField(context, viewModel),

              // Mensagens de erro/sucesso
              if (viewModel.errorMessage != null) _buildErrorMessage(context, viewModel),
              if (viewModel.successMessage != null) _buildSuccessMessage(context, viewModel),

              // Toggle de comentários
              _buildCommentsToggle(context, viewModel),

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
          UserAvatar(
            imageUrl: user?.photoUrl,
            fullName: user?.displayName,
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
                    style: AppTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.normal),
                          color: AppTheme.of(context).secondary,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  if (viewModel.groupId != null)
                    Text(
                      'From group ${viewModel.groupName}',
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexendDeca(),
                            color: AppTheme.of(context).primary,
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

  Widget _buildTextField(BuildContext context, SharingAddViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 4.0),
      child: TextFormField(
        controller: viewModel.textController,
        focusNode: viewModel.textFocusNode,
        autofocus: true,
        obscureText: false,
        decoration: InputDecoration(
          labelText: 'Share your experience',
          labelStyle: AppTheme.of(context).labelLarge.override(
                font: GoogleFonts.poppins(),
                color: AppTheme.of(context).primary,
                fontSize: 18.0,
                letterSpacing: 0.0,
              ),
          hintText: 'Write about your experience...',
          hintStyle: AppTheme.of(context).bodySmall.override(
                font: GoogleFonts.lexendDeca(),
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
        maxLines: null,
        minLines: 20,
        validator: viewModel.validateText,
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, SharingAddViewModel viewModel) {
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

  Widget _buildSuccessMessage(BuildContext context, SharingAddViewModel viewModel) {
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

  Widget _buildCommentsToggle(BuildContext context, SharingAddViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Enable comments',
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(),
                  color: AppTheme.of(context).secondary,
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
          ),
          Switch(
            value: viewModel.commentsEnabled,
            onChanged: viewModel.toggleComments,
            thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.of(context).primary;
              }
              return Colors.grey;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.of(context).primary.withValues(alpha: 0.5);
              }
              return Colors.grey.withValues(alpha: 0.3);
            }),
          ),
        ],
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
          // Botão Save as Draft
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
                            content: const Text('Reflection saved'),
                            backgroundColor: AppTheme.of(context).success,
                          ),
                        );
                      }
                    },
              text: 'Keep in Reflection',
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
          // Botão Publish
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: FFButtonWidget(
              onPressed: viewModel.isSaving || !viewModel.canSave() ? null : () => viewModel.saveCommand(context),
              text: viewModel.isSaving ? 'Saving...' : 'Publish',
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
