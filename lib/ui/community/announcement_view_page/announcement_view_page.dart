import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/community/announcement_view_page/view_model/announcement_view_view_model.dart';
import 'package:gw_community/ui/community/sharing_view_page/widgets/comment_item_widget.dart';
import 'package:gw_community/ui/community/widgets/add_comment/add_comment_widget.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class AnnouncementViewPage extends StatefulWidget {
  const AnnouncementViewPage({
    super.key,
    required this.announcementId,
    this.groupModerators,
  });

  final int? announcementId;
  final List<int>? groupModerators;

  static String routeName = 'announcementViewPage';
  static String routePath = '/announcementViewPage';

  @override
  State<AnnouncementViewPage> createState() => _AnnouncementViewPageState();
}

class _AnnouncementViewPageState extends State<AnnouncementViewPage> {
  late AnnouncementViewViewModel _viewModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'announcementViewPage'});
    _viewModel = AnnouncementViewViewModel(
      repository: context.read<AnnouncementRepository>(),
      currentUserUid: context.currentUserIdOrEmpty,
      appState: context.read<FFAppState>(),
      groupModerators: widget.groupModerators,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.announcementId;
      if (id != null) {
        _viewModel.initialize(id);
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AnnouncementViewViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
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
                'Announcement',
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
              child: viewModel.isLoading && viewModel.announcement == null
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.of(context).primary,
                        ),
                      ),
                    )
                  : _buildContent(context, viewModel),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AnnouncementViewViewModel viewModel) {
    final announcement = viewModel.announcement;
    if (announcement == null) {
      return Center(
        child: Text(
          viewModel.errorMessage ?? 'Announcement not found.',
          style: AppTheme.of(context).labelLarge,
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
        child: StickyHeader(
          overlapHeaders: false,
          header: _buildHeaderCard(context, announcement),
          content: Column(
            children: [
              _buildNotificationBody(context, viewModel, announcement),
              const SizedBox(height: 16.0),
              _buildCommentsList(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, CcViewNotificationsUsersRow announcement) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: AppTheme.of(context).primaryBackground,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                    child: Text(
                      valueOrDefault<String>(announcement.title, 'title'),
                      style: AppTheme.of(context).titleMedium.override(
                            font: GoogleFonts.lexendDeca(
                              fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                              fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                            ),
                            color: AppTheme.of(context).secondary,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                    child: Text(
                      '${dateTimeFormat('MMM d', announcement.updatedAt)} - From ${valueOrDefault<String>(announcement.displayName, 'name')} - Facilitator',
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexendDeca(
                              fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                            ),
                            color: AppTheme.of(context).secondary,
                            fontSize: 13.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBody(
    BuildContext context,
    AnnouncementViewViewModel viewModel,
    CcViewNotificationsUsersRow announcement,
  ) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: AppTheme.of(context).primaryBackground,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
            child: MarkdownBody(
              data: announcement.text ?? '',
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchURL(href);
                }
              },
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.lexendDeca(
                  color: AppTheme.of(context).secondary,
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                ),
                strong: GoogleFonts.lexendDeca(
                  color: AppTheme.of(context).secondary,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
                em: GoogleFonts.lexendDeca(
                  color: AppTheme.of(context).secondary,
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                a: GoogleFonts.lexendDeca(
                  color: AppTheme.of(context).primary,
                  fontSize: 14.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildCommentButton(context, viewModel, announcement),
                if (viewModel.canEditAnnouncement)
                  FlutterFlowIconButton(
                    borderRadius: 8.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      Icons.edit,
                      color: AppTheme.of(context).secondary,
                      size: 26.0,
                    ),
                    onPressed: viewModel.isActionInProgress
                        ? null
                        : () async {
                            final wasEdited = await context.pushNamed<bool>(
                              AnnouncementEditPage.routeName,
                              extra: {
                                'sharingRow': announcement,
                              },
                            );
                            // Se o anúncio foi editado, volta para a página de anúncios do grupo
                            if (wasEdited == true && context.mounted) {
                              context.pop();
                              return;
                            }
                            viewModel.loadAnnouncement();
                          },
                  ),
                if (viewModel.canDeleteAnnouncement)
                  FlutterFlowIconButton(
                    borderRadius: 8.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      Icons.delete,
                      color: AppTheme.of(context).secondary,
                      size: 26.0,
                    ),
                    onPressed: viewModel.isActionInProgress
                        ? null
                        : () async {
                            final confirm = await _showConfirmationDialog(
                              context,
                              title: 'Deletion of Notification',
                              message: 'Confirm deletion of this notification?',
                            );
                            if (!confirm || !context.mounted) return;
                            final success = await viewModel.deleteAnnouncement();
                            if (!success || !context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Notification deleted successfully',
                                  style: TextStyle(
                                    color: AppTheme.of(context).primaryText,
                                  ),
                                ),
                                backgroundColor: AppTheme.of(context).secondary,
                              ),
                            );
                            context.pushNamed(CommunityPage.routeName);
                          },
                  ),
                if (viewModel.canToggleLock)
                  FlutterFlowIconButton(
                    borderRadius: 8.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      viewModel.isLocked ? Icons.lock : Icons.lock_open,
                      color: AppTheme.of(context).secondary,
                      size: 26.0,
                    ),
                    onPressed: viewModel.isActionInProgress
                        ? null
                        : () async {
                            await viewModel.toggleLock();
                          },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentButton(
    BuildContext context,
    AnnouncementViewViewModel viewModel,
    CcViewNotificationsUsersRow announcement,
  ) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
        child: Container(
          height: 44.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: AppTheme.of(context).alternate,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              children: [
                FlutterFlowIconButton(
                  borderRadius: 8.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.comment_rounded,
                    color:
                        announcement.locked == true ? AppTheme.of(context).alternate : AppTheme.of(context).secondary,
                    size: 28.0,
                  ),
                  onPressed: !viewModel.canComment
                      ? null
                      : () async {
                          await _showAddCommentSheet(context, parentId: null);
                          await viewModel.refreshComments();
                        },
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                  child: Text(
                    valueOrDefault<String>(announcement.comments?.toString(), '0'),
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                          ),
                          fontSize: 17.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context, AnnouncementViewViewModel viewModel) {
    if (viewModel.comments.isEmpty) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
        child: Text(
          'No comments yet.',
          style: AppTheme.of(context).labelLarge,
        ),
      );
    }

    return Column(
      children: viewModel.comments.map((comment) {
        return CommentItemWidget(
          comment: comment,
          canDelete: viewModel.canDeleteComment(comment.userId),
          onReply: () async {
            await _showAddCommentSheet(context, parentId: comment.id);
            await viewModel.refreshComments();
          },
          onDelete: viewModel.canDeleteComment(comment.userId)
              ? () async {
                  final confirm = await _showConfirmationDialog(
                    context,
                    title: 'Deletion of Comment',
                    message: 'Confirm deletion of this comment?',
                  );
                  if (!confirm) return;
                  await viewModel.deleteComment(comment.id!);
                }
              : null,
        );
      }).toList(),
    );
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final confirmDialogResponse = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) {
            return WebViewAware(
              child: AlertDialog(
                title: Text(title),
                content: Text(message),
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
    return confirmDialogResponse;
  }

  Future<void> _showAddCommentSheet(BuildContext context, {int? parentId}) async {
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
                  sharingId: widget.announcementId!,
                  parentId: parentId,
                  photoUrl: FFAppState().loginUser.photoUrl,
                  fullName: FFAppState().loginUser.fullName,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
