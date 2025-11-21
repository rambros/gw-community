import '/backend/supabase/supabase.dart';
import '/data/repositories/notification_repository.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/ui/community/widgets/add_comment/add_comment_widget.dart';
import 'view_model/notification_view_view_model.dart';
import '/ui/community/sharing_view_page/widgets/comment_item_widget.dart';
import '/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class NotificationViewPage extends StatefulWidget {
  const NotificationViewPage({
    super.key,
    required this.notificationId,
    this.groupModerators,
  });

  final int? notificationId;
  final List<int>? groupModerators;

  static String routeName = 'NotificationViewPage';
  static String routePath = '/notificationViewPage';

  @override
  State<NotificationViewPage> createState() => _NotificationViewPageState();
}

class _NotificationViewPageState extends State<NotificationViewPage> {
  late NotificationViewViewModel _viewModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'notificationViewPage'});
    _viewModel = NotificationViewViewModel(
      repository: context.read<NotificationRepository>(),
      currentUserUid: context.currentUserIdOrEmpty,
      appState: context.read<FFAppState>(),
      groupModerators: widget.groupModerators,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.notificationId;
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
      child: Consumer<NotificationViewViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
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
                'Notification',
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
              child: viewModel.isLoading && viewModel.notification == null
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
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

  Widget _buildContent(BuildContext context, NotificationViewViewModel viewModel) {
    final notification = viewModel.notification;
    if (notification == null) {
      return Center(
        child: Text(
          viewModel.errorMessage ?? 'Notification not found.',
          style: FlutterFlowTheme.of(context).labelLarge,
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
        child: StickyHeader(
          overlapHeaders: false,
          header: _buildHeaderCard(context, notification),
          content: Column(
            children: [
              _buildNotificationBody(context, viewModel, notification),
              const SizedBox(height: 16.0),
              _buildCommentsList(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, CcViewNotificationsUsersRow notification) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: FlutterFlowTheme.of(context).primaryBackground,
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
                      valueOrDefault<String>(notification.title, 'title'),
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.lexendDeca(
                              fontWeight: FlutterFlowTheme.of(context).titleMedium.fontWeight,
                              fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).secondary,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From ${valueOrDefault<String>(notification.displayName, 'name')} - Group Administrator',
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).secondary,
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                        if (notification.updatedAt != null)
                          Text(
                            dateTimeFormat(
                              'MMMMEEEEd',
                              notification.updatedAt,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).secondary,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        Text(
                          notification.visibility == 'everyone'
                              ? 'Notification for everyone'
                              : 'Only for the Group ${notification.groupName}',
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
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBody(
    BuildContext context,
    NotificationViewViewModel viewModel,
    CcViewNotificationsUsersRow notification,
  ) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: FlutterFlowTheme.of(context).primaryBackground,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
            child: Html(
              data: notification.text ?? '',
              onLinkTap: (url, _, __) {
                if (url != null) {
                  launchURL(url);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildCommentButton(context, viewModel, notification),
                if (viewModel.canDeleteNotification)
                  FlutterFlowIconButton(
                    borderRadius: 8.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      Icons.delete,
                      color: FlutterFlowTheme.of(context).secondary,
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
                            final success = await viewModel.deleteNotification();
                            if (!success || !context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Notification deleted successfully',
                                  style: TextStyle(
                                    color: FlutterFlowTheme.of(context).primaryText,
                                  ),
                                ),
                                backgroundColor: FlutterFlowTheme.of(context).secondary,
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
                      color: FlutterFlowTheme.of(context).secondary,
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
    NotificationViewViewModel viewModel,
    CcViewNotificationsUsersRow notification,
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
              color: FlutterFlowTheme.of(context).alternate,
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
                    color: notification.locked == true
                        ? FlutterFlowTheme.of(context).alternate
                        : FlutterFlowTheme.of(context).secondary,
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
                    valueOrDefault<String>(notification.comments?.toString(), '0'),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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

  Widget _buildCommentsList(BuildContext context, NotificationViewViewModel viewModel) {
    if (viewModel.comments.isEmpty) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
        child: Text(
          'No comments yet.',
          style: FlutterFlowTheme.of(context).labelLarge,
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
                  sharingId: widget.notificationId!,
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
