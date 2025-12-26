import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import '/data/repositories/support_repository.dart';
import '/data/services/supabase/supabase.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/utils/flutter_flow_util.dart';
import '/utils/context_extensions.dart';
import '../widgets/message_bubble_widget.dart';
import '../widgets/status_badge_widget.dart';
import 'view_model/request_chat_view_model.dart';

class RequestChatPage extends StatelessWidget {
  const RequestChatPage({
    super.key,
    required this.requestId,
  });

  final int requestId;

  static const String routeName = 'requestChatPage';
  static const String routePath = '/support/chat/:id';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RequestChatViewModel(
        repository: SupportRepository(),
        requestId: requestId,
      ),
      child: const _RequestChatPageContent(),
    );
  }
}

class _RequestChatPageContent extends StatelessWidget {
  const _RequestChatPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RequestChatViewModel>();
    final currentUserId = context.currentUserIdOrEmpty;

    if (viewModel.isLoading) {
      return Scaffold(
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
            'Question',
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(),
                  color: Colors.white,
                  fontSize: 20.0,
                ),
          ),
          centerTitle: true,
          elevation: 4.0,
        ),
        body: Center(
          child: SpinKitRipple(
            color: AppTheme.of(context).primary,
            size: 50.0,
          ),
        ),
      );
    }

    final request = viewModel.request;
    if (request == null) {
      return Scaffold(
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
          centerTitle: true,
          elevation: 4.0,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.of(context).error,
              ),
              const SizedBox(height: 16),
              Text(
                'Question not found',
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.lexendDeca(),
                      color: AppTheme.of(context).error,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
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
          request.requestNumber,
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(),
                color: Colors.white,
                fontSize: 18.0,
              ),
        ),
        actions: [
          _buildActionsMenu(context, viewModel, request),
        ],
        centerTitle: true,
        elevation: 4.0,
      ),
      body: Column(
        children: [
          // Request header
          _buildRequestHeader(context, request),

          // Messages list
          Expanded(
            child: _buildMessagesList(context, viewModel, currentUserId),
          ),

          // Input area or resolved banner
          if (viewModel.isResolved)
            _buildResolvedBanner(context, viewModel)
          else
            _buildInputArea(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildActionsMenu(
    BuildContext context,
    RequestChatViewModel viewModel,
    CcSupportRequestsRow request,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) async {
        switch (value) {
          case 'resolve':
            await _confirmResolve(context, viewModel);
            break;
          case 'reopen':
            await _confirmReopen(context, viewModel);
            break;
        }
      },
      itemBuilder: (context) => [
        if (!viewModel.isResolved)
          PopupMenuItem<String>(
            value: 'resolve',
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: AppTheme.of(context).success,
                ),
                const SizedBox(width: 12),
                Text(
                  'Mark as Completed',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    color: AppTheme.of(context).success,
                  ),
                ),
              ],
            ),
          )
        else
          PopupMenuItem<String>(
            value: 'reopen',
            child: Row(
              children: [
                Icon(
                  Icons.refresh,
                  size: 20,
                  color: AppTheme.of(context).primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Reopen Question',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    color: AppTheme.of(context).primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRequestHeader(BuildContext context, CcSupportRequestsRow request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          StatusBadgeWidget(status: request.status),
          const SizedBox(height: 12),

          // Title
          Text(
            request.title,
            style: GoogleFonts.lexendDeca(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.of(context).secondary,
            ),
          ),
          const SizedBox(height: 8),

          // Description (collapsed)
          if (request.description.isNotEmpty)
            Text(
              request.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.of(context).secondary.withValues(alpha: 0.7),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(
    BuildContext context,
    RequestChatViewModel viewModel,
    String currentUserId,
  ) {
    return StreamBuilder<List<CcSupportMessagesRow>>(
      stream: viewModel.messagesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Center(
            child: SpinKitRipple(
              color: AppTheme.of(context).primary,
              size: 40,
            ),
          );
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: AppTheme.of(context).cadetGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: GoogleFonts.lexendDeca(
                      fontSize: 16,
                      color: AppTheme.of(context).cadetGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send a message to start the conversation',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.of(context).cadetGrey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.scrollToBottomOnNewMessages();
        });

        return ListView.builder(
          controller: viewModel.scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isCurrentUser = message.authorId == currentUserId;
            return MessageBubbleWidget(
              message: message,
              isCurrentUser: isCurrentUser,
            );
          },
        );
      },
    );
  }

  Widget _buildInputArea(BuildContext context, RequestChatViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected image preview
            if (viewModel.selectedImage != null)
              _buildImagePreview(context, viewModel),

            // Input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment button
                IconButton(
                  onPressed: () => _showAttachmentOptions(context, viewModel),
                  icon: Icon(
                    Icons.attach_file,
                    color: AppTheme.of(context).primary,
                  ),
                ),

                // Text input
                Expanded(
                  child: TextField(
                    controller: viewModel.messageController,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.inter(
                        color: AppTheme.of(context).secondary.withValues(alpha: 0.4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.of(context).secondary.withValues(alpha: 0.05),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppTheme.of(context).secondary,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: viewModel.canSendMessage
                        ? () => _sendMessage(context, viewModel)
                        : null,
                    icon: viewModel.isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, RequestChatViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              viewModel.selectedImage!,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => viewModel.clearImage(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolvedBanner(BuildContext context, RequestChatViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF388E3C),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This question has been completed',
                style: GoogleFonts.lexendDeca(
                  fontSize: 14,
                  color: const Color(0xFF388E3C),
                ),
              ),
            ),
            TextButton(
              onPressed: () => _confirmReopen(context, viewModel),
              child: Text(
                'Reopen',
                style: GoogleFonts.lexendDeca(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.of(context).primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context, RequestChatViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: AppTheme.of(context).primary,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickImage();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: AppTheme.of(context).primary,
              ),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                viewModel.takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(BuildContext context, RequestChatViewModel viewModel) async {
    final success = await viewModel.sendMessage();
    if (!success && viewModel.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: AppTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _confirmResolve(
    BuildContext context,
    RequestChatViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => WebViewAware(
        child: AlertDialog(
          title: const Text('Mark as Completed'),
          content: const Text(
            'Are you sure your question has been answered? You can reopen it later if needed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.of(context).secondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Mark as Completed',
                style: TextStyle(color: AppTheme.of(context).success),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await viewModel.markAsResolved();
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Question marked as completed'),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
      }
    }
  }

  Future<void> _confirmReopen(
    BuildContext context,
    RequestChatViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => WebViewAware(
        child: AlertDialog(
          title: const Text('Reopen Question'),
          content: const Text(
            'Do you need further assistance with this question?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.of(context).secondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Reopen',
                style: TextStyle(color: AppTheme.of(context).primary),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await viewModel.reopenRequest();
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Question reopened'),
            backgroundColor: AppTheme.of(context).primary,
          ),
        );
      }
    }
  }
}
