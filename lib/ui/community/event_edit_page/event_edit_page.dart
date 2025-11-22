import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/data/services/supabase/supabase.dart';
import '/ui/core/ui/flutter_flow_drop_down.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/ui/core/themes/app_theme.dart';
import '/utils/flutter_flow_util.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/ui/core/ui/form_field_controller.dart';
import '/index.dart';
import '/data/repositories/event_repository.dart';
import '/utils/context_extensions.dart';
import 'view_model/event_edit_view_model.dart';

class EventEditPage extends StatefulWidget {
  const EventEditPage({
    super.key,
    required this.eventRow,
  });

  final CcEventsRow? eventRow;

  static String routeName = 'eventEditPage';
  static String routePath = '/eventEditPage';

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  EventEditViewModel? viewModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (viewModel == null && widget.eventRow != null) {
      viewModel = EventEditViewModel(
        repository: context.read<EventRepository>(),
        currentUserUid: context.currentUserIdOrEmpty,
        event: widget.eventRow!,
      );
    }
  }

  @override
  void dispose() {
    viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  'Edit Event',
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
                  child: _EventEditForm(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EventEditForm extends StatefulWidget {
  const _EventEditForm();

  @override
  State<_EventEditForm> createState() => _EventEditFormState();
}

class _EventEditFormState extends State<_EventEditForm> {
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventEditViewModel>();
    final visibilityController = FormFieldController<String>(vm.visibility);
    final statusController = FormFieldController<String>(vm.status);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.of(context).primaryBackground,
      child: Form(
        key: vm.formKey,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(context, vm.titleController, vm.titleFocus, 'Title'),
                _buildTextField(context, vm.facilitatorController, vm.facilitatorFocus, 'Facilitator'),
                _buildTextField(
                  context,
                  vm.descriptionController,
                  vm.descriptionFocus,
                  'Description',
                  maxLines: 6,
                ),
                _buildDateField(context, vm),
                _buildTimeField(context, vm),
                _buildTextField(
                  context,
                  vm.durationController,
                  vm.durationFocus,
                  'Duration (minutes)',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  context,
                  vm.urlRegistrationController,
                  vm.urlFocus,
                  'Registration URL (optional)',
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
                  child: FlutterFlowDropDown<String>(
                    controller: visibilityController,
                    options: const ['group_only', 'everyone'],
                    optionLabels: const ['Only this group', 'Everyone'],
                    onChanged: vm.setVisibility,
                    textStyle: AppTheme.of(context).bodyMedium,
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
                      _buildCancelButton(context, vm),
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

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: _requiredValidator,
        decoration: InputDecoration(
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
        ),
        style: AppTheme.of(context).bodyMedium,
      ),
    );
  }

  Widget _buildDateField(BuildContext context, EventEditViewModel vm) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: vm.dateController,
              focusNode: vm.dateFocus,
              readOnly: true,
              validator: _requiredValidator,
              decoration: _dateTimeDecoration(context, 'Date'),
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

  Widget _buildTimeField(BuildContext context, EventEditViewModel vm) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: vm.timeController,
              focusNode: vm.timeFocus,
              readOnly: true,
              validator: _requiredValidator,
              decoration: _dateTimeDecoration(context, 'Time'),
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

  Widget _buildCancelButton(BuildContext context, EventEditViewModel vm) {
    return FFButtonWidget(
      onPressed: () {
        vm.resetForm();
        context.safePop();
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

  Widget _buildSaveButton(BuildContext context, EventEditViewModel vm) {
    return FFButtonWidget(
      onPressed: vm.isSaving
          ? null
          : () async {
              final success = await vm.saveEvent();
              if (!success || !context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Event updated with success',
                    style: TextStyle(color: AppTheme.of(context).primaryText),
                  ),
                  backgroundColor: AppTheme.of(context).secondary,
                ),
              );
              context.pushNamed(
                EventDetailsPage.routeName,
                queryParameters: {
                  'eventRow': serializeParam(
                    vm.event,
                    ParamType.SupabaseRow,
                  ),
                  'groupId': serializeParam(
                    vm.event.groupId,
                    ParamType.int,
                  ),
                }.withoutNulls,
              );
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
