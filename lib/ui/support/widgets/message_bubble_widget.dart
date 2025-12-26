import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

class MessageBubbleWidget extends StatelessWidget {
  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  final CcSupportMessagesRow message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isCurrentUser ? 48 : 16,
        right: isCurrentUser ? 16 : 48,
        top: 8,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Author info (only for admin/system messages)
          if (!isCurrentUser) _buildAuthorInfo(context),

          // Message bubble
          Container(
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppTheme.of(context).primary
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image attachment
                  if (message.hasImage)
                    _buildImage(context),

                  // Message content
                  if (message.content.isNotEmpty &&
                      message.content != 'Image attached')
                    Text(
                      message.content,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: isCurrentUser
                            ? Colors.white
                            : AppTheme.of(context).secondary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatTime(message.createdAt),
              style: GoogleFonts.lexendDeca(
                fontSize: 11,
                color: AppTheme.of(context).secondary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    final isAdmin = message.authorType == 'admin';
    final isSystem = message.authorType == 'system';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(
            imageUrl: message.authorPhoto,
            fullName: message.authorName,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            message.authorName,
            style: GoogleFonts.lexendDeca(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isAdmin
                  ? AppTheme.of(context).primary
                  : AppTheme.of(context).secondary.withValues(alpha: 0.7),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Support',
                style: GoogleFonts.lexendDeca(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.of(context).primary,
                ),
              ),
            ),
          ],
          if (isSystem) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.settings,
              size: 12,
              color: AppTheme.of(context).secondary.withValues(alpha: 0.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: (message.content.isNotEmpty &&
                 message.content != 'Image attached')
            ? 8
            : 0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () => _showFullImage(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 250,
              maxHeight: 200,
            ),
            child: CachedNetworkImage(
              imageUrl: message.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 150,
                height: 100,
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 150,
                height: 100,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: message.imageUrl!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final isToday = now.day == date.day &&
        now.month == date.month &&
        now.year == date.year;

    if (isToday) {
      return DateFormat('HH:mm').format(date);
    } else {
      return DateFormat('MMM d, HH:mm').format(date);
    }
  }
}
