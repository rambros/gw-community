import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/ui/core/themes/app_theme.dart';
import '/utils/flutter_flow_util.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/ui/core/ui/flutter_flow_drop_down.dart';
import '/ui/core/ui/form_field_controller.dart';
import '/data/repositories/group_repository.dart';
import '/utils/context_extensions.dart';
import 'view_model/group_add_view_model.dart';

class GroupAddPage extends StatelessWidget {
  const GroupAddPage({super.key});

  static String routeName = 'groupAddPage';
  static String routePath = '/groupAddPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupAddViewModel(
        context.read<GroupRepository>(),
        currentUserUid: context.currentUserIdOrEmpty,
      )..init(),
      child: const GroupAddPageView(),
    );
  }
}

class GroupAddPageView extends StatelessWidget {
  const GroupAddPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupAddViewModel>();

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
            'New Group',
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
                            // Managers Dropdown
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    'Group managers',
                                    textAlign: TextAlign.start,
                                    style: AppTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.lexendDeca(),
                                          color: AppTheme.of(context).secondary,
                                          fontSize: 16.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 8.0),
                                child: FlutterFlowDropDown<String>(
                                  multiSelectController: FormListFieldController<String>(viewModel.selectedManagerIds),
                                  options: viewModel.availableManagers.map((e) => e.id).toList(),
                                  optionLabels: viewModel.availableManagers.map((e) => e.displayName ?? 'Unknown').toList(),
                                  onMultiSelectChanged: (val) => viewModel.setSelectedManagers(val),
                                  width: double.infinity,
                                  height: 50.0,
                                  textStyle: AppTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.lexendDeca(),
                                        color: AppTheme.of(context).secondary,
                                      ),
                                  hintText: 'Select Managers/ facilitators',
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppTheme.of(context).secondaryText,
                                    size: 24.0,
                                  ),
                                  fillColor: AppTheme.of(context).primaryBackground,
                                  elevation: 2.0,
                                  borderColor: Colors.transparent,
                                  borderWidth: 0.0,
                                  borderRadius: 8.0,
                                  margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                                  hidesUnderline: true,
                                  isOverButton: false,
                                  isSearchable: true,
                                  isMultiSelect: true,
                                ),
                              ),
                            ),
                            // Image Upload
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                              child: Container(
                                width: double.infinity,
                                height: MediaQuery.sizeOf(context).height * 0.32,
                                decoration: BoxDecoration(
                                  color: AppTheme.of(context).primaryBackground,
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        onTap: () => viewModel.uploadImage(context),
                                        child: Container(
                                          width: 100.0,
                                          height: 100.0,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEEEEE),
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                          child: viewModel.uploadedImageUrl != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(16.0),
                                                  child: CachedNetworkImage(
                                                    imageUrl: viewModel.uploadedImageUrl!,
                                                    width: 100.0,
                                                    height: 100.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.add_a_photo,
                                                      color: AppTheme.of(context).secondaryText,
                                                      size: 32.0,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                      child: Text(
                                                        'Upload Image',
                                                        style: AppTheme.of(context).bodySmall,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Save Button
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  final success = await viewModel.saveGroup(context);
                                  if (success) {
                                    if (context.mounted) {
                                      context.pop();
                                    }
                                  }
                                },
                                text: 'Create Group',
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
