import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/ui/community/group_details_page/view_model/group_details_view_model.dart';
import 'package:gw_community/ui/community/group_details_page/widgets/resource_card_widget.dart';
import 'package:gw_community/ui/community/group_details_page/widgets/resource_form_sheet.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:provider/provider.dart';

class GroupResourcesTab extends StatelessWidget {
  const GroupResourcesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupDetailsViewModel>();
    final canManage = viewModel.currentUserIsGroupManager ||
        (viewModel.isMember && _isAdminUser(context, viewModel));

    return Stack(
      children: [
        _buildContent(context, viewModel, canManage),
        if (canManage)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => _showAddResource(context, viewModel),
              backgroundColor: AppTheme.of(context).primary,
              elevation: 8.0,
              icon: Icon(
                Icons.add,
                color: AppTheme.of(context).primaryBackground,
              ),
              label: Text(
                'New resource',
                style: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(),
                      color: AppTheme.of(context).primaryBackground,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    GroupDetailsViewModel viewModel,
    bool canManage,
  ) {
    if (viewModel.isLoadingResources) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.of(context).primary),
      );
    }

    final resources = viewModel.groupFileResources;

    if (resources.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                canManage
                    ? 'No resources yet.\nTap + to add the first one.'
                    : 'No resources available yet.',
                style: GoogleFonts.lexendDeca(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadFileResources,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 16, 16, canManage ? 80 : 16),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];
          final portalItemId = resource.portalItemId;
          return ResourceCardWidget(
            resource: resource,
            isAdminOrManager: canManage,
            onToggleStatus: () => viewModel.toggleFileResourceStatus(
              resource.id,
              resource.status,
            ),
            onDelete: () => viewModel.deleteFileResource(resource.id),
            onUnlink: (canManage && portalItemId != null)
                ? () => viewModel.unlinkFileResource(resource.id, portalItemId)
                : null,
            onSaved: viewModel.loadFileResources,
          );
        },
      ),
    );
  }

  bool _isAdminUser(BuildContext context, GroupDetailsViewModel viewModel) {
    return FFAppState().loginUser.roles.hasAdminOrGroupManager;
  }

  void _showAddResource(BuildContext context, GroupDetailsViewModel viewModel) {
    if (viewModel.currentUserId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResourceFormSheet(
        groupId: viewModel.group.id,
        currentUserId: viewModel.currentUserId!,
        onSaved: viewModel.loadFileResources,
      ),
    );
  }
}
