import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/notifications/in_app_notifications_page/view_model/in_app_notifications_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Page that displays all in-app notifications for the current user
class InAppNotificationsPage extends StatefulWidget {
  const InAppNotificationsPage({super.key});

  static const String routeName = 'inAppNotificationsPage';
  static const String routePath = '/inAppNotificationsPage';

  @override
  State<InAppNotificationsPage> createState() => _InAppNotificationsPageState();
}

class _InAppNotificationsPageState extends State<InAppNotificationsPage> {
  late InAppNotificationsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = InAppNotificationsViewModel();
    _viewModel.loadNotifications();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<InAppNotificationsViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: AppTheme.of(context).primaryBackground,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.of(context).secondary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Notifications',
                style: AppTheme.of(context).headlineSmall,
              ),
              centerTitle: true,
              actions: [
                if (viewModel.notifications.isNotEmpty)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppTheme.of(context).secondary,
                    ),
                    onSelected: (value) => _handleMenuAction(context, viewModel, value),
                    itemBuilder: (context) => [
                      if (viewModel.hasUnread)
                        const PopupMenuItem(
                          value: 'mark_all_read',
                          child: Row(
                            children: [
                              Icon(Icons.done_all, size: 20),
                              SizedBox(width: 12),
                              Text('Mark all as read'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete_read',
                        child: Row(
                          children: [
                            Icon(Icons.delete_sweep, size: 20),
                            SizedBox(width: 12),
                            Text('Delete read'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete_all',
                        child: Row(
                          children: [
                            Icon(Icons.delete_forever, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete all', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            body: _buildBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, InAppNotificationsViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.of(context).primary,
        ),
      );
    }

    if (viewModel.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: AppTheme.of(context).cadetGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).cadetGrey,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      );
    }

    final unreadNotifications = viewModel.unreadNotifications;
    final readNotifications = viewModel.readNotifications;

    return RefreshIndicator(
      onRefresh: () => viewModel.loadNotifications(),
      color: AppTheme.of(context).primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Unread section
          if (unreadNotifications.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              title: 'New',
              count: unreadNotifications.length,
              color: AppTheme.of(context).primary,
            ),
            ...unreadNotifications.map((notification) => _buildNotificationItem(
                  context,
                  viewModel,
                  notification,
                )),
          ],

          // Read section
          if (readNotifications.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              title: 'Read',
              count: readNotifications.length,
              color: AppTheme.of(context).cadetGrey,
              isRead: true,
            ),
            ...readNotifications.map((notification) => _buildNotificationItem(
                  context,
                  viewModel,
                  notification,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    bool isRead = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isRead
          ? AppTheme.of(context).gray200.withValues(alpha: 0.3)
          : AppTheme.of(context).primary.withValues(alpha: 0.05),
      child: Row(
        children: [
          Icon(
            isRead ? Icons.done_all : Icons.notifications_active,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTheme.of(context).bodyMedium.override(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: AppTheme.of(context).bodySmall.override(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    InAppNotificationsViewModel viewModel,
    CcNotificationsRow notification,
  ) {
    return Column(
      children: [
        Dismissible(
          key: Key('notification_${notification.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: AppTheme.of(context).error,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (_) => viewModel.deleteNotification(notification.id),
          child: _NotificationTile(
            notification: notification,
            onTap: () => _handleNotificationTap(context, viewModel, notification),
            onDelete: () => viewModel.deleteNotification(notification.id),
          ),
        ),
        Divider(
          height: 1,
          color: AppTheme.of(context).gray200,
        ),
      ],
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    InAppNotificationsViewModel viewModel,
    CcNotificationsRow notification,
  ) async {
    // Mark as read
    await viewModel.markAsRead(notification.id);

    // Navigate based on notification type
    if (notification.referenceType == 'experience' && notification.referenceId != null) {
      if (context.mounted) {
        context.pushNamed(
          SharingViewPage.routeName,
          extra: {'sharingId': notification.referenceId},
        );
      }
    }
  }

  void _handleMenuAction(
    BuildContext context,
    InAppNotificationsViewModel viewModel,
    String action,
  ) {
    switch (action) {
      case 'mark_all_read':
        viewModel.markAllAsRead();
        break;
      case 'delete_read':
        _showDeleteConfirmation(
          context,
          title: 'Delete Read Notifications',
          message: 'Are you sure you want to delete all read notifications?',
          onConfirm: () => viewModel.deleteReadNotifications(),
        );
        break;
      case 'delete_all':
        _showDeleteConfirmation(
          context,
          title: 'Delete All Notifications',
          message: 'Are you sure you want to delete all notifications? This action cannot be undone.',
          onConfirm: () => viewModel.deleteAllNotifications(),
        );
        break;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.of(context).secondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final CcNotificationsRow notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    final iconColor = isRead
        ? _getNotificationColor(context).withValues(alpha: 0.4)
        : _getNotificationColor(context);
    final textOpacity = isRead ? 0.6 : 1.0;

    return Container(
      color: isRead
          ? AppTheme.of(context).gray200.withValues(alpha: 0.15)
          : AppTheme.of(context).primaryBackground,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: isRead ? 0.05 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getNotificationIcon(),
            color: iconColor,
            size: 20,
          ),
        ),
        title: Opacity(
          opacity: textOpacity,
          child: Text(
            notification.title,
            style: AppTheme.of(context).bodySmall.override(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
          ),
        ),
        subtitle: Opacity(
          opacity: textOpacity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notification.message != null) ...[
                const SizedBox(height: 4),
                Text(
                  notification.message!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.of(context).bodyMedium.override(
                        color: AppTheme.of(context).cadetGrey,
                        fontSize: 13,
                      ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _formatDate(notification.createdAt),
                    style: AppTheme.of(context).bodyMedium.override(
                          fontSize: 12,
                          color: AppTheme.of(context).cadetGrey,
                        ),
                  ),
                  if (isRead) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.done,
                      size: 14,
                      color: AppTheme.of(context).cadetGrey,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRead)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary,
                  shape: BoxShape.circle,
                ),
              ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: AppTheme.of(context).cadetGrey,
              ),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case 'experience_approved':
        return Icons.check_circle;
      case 'experience_rejected':
        return Icons.cancel;
      case 'experience_changes_requested':
        return Icons.edit_note;
      case 'experience_pending_moderation':
        return Icons.hourglass_empty;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(BuildContext context) {
    switch (notification.type) {
      case 'experience_approved':
        return AppTheme.of(context).success;
      case 'experience_rejected':
        return AppTheme.of(context).error;
      case 'experience_changes_requested':
        return AppTheme.of(context).warning;
      case 'experience_pending_moderation':
        return AppTheme.of(context).copperRed;
      default:
        return AppTheme.of(context).primary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
