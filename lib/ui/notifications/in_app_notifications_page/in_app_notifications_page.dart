import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/notifications/in_app_notifications_page/view_model/in_app_notifications_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
                icon: Icon(Icons.arrow_back_ios, color: AppTheme.of(context).secondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text('Notifications', style: AppTheme.of(context).headlineSmall),
              centerTitle: true,
              actions: [
                if (viewModel.items.isNotEmpty)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: AppTheme.of(context).secondary),
                    onSelected: (value) => _handleMenuAction(context, viewModel, value),
                    itemBuilder: (context) => [
                      if (viewModel.hasUnread)
                        const PopupMenuItem(
                          value: 'mark_all_read',
                          child: Row(children: [
                            Icon(Icons.done_all, size: 20),
                            SizedBox(width: 12),
                            Text('Mark all as read'),
                          ]),
                        ),
                      const PopupMenuItem(
                        value: 'delete_read',
                        child: Row(children: [
                          Icon(Icons.delete_sweep, size: 20),
                          SizedBox(width: 12),
                          Text('Delete read'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'delete_all',
                        child: Row(children: [
                          Icon(Icons.delete_forever, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete all', style: TextStyle(color: Colors.red)),
                        ]),
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
      return Center(child: CircularProgressIndicator(color: AppTheme.of(context).primary));
    }

    if (viewModel.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: AppTheme.of(context).cadetGrey),
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

    final unread = viewModel.unreadItems;
    final read = viewModel.readItems;

    return RefreshIndicator(
      onRefresh: () => viewModel.loadNotifications(),
      color: AppTheme.of(context).primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (unread.isNotEmpty) ...[
            _buildSectionHeader(context, title: 'New', count: unread.length,
                color: AppTheme.of(context).primary),
            ...unread.map((item) => _buildItem(context, viewModel, item)),
          ],
          if (read.isNotEmpty) ...[
            _buildSectionHeader(context, title: 'Read', count: read.length,
                color: AppTheme.of(context).cadetGrey, isRead: true),
            ...read.map((item) => _buildItem(context, viewModel, item)),
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
          Icon(isRead ? Icons.done_all : Icons.notifications_active, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title,
              style: AppTheme.of(context)
                  .bodyMedium
                  .override(fontWeight: FontWeight.w600, color: color, fontSize: 14)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(count.toString(),
                style: AppTheme.of(context)
                    .bodySmall
                    .override(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    InAppNotificationsViewModel viewModel,
    UnifiedNotificationItem item,
  ) {
    final canDelete = item.source == 'system';
    return Column(
      children: [
        canDelete
            ? Dismissible(
                key: Key('notif_${item.source}_${item.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppTheme.of(context).error,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => viewModel.deleteNotification(item),
                child: _NotificationTile(
                  item: item,
                  onTap: () => _handleTap(context, viewModel, item),
                  onDelete: canDelete ? () => viewModel.deleteNotification(item) : null,
                ),
              )
            : _NotificationTile(
                item: item,
                onTap: () => _handleTap(context, viewModel, item),
                onDelete: null,
              ),
        Divider(height: 1, color: AppTheme.of(context).gray200),
      ],
    );
  }

  void _handleTap(
    BuildContext context,
    InAppNotificationsViewModel viewModel,
    UnifiedNotificationItem item,
  ) async {
    await viewModel.markAsRead(item);

    if (!context.mounted) return;

    if (item.source == 'announcement' && item.id != 0) {
      context.pushNamed(
        AnnouncementViewPage.routeName,
        queryParameters: {'announcementId': item.id.toString()},
      );
    } else if (item.source == 'system' &&
        item.systemNotification?.referenceType == 'experience' &&
        item.systemNotification?.referenceId != null) {
      context.pushNamed(
        ExperienceViewPage.routeName,
        extra: {'experienceId': item.systemNotification!.referenceId},
      );
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
          message: 'Are you sure you want to delete all system notifications? This action cannot be undone.',
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
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: AppTheme.of(context).secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final UnifiedNotificationItem item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _NotificationTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = item.isRead;
    final color = isRead
        ? _tileColor(context).withValues(alpha: 0.4)
        : _tileColor(context);

    return Material(
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
            color: color.withValues(alpha: isRead ? 0.05 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_tileIcon(), color: color, size: 20),
        ),
        title: Opacity(
          opacity: isRead ? 0.6 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.source == 'announcement' && item.groupName != null)
                Text(
                  item.groupName!,
                  style: AppTheme.of(context).bodySmall.override(
                        color: AppTheme.of(context).primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              Text(
                item.title,
                style: AppTheme.of(context).bodySmall.override(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        subtitle: Opacity(
          opacity: isRead ? 0.6 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.message != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.message!,
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
                    _formatDate(item.createdAt),
                    style: AppTheme.of(context).bodyMedium.override(
                          fontSize: 12,
                          color: AppTheme.of(context).cadetGrey,
                        ),
                  ),
                  if (isRead) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.done, size: 14, color: AppTheme.of(context).cadetGrey),
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
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.close, size: 18, color: AppTheme.of(context).cadetGrey),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ),
    );
  }

  IconData _tileIcon() {
    if (item.source == 'announcement') return Icons.campaign_outlined;
    switch (item.systemNotification?.type) {
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

  Color _tileColor(BuildContext context) {
    if (item.source == 'announcement') return AppTheme.of(context).secondary;
    switch (item.systemNotification?.type) {
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
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}
