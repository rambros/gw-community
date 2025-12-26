import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/data/repositories/event_repository.dart';
import '/index.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_drop_down.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/ui/core/ui/form_field_controller.dart';
import '/utils/context_extensions.dart';
import '/utils/flutter_flow_util.dart';
import 'view_model/event_add_view_model.dart';

class EventAddPage extends StatefulWidget {
  const EventAddPage({
    super.key,
    this.groupId,
    this.groupName,
  });

  final int? groupId;
  final String? groupName;

  static String routeName = 'EventAddPage';
  static String routePath = '/eventAddPage';

  @override
  State<EventAddPage> createState() => _EventAddPageState();
}

class _EventAddPageState extends State<EventAddPage> {
  late EventAddViewModel viewModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'eventAddPage'});
    viewModel = EventAddViewModel(
      repository: context.read<EventRepository>(),
      currentUserUid: context.currentUserIdOrEmpty,
      groupId: widget.groupId,
      groupName: widget.groupName,
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
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
                  'New Event',
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
                centerTitle: true,
                elevation: 2.0,
              ),
              body: const SafeArea(
                top: true,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                  child: _EventAddPageForm(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EventAddPageForm extends StatefulWidget {
  const _EventAddPageForm();

  @override
  State<_EventAddPageForm> createState() => _EventAddPageFormState();
}

class _EventAddPageFormState extends State<_EventAddPageForm> {
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventAddViewModel>();
    final visibilityController = FormFieldController<String>(vm.visibility);
    final statusController = FormFieldController<String>(vm.status);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.of(context).primaryBackground,
      child: Form(
        key: vm.formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  context: context,
                  controller: vm.titleController,
                  focusNode: vm.titleFocus,
                  label: 'Title',
                  validator: _requiredValidator,
                ),
                _buildTextField(
                  context: context,
                  controller: vm.facilitatorController,
                  focusNode: vm.facilitatorFocus,
                  label: 'Facilitator',
                  validator: _requiredValidator,
                ),
                _buildTextField(
                  context: context,
                  controller: vm.descriptionController,
                  focusNode: vm.descriptionFocus,
                  label: 'Description',
                  maxLines: 6,
                  validator: _requiredValidator,
                ),
                _buildDateField(context, vm),
                _buildTimeField(context, vm),
                _buildTextField(
                  context: context,
                  controller: vm.durationController,
                  focusNode: vm.durationFocus,
                  label: 'Duration (minutes)',
                  keyboardType: TextInputType.number,
                  validator: _requiredValidator,
                ),
                _buildTextField(
                  context: context,
                  controller: vm.urlRegistrationController,
                  focusNode: vm.urlFocus,
                  label: 'Registration URL (optional)',
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
                  child: FlutterFlowDropDown<String>(
                    controller: visibilityController,
                    options: const ['group_only', 'everyone'],
                    optionLabels: const ['Only this group', 'Everyone'],
                    onChanged: vm.setVisibility,
                    textStyle: AppTheme.of(context).bodyMedium,
                    hintText: 'Visibility',
                    fillColor: AppTheme.of(context).primaryBackground,
                    elevation: 2.0,
                    borderColor: AppTheme.of(context).alternate,
                    borderWidth: 1.0,
                    borderRadius: 16.0,
                    margin: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
                  child: FlutterFlowDropDown<String>(
                    controller: statusController,
                    options: const ['scheduled', 'recorded'],
                    optionLabels: const ['Scheduled', 'Recorded'],
                    onChanged: vm.setStatus,
                    textStyle: AppTheme.of(context).bodyMedium,
                    hintText: 'Status',
                    fillColor: AppTheme.of(context).primaryBackground,
                    elevation: 2.0,
                    borderColor: AppTheme.of(context).alternate,
                    borderWidth: 1.0,
                    borderRadius: 16.0,
                    margin: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                  ),
                ),
                if (vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 0.0),
                    child: Text(
                      vm.errorMessage!,
                      style: AppTheme.of(context).labelMedium.copyWith(
                            color: AppTheme.of(context).error,
                          ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildCancelButton(context),
                      const SizedBox(width: 12.0),
                      _buildSaveButton(context, vm),
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

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.of(context).labelLarge.override(
                font: GoogleFonts.poppins(
                  fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                  fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                ),
                color: AppTheme.of(context).primary,
                fontSize: 16.0,
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
              color: AppTheme.of(context).primary,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        style: AppTheme.of(context).bodyMedium,
      ),
    );
  }

  Widget _buildDateField(BuildContext context, EventAddViewModel vm) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: vm.dateController,
              focusNode: vm.dateFocus,
              readOnly: true,
              decoration: _dateTimeDecoration(context, 'Date'),
              validator: _requiredValidator,
            ),
          ),
          const SizedBox(width: 8.0),
          FFButtonWidget(
            onPressed: () async {
              final locale = FFLocalizations.of(context).languageCode;
              final picked = await showDatePicker(
                context: context,
                initialDate: vm.eventDate ?? getCurrentTimestamp,
                firstDate: DateTime(1900),
                lastDate: DateTime(2050),
              );
              if (picked != null) {
                vm.setEventDate(
                  DateTime(picked.year, picked.month, picked.day),
                  locale: locale,
                );
              }
            },
            text: 'Select date',
            options: _pickerButtonOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField(BuildContext context, EventAddViewModel vm) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: vm.timeController,
              focusNode: vm.timeFocus,
              readOnly: true,
              decoration: _dateTimeDecoration(context, 'Time'),
              validator: _requiredValidator,
            ),
          ),
          const SizedBox(width: 8.0),
          FFButtonWidget(
            onPressed: () async {
              final locale = FFLocalizations.of(context).languageCode;
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(vm.eventTime ?? getCurrentTimestamp),
              );
              if (picked != null) {
                final now = DateTime.now();
                vm.setEventTime(
                  DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
                  locale: locale,
                );
              }
            },
            text: 'Select time',
            options: _pickerButtonOptions(context),
          ),
        ],
      ),
    );
  }

  InputDecoration _dateTimeDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTheme.of(context).labelLarge.override(
            font: GoogleFonts.poppins(
              fontWeight: AppTheme.of(context).labelLarge.fontWeight,
              fontStyle: AppTheme.of(context).labelLarge.fontStyle,
            ),
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
          color: AppTheme.of(context).primary,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
    );
  }

  FFButtonOptions _pickerButtonOptions(BuildContext context) {
    return FFButtonOptions(
      height: 40.0,
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
      color: AppTheme.of(context).primary,
      textStyle: AppTheme.of(context).labelLarge.override(
            font: GoogleFonts.poppins(
              fontWeight: AppTheme.of(context).labelLarge.fontWeight,
              fontStyle: AppTheme.of(context).labelLarge.fontStyle,
            ),
            color: AppTheme.of(context).primaryBackground,
          ),
      elevation: 1.0,
      borderSide: BorderSide(
        color: AppTheme.of(context).secondaryBackground,
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(20.0),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return FFButtonWidget(
      onPressed: () async {
        context.pushNamed(CommunityPage.routeName);
      },
      text: 'Cancel',
      options: FFButtonOptions(
        height: 40.0,
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
        color: AppTheme.of(context).primaryBackground,
        textStyle: AppTheme.of(context).labelLarge.override(
              font: GoogleFonts.poppins(
                fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                fontStyle: AppTheme.of(context).labelLarge.fontStyle,
              ),
              color: AppTheme.of(context).secondary,
            ),
        elevation: 0.0,
        borderSide: BorderSide(
          color: AppTheme.of(context).secondaryBackground,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, EventAddViewModel vm) {
    return FFButtonWidget(
      onPressed: vm.isSaving
          ? null
          : () async {
              final success = await vm.saveEvent();
              if (!success || !context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Event created with success',
                    style: TextStyle(color: AppTheme.of(context).primaryText),
                  ),
                  backgroundColor: AppTheme.of(context).secondary,
                ),
              );
              context.pushNamed(CommunityPage.routeName);
            },
      text: vm.isSaving ? 'Saving...' : 'Save Event',
      options: FFButtonOptions(
        height: 40.0,
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
        color: AppTheme.of(context).primary,
        textStyle: AppTheme.of(context).labelLarge.override(
              font: GoogleFonts.poppins(
                fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                fontStyle: AppTheme.of(context).labelLarge.fontStyle,
              ),
              color: AppTheme.of(context).primaryBackground,
            ),
        elevation: 1.0,
        borderSide: BorderSide(
          color: AppTheme.of(context).secondaryBackground,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }
}
