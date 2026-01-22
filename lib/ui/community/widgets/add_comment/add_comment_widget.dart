import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/experience_repository.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/community/widgets/add_comment/view_model/add_comment_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class AddCommentWidget extends StatelessWidget {
  const AddCommentWidget({
    super.key,
    required this.experienceId,
    this.parentId,
    this.photoUrl,
    required this.fullName,
  });

  final int experienceId;
  final int? parentId;
  final String? photoUrl;
  final String? fullName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddCommentViewModel(
        repository: context.read<ExperienceRepository>(),
        currentUserUid: context.currentUserIdOrEmpty,
        experienceId: experienceId,
        parentId: parentId,
      ),
      child: _AddCommentView(
        fullName: fullName,
        photoUrl: photoUrl,
        experienceId: experienceId,
      ),
    );
  }
}

class _AddCommentView extends StatelessWidget {
  const _AddCommentView({
    required this.fullName,
    required this.photoUrl,
    required this.experienceId,
  });

  final String? photoUrl;
  final String? fullName;
  final int experienceId;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddCommentViewModel>();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          boxShadow: const [
            BoxShadow(
              blurRadius: 5.0,
              color: Color(0x162D3A21),
              offset: Offset(0.0, 3.0),
            ),
          ],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    imageUrl: photoUrl,
                    fullName: fullName,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                      child: TextFormField(
                        controller: viewModel.textController,
                        focusNode: viewModel.textFieldFocusNode,
                        onChanged: (value) => EasyDebounce.debounce(
                          'add_comment_text_controller',
                          const Duration(milliseconds: 200),
                          () => viewModel.onTextChanged(value),
                        ),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Write something...',
                          hintStyle: AppTheme.of(context).labelSmall.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: AppTheme.of(context).labelSmall.fontWeight,
                                  fontStyle: AppTheme.of(context).labelSmall.fontStyle,
                                ),
                                color: AppTheme.of(context).secondary,
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                                fontWeight: AppTheme.of(context).labelSmall.fontWeight,
                                fontStyle: AppTheme.of(context).labelSmall.fontStyle,
                              ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0x00000000),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0x00000000),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).error,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          focusedErrorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).error,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 8.0, 12.0),
                        ),
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                              ),
                              color: AppTheme.of(context).secondary,
                              letterSpacing: 0.0,
                              fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                            ),
                        maxLines: 8,
                        minLines: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 12.0,
              thickness: 2.0,
              color: AppTheme.of(context).alternate,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (viewModel.errorMessage != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                        child: Text(
                          viewModel.errorMessage!,
                          style: AppTheme.of(context).labelSmall.override(
                                font: GoogleFonts.poppins(),
                                color: AppTheme.of(context).error,
                                letterSpacing: 0.0,
                              ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  FFButtonWidget(
                    onPressed: viewModel.canSubmit
                        ? () async {
                            final wasSaved = await viewModel.submitComment();
                            if (!wasSaved) return;

                            if (context.mounted) {
                              Navigator.pop(context, true);
                              context.pushNamed(
                                ExperienceViewPage.routeName,
                                queryParameters: {
                                  'experienceId': serializeParam(experienceId, ParamType.int),
                                }.withoutNulls,
                              );
                            }
                          }
                        : null,
                    text: viewModel.isSubmitting ? 'Posting...' : 'Post',
                    options: FFButtonOptions(
                      width: 90.0,
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
                            fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                            fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                          ),
                      elevation: 1.0,
                      borderSide: BorderSide(
                        color: AppTheme.of(context).secondaryBackground,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                      disabledColor: AppTheme.of(context).alternate,
                      disabledTextColor: AppTheme.of(context).secondaryBackground,
                    ),
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
