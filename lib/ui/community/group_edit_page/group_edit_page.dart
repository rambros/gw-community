import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/group_edit_page/view_model/group_edit_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class GroupEditPage extends StatelessWidget {
  final CcGroupsRow groupRow;

  const GroupEditPage({
    super.key,
    required this.groupRow,
  });

  static String routeName = 'groupEditPage';
  static String routePath = '/groupEditPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupEditViewModel(
        context.read<GroupRepository>(),
        groupRow,
      )..init(),
      child: const GroupEditPageView(),
    );
  }
}

class GroupEditPageView extends StatelessWidget {
  const GroupEditPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupEditViewModel>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Edit Group',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(
                    fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                  ),
                  fontSize: 20.0,
                ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: viewModel.isLoading && viewModel.availableManagers.isEmpty
              ? Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: SpinKitRipple(
                      color: AppTheme.of(context).primary,
                      size: 50.0,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                  child: Form(
                    key: viewModel.formKey,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Name Field
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
                              child: TextFormField(
                                controller: viewModel.nameController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: AppTheme.of(context).labelLarge.override(
                                        font: GoogleFonts.poppins(),
                                        color: AppTheme.of(context).primary,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                ),
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.lexendDeca(),
                                      color: AppTheme.of(context).secondary,
                                    ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Field is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Description Field
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
                              child: TextFormField(
                                controller: viewModel.descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  labelStyle: AppTheme.of(context).labelLarge.override(
                                        font: GoogleFonts.poppins(),
                                        color: AppTheme.of(context).primary,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                ),
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.lexendDeca(),
                                      color: AppTheme.of(context).secondary,
                                    ),
                                maxLines: 5,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Field is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Welcome Message Field
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
                              child: TextFormField(
                                controller: viewModel.welcomeMessageController,
                                decoration: InputDecoration(
                                  labelText: 'Welcome message',
                                  labelStyle: AppTheme.of(context).labelLarge.override(
                                        font: GoogleFonts.poppins(),
                                        color: AppTheme.of(context).primary,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                ),
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.lexendDeca(),
                                      color: AppTheme.of(context).secondary,
                                    ),
                                maxLines: 5,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Field is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Policy Message Field
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
                              child: TextFormField(
                                controller: viewModel.policyMessageController,
                                decoration: InputDecoration(
                                  labelText: 'Policy message',
                                  labelStyle: AppTheme.of(context).labelLarge.override(
                                        font: GoogleFonts.poppins(),
                                        color: AppTheme.of(context).primary,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                ),
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.lexendDeca(),
                                      color: AppTheme.of(context).secondary,
                                    ),
                                maxLines: 5,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Field is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Privacy Toggle
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: AppTheme.of(context).alternate,
                                    width: 1.0,
                                  ),
                                ),
                                child: SwitchListTile(
                                  value: viewModel.isPrivate,
                                  onChanged: viewModel.setIsPrivate,
                                  title: Text(
                                    'Private Group',
                                    style: AppTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.lexendDeca(),
                                          color: AppTheme.of(context).secondary,
                                        ),
                                  ),
                                  subtitle: Text(
                                    viewModel.isPrivate ? 'Only members can see content.' : 'Anyone can see content.',
                                    style: AppTheme.of(context).bodySmall.override(
                                          font: GoogleFonts.lexendDeca(),
                                          color: const Color(0xFF57636C),
                                          fontSize: 12.0,
                                        ),
                                  ),
                                  activeColor: AppTheme.of(context).primary,
                                  activeTrackColor: AppTheme.of(context).primary.withValues(alpha: 0.5),
                                  dense: false,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                ),
                              ),
                            ),
                            // Managers Selection
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 8.0),
                                    child: Text(
                                      'Managers / Facilitators (${viewModel.selectedManagerIds.length})',
                                      style: AppTheme.of(context).labelLarge.override(
                                            font: GoogleFonts.poppins(),
                                            color: AppTheme.of(context).primary,
                                          ),
                                    ),
                                  ),
                                  // Selected managers as chips
                                  if (viewModel.selectedManagers.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Wrap(
                                        spacing: 8.0,
                                        runSpacing: 4.0,
                                        children: viewModel.selectedManagers.map((manager) {
                                          final managerId = manager.authUserId ?? manager.id;
                                          return Chip(
                                            avatar: UserAvatar(
                                              imageUrl: manager.photoUrl,
                                              fullName: manager.displayName,
                                              size: 24.0,
                                            ),
                                            label: Text(
                                              manager.displayName ?? 'Unknown',
                                              style: AppTheme.of(context).bodySmall.override(
                                                    font: GoogleFonts.lexendDeca(),
                                                    color: Colors.white,
                                                  ),
                                            ),
                                            backgroundColor: AppTheme.of(context).primary,
                                            deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                                            onDeleted: () => viewModel.toggleManager(managerId, manager),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  // Search field
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search by name or email (min 3 chars)...',
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide(color: AppTheme.of(context).alternate),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide(color: AppTheme.of(context).alternate),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF9FAFB),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    ),
                                    onChanged: viewModel.setManagerSearchQuery,
                                  ),
                                  const SizedBox(height: 8.0),
                                  // Available users list
                                  Container(
                                    width: double.infinity,
                                    height: 300.0,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: AppTheme.of(context).alternate,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: viewModel.filteredManagers.isEmpty
                                        ? Center(
                                            child: Text(
                                              viewModel.managerSearchQuery.isEmpty
                                                  ? 'Search to find users'
                                                  : 'No users found',
                                              style: AppTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.lexendDeca(),
                                                    color: const Color(0xFF57636C),
                                                  ),
                                            ),
                                          )
                                        : ListView.separated(
                                            itemCount: viewModel.filteredManagers.length,
                                            separatorBuilder: (_, __) => const SizedBox(height: 0),
                                            itemBuilder: (context, index) {
                                              final manager = viewModel.filteredManagers[index];
                                              final managerId = manager.authUserId ?? manager.id;
                                              final isSelected = viewModel.selectedManagerIds.contains(managerId);

                                              return InkWell(
                                                onTap: () => viewModel.toggleManager(managerId, manager),
                                                borderRadius: BorderRadius.circular(8),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                  child: Row(
                                                    children: [
                                                      Theme(
                                                        data: Theme.of(context).copyWith(
                                                          unselectedWidgetColor: const Color(0xFF95A1AC),
                                                        ),
                                                        child: Checkbox(
                                                          value: isSelected,
                                                          onChanged: (_) => viewModel.toggleManager(managerId, manager),
                                                          activeColor: AppTheme.of(context).primary,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 12.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                manager.displayName ?? 'Unknown',
                                                                style: AppTheme.of(context).bodyMedium.override(
                                                                      font: GoogleFonts.lexendDeca(),
                                                                      color: AppTheme.of(context).secondary,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                              ),
                                                              if (manager.email != null && manager.email!.isNotEmpty)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 2.0),
                                                                  child: Text(
                                                                    manager.email!,
                                                                    style: AppTheme.of(context).bodySmall.override(
                                                                          font: GoogleFonts.lexendDeca(),
                                                                          color: const Color(0xFF57636C),
                                                                          fontSize: 12.0,
                                                                        ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            // Image Upload
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 8.0),
                                    child: Text(
                                      'Group Image',
                                      style: AppTheme.of(context).labelLarge.override(
                                            font: GoogleFonts.poppins(),
                                            color: AppTheme.of(context).primary,
                                          ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => viewModel.uploadImage(context),
                                    child: Container(
                                      width: 70.0,
                                      height: 70.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: AppTheme.of(context).alternate,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: viewModel.displayImageUrl != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(16.0),
                                              child: CachedNetworkImage(
                                                imageUrl: viewModel.displayImageUrl!,
                                                width: 70.0,
                                                height: 70.0,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Icon(
                                              Icons.add_a_photo,
                                              color: AppTheme.of(context).secondaryText,
                                              size: 24.0,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Save Button
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  final success = await viewModel.updateGroup(context);
                                  if (success) {
                                    if (context.mounted) {
                                      context.pop();
                                    }
                                  }
                                },
                                text: 'Update Group',
                                options: FFButtonOptions(
                                  width: 270.0,
                                  height: 50.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                  color: AppTheme.of(context).primary,
                                  textStyle: AppTheme.of(context).titleSmall.override(
                                        font: GoogleFonts.lexendDeca(),
                                        color: Colors.white,
                                      ),
                                  elevation: 3.0,
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
