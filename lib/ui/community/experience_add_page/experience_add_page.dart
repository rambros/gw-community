import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/community_repository.dart';
import 'package:gw_community/data/repositories/experience_repository.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/experience_add_page/view_model/experience_add_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:gw_community/ui/journey/widgets/journey_locale_scope.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

/// Página de adicionar novo Experience
/// Refatorada para seguir arquitetura MVVM estilo Compass
class ExperienceAddPage extends StatelessWidget {
  const ExperienceAddPage({
    super.key,
    this.groupId,
    this.groupName,
    String? privacy,
    this.chooseGroups = false,
    this.fixedLanguage,
  }) : privacy = privacy ?? 'public';

  final int? groupId;
  final String? groupName;
  final String privacy;
  final bool chooseGroups;
  final String? fixedLanguage;

  static String routeName = 'experienceAddPage';
  static String routePath = '/experienceAddPage';

  @override
  Widget build(BuildContext context) {
    return JourneyLocaleScope(
      fixedLanguage: fixedLanguage,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => ExperienceAddViewModel(
            repository: context.read<ExperienceRepository>(),
            communityRepository: context.read<CommunityRepository>(),
            currentUserUid: context.currentUserIdOrEmpty,
            groupId: groupId,
            groupName: groupName,
            privacy: privacy,
            chooseGroups: chooseGroups,
            fixedLanguage: fixedLanguage,
          ),
          child: const _ExperienceAddPageContent(),
        );
      },
    );
  }
}

class _ExperienceAddPageContent extends StatelessWidget {
  const _ExperienceAddPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExperienceAddViewModel>();

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
        context.l10n.newExperience,
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

  Widget _buildBody(BuildContext context, ExperienceAddViewModel viewModel) {
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

              if (viewModel.chooseGroups) _buildGroupSelector(context, viewModel),

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

  Widget _buildHeader(BuildContext context, ExperienceAddViewModel viewModel) {
    final loginUser = FFAppState().loginUser;
    final displayName = loginUser.displayName.isNotEmpty
        ? loginUser.displayName
        : loginUser.firstName.isNotEmpty
            ? loginUser.firstName
            : viewModel.currentUser?.displayName;
    final photoUrl = loginUser.photoUrl.isNotEmpty
        ? loginUser.photoUrl
        : viewModel.currentUser?.photoUrl;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          UserAvatar(
            imageUrl: photoUrl,
            fullName: displayName,
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
                    valueOrDefault<String>(displayName, ''),
                    style: AppTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.normal),
                          color: AppTheme.of(context).secondary,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  if (viewModel.groupId != null)
                    Text(
                      context.l10n.fromGroup(viewModel.groupName ?? ''),
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

  Widget _buildGroupSelector(BuildContext context, ExperienceAddViewModel viewModel) {
    final label = _selectedGroupsLabel(context, viewModel);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.shareInGroups,
            style: AppTheme.of(context).labelLarge.override(
                  font: GoogleFonts.poppins(),
                  color: AppTheme.of(context).primary,
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 8.0),
          InkWell(
            onTap: viewModel.availableGroups.isEmpty
                ? null
                : () => _openGroupPicker(context, viewModel),
            borderRadius: BorderRadius.circular(16.0),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: context.l10n.chooseGroups,
                hintStyle: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.lexendDeca(),
                      color: AppTheme.of(context).alternate,
                      letterSpacing: 0.0,
                    ),
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.of(context).primary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).alternate,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
              child: Text(
                label,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.lexendDeca(),
                      color: label == context.l10n.chooseGroups
                          ? AppTheme.of(context).alternate
                          : AppTheme.of(context).secondary,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
          if (viewModel.availableGroups.isEmpty) ...[
            const SizedBox(height: 6.0),
            Text(
              context.l10n.noGroupsToShare,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String _selectedGroupsLabel(BuildContext context, ExperienceAddViewModel viewModel) {
    if (viewModel.selectedGroups.isEmpty) return context.l10n.chooseGroups;
    if (viewModel.allGroupsSelected) return context.l10n.allGroups;
    return viewModel.selectedGroups.map((group) => group.name ?? '').where((name) => name.isNotEmpty).join(', ');
  }

  Future<void> _openGroupPicker(BuildContext context, ExperienceAddViewModel viewModel) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.of(context).primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return JourneyLocaleScope(
          fixedLanguage: viewModel.fixedLanguage,
          builder: (context) {
            return ChangeNotifierProvider.value(
              value: viewModel,
              child: const _GroupPickerSheet(),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context, ExperienceAddViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 4.0),
      child: TextFormField(
        controller: viewModel.textController,
        focusNode: viewModel.textFocusNode,
        autofocus: true,
        obscureText: false,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: context.l10n.shareYourExperience,
          labelStyle: AppTheme.of(context).labelLarge.override(
                font: GoogleFonts.poppins(),
                color: AppTheme.of(context).primary,
                fontSize: 18.0,
                letterSpacing: 0.0,
              ),
          hintText: context.l10n.writeAboutExperience,
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

  Widget _buildErrorMessage(BuildContext context, ExperienceAddViewModel viewModel) {
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

  Widget _buildSuccessMessage(BuildContext context, ExperienceAddViewModel viewModel) {
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

  Widget _buildCommentsToggle(BuildContext context, ExperienceAddViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.enableComments,
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

  Widget _buildActions(BuildContext context, ExperienceAddViewModel viewModel) {
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
              text: context.l10n.cancel,
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
                            content: Text(context.l10n.draftSaved),
                            backgroundColor: AppTheme.of(context).success,
                          ),
                        );
                      }
                    },
              text: context.l10n.draft,
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
              text: viewModel.isSaving ? context.l10n.saving : context.l10n.publish,
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

class _GroupPickerSheet extends StatelessWidget {
  const _GroupPickerSheet();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExperienceAddViewModel>();
    final maxHeight = MediaQuery.sizeOf(context).height * 0.6;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.of(context).alternate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            CheckboxListTile(
              value: viewModel.allGroupsSelected,
              title: Text(
                context.l10n.allGroups,
                style: AppTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.lexendDeca(fontWeight: FontWeight.w600),
                      color: AppTheme.of(context).secondary,
                      letterSpacing: 0.0,
                    ),
              ),
              activeColor: AppTheme.of(context).primary,
              onChanged: viewModel.availableGroups.isEmpty
                  ? null
                  : (value) => viewModel.setAllGroups(value ?? false),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final group in viewModel.availableGroups)
                    CheckboxListTile(
                      value: viewModel.isGroupSelected(group.id),
                      title: Text(
                        group.name ?? '',
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(),
                              color: AppTheme.of(context).secondary,
                              letterSpacing: 0.0,
                            ),
                      ),
                      activeColor: AppTheme.of(context).primary,
                      onChanged: (_) => viewModel.toggleGroup(group.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
