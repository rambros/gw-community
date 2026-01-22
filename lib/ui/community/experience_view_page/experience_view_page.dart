import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/community/experience_edit_page/experience_edit_page.dart';
import 'package:gw_community/ui/community/experience_view_page/view_model/experience_view_view_model.dart';
import 'package:gw_community/ui/community/experience_view_page/widgets/comment_item_widget.dart';
import 'package:gw_community/ui/community/experience_view_page/widgets/experience_actions_widget.dart';
import 'package:gw_community/ui/community/experience_view_page/widgets/experience_content_widget.dart';
import 'package:gw_community/ui/community/experience_view_page/widgets/experience_header_widget.dart';
import 'package:gw_community/ui/community/widgets/add_comment/add_comment_widget.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

/// Página de visualização de um Experience individual
/// Refatorada para seguir arquitetura MVVM estilo Compass
class ExperienceViewPage extends StatefulWidget {
  const ExperienceViewPage({
    super.key,
    required this.experienceId,
    this.groupModerators,
  });

  final int? experienceId;

  /// Who can delete experience
  final List<int>? groupModerators;

  static String routeName = 'experienceViewPage';
  static String routePath = '/experienceViewPage';

  @override
  State<ExperienceViewPage> createState() => _ExperienceViewPageState();
}

class _ExperienceViewPageState extends State<ExperienceViewPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'experienceViewPage'});

    // Carregar dados após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.experienceId != null) {
        context.read<ExperienceViewViewModel>().loadExperience(widget.experienceId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExperienceViewViewModel>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
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
        onPressed: () async {
          context.pop();
        },
      ),
      title: Text(
        'Experience',
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

  Widget _buildBody(BuildContext context, ExperienceViewViewModel viewModel) {
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

    // Error state
    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            viewModel.errorMessage!,
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(),
                  color: AppTheme.of(context).error,
                  letterSpacing: 0.0,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Empty state
    if (viewModel.experience == null) {
      return Center(
        child: Text(
          'Experience not found',
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(),
                letterSpacing: 0.0,
              ),
        ),
      );
    }

    // Success state
    final experience = viewModel.experience!;

    return SafeArea(
      top: true,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        height: MediaQuery.sizeOf(context).height * 0.94,
        decoration: const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
          child: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                StickyHeader(
                  overlapHeaders: false,
                  header: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Header com informações do autor
                      ExperienceHeaderWidget(experience: experience),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Conteúdo do experience
                      ExperienceContentWidget(experience: experience),
                      // Ações (comentar, deletar, lock)
                      _buildActionsCard(context, viewModel, experience),
                      // Lista de comentários
                      _buildCommentsList(context, viewModel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, ExperienceViewViewModel viewModel, experience) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: AppTheme.of(context).primaryBackground,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 8.0),
            child: ExperienceActionsWidget(
              experience: experience,
              canEdit: false,
              canDelete: false,
              canLock: viewModel.canLock(),
              onComment: () => _showAddCommentModal(context, widget.experienceId!, null),
              onEdit: () => _handleEditExperience(context, experience),
              onDelete: () => _handleDeleteExperience(context, viewModel),
              onToggleLock: () => viewModel.toggleLockCommand(widget.experienceId!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context, ExperienceViewViewModel viewModel) {
    if (viewModel.comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No comments yet',
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(),
                letterSpacing: 0.0,
              ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: viewModel.comments.length,
        itemBuilder: (context, index) {
          final comment = viewModel.comments[index];
          return CommentItemWidget(
            comment: comment,
            canDelete: viewModel.canDeleteComment(comment.userId ?? ''),
            onReply: () => _showAddCommentModal(
              context,
              comment.sharingId!,
              comment.id,
            ),
            onDelete: () => _handleDeleteComment(context, viewModel, comment.id!),
          );
        },
      ),
    );
  }

  // ========== HELPER METHODS ==========

  Future<void> _showAddCommentModal(
    BuildContext context,
    int experienceId,
    int? parentId,
  ) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return WebViewAware(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: SizedBox(
                height: 200.0,
                child: AddCommentWidget(
                  experienceId: experienceId,
                  parentId: parentId,
                  photoUrl: context.read<FFAppState>().loginUser.photoUrl,
                  fullName: context.read<FFAppState>().loginUser.fullName,
                ),
              ),
            ),
          ),
        );
      },
    );

    if (context.mounted) {
      context.read<ExperienceViewViewModel>().refreshComments(experienceId);
    }
  }

  Future<void> _handleEditExperience(BuildContext context, experience) async {
    await context.pushNamed(
      ExperienceEditPage.routeName,
      extra: {'experienceRow': experience},
    );

    // Recarregar dados após voltar da edição
    if (context.mounted && widget.experienceId != null) {
      context.read<ExperienceViewViewModel>().loadExperience(widget.experienceId!);
    }
  }

  Future<void> _handleDeleteExperience(
    BuildContext context,
    ExperienceViewViewModel viewModel,
  ) async {
    final confirmDialogResponse = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) {
            return WebViewAware(
              child: AlertDialog(
                title: const Text('Deletion of Experience'),
                content: const Text('Confirm deletion of this experience?'),
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

    if (confirmDialogResponse && widget.experienceId != null) {
      if (!context.mounted) return;
      await viewModel.deleteExperienceCommand(context, widget.experienceId!);
    }
  }

  Future<void> _handleDeleteComment(
    BuildContext context,
    ExperienceViewViewModel viewModel,
    int commentId,
  ) async {
    final confirmDialogResponse = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) {
            return WebViewAware(
              child: AlertDialog(
                title: const Text('Deletion of Comment'),
                content: const Text('Confirm deletion of this comment?'),
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

    if (confirmDialogResponse && widget.experienceId != null) {
      if (!mounted) return;
      await viewModel.deleteCommentCommand(commentId, widget.experienceId!);
    }
  }
}
