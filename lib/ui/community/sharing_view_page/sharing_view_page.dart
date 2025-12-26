import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/utils/flutter_flow_util.dart';
import '../sharing_edit_page/sharing_edit_page.dart';
import '../widgets/add_comment/add_comment_widget.dart';
import 'view_model/sharing_view_view_model.dart';
import 'widgets/comment_item_widget.dart';
import 'widgets/sharing_actions_widget.dart';
import 'widgets/sharing_content_widget.dart';
import 'widgets/sharing_header_widget.dart';

/// Página de visualização de um Sharing individual
/// Refatorada para seguir arquitetura MVVM estilo Compass
class SharingViewPage extends StatefulWidget {
  const SharingViewPage({
    super.key,
    required this.sharingId,
    this.groupModerators,
  });

  final int? sharingId;

  /// Who can delete sharing
  final List<int>? groupModerators;

  static String routeName = 'sharingViewPage';
  static String routePath = '/sharingViewPage';

  @override
  State<SharingViewPage> createState() => _SharingViewPageState();
}

class _SharingViewPageState extends State<SharingViewPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'sharingViewPage'});

    // Carregar dados após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.sharingId != null) {
        context.read<SharingViewViewModel>().loadSharing(widget.sharingId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SharingViewViewModel>();

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

  Widget _buildBody(BuildContext context, SharingViewViewModel viewModel) {
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
    if (viewModel.sharing == null) {
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
    final sharing = viewModel.sharing!;

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
                      SharingHeaderWidget(sharing: sharing),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Conteúdo do sharing
                      SharingContentWidget(sharing: sharing),
                      // Ações (comentar, deletar, lock)
                      _buildActionsCard(context, viewModel, sharing),
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

  Widget _buildActionsCard(BuildContext context, SharingViewViewModel viewModel, sharing) {
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
            child: SharingActionsWidget(
              sharing: sharing,
              canEdit: viewModel.canEdit(),
              canDelete: viewModel.canDelete(),
              canLock: viewModel.canLock(),
              onComment: () => _showAddCommentModal(context, widget.sharingId!, null),
              onEdit: () => _handleEditSharing(context, sharing),
              onDelete: () => _handleDeleteSharing(context, viewModel),
              onToggleLock: () => viewModel.toggleLockCommand(widget.sharingId!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context, SharingViewViewModel viewModel) {
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
    int sharingId,
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
                  sharingId: sharingId,
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
      context.read<SharingViewViewModel>().refreshComments(sharingId);
    }
  }

  Future<void> _handleEditSharing(BuildContext context, sharing) async {
    await context.pushNamed(
      SharingEditPage.routeName,
      extra: {'sharingRow': sharing},
    );

    // Recarregar dados após voltar da edição
    if (context.mounted && widget.sharingId != null) {
      context.read<SharingViewViewModel>().loadSharing(widget.sharingId!);
    }
  }

  Future<void> _handleDeleteSharing(
    BuildContext context,
    SharingViewViewModel viewModel,
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

    if (confirmDialogResponse && widget.sharingId != null) {
      if (!context.mounted) return;
      await viewModel.deleteSharingCommand(context, widget.sharingId!);
    }
  }

  Future<void> _handleDeleteComment(
    BuildContext context,
    SharingViewViewModel viewModel,
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

    if (confirmDialogResponse && widget.sharingId != null) {
      if (!mounted) return;
      await viewModel.deleteCommentCommand(commentId, widget.sharingId!);
    }
  }
}
