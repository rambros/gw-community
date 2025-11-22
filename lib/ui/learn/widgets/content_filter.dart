import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_animations.dart';
import '/ui/core/ui/flutter_flow_drop_down.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/ui/core/ui/form_field_controller.dart';
import '/ui/learn/learn_list_page/view_model/learn_list_view_model.dart';

class ContentFilter extends StatefulWidget {
  const ContentFilter({super.key});

  @override
  State<ContentFilter> createState() => _ContentFilterState();
}

class _ContentFilterState extends State<ContentFilter> with TickerProviderStateMixin {
  final animationsMap = <String, AnimationInfo>{};
  bool _hasSyncedFilters = false;
  int _selectedAuthorId = 0;
  int _selectedEventId = 0;
  String _selectedYear = '';
  int _selectedJourneyId = 0;
  int _selectedGroupId = 0;
  List<String> _selectedTopics = [];
  FormFieldController<int>? _authorController;
  FormFieldController<int>? _eventController;
  FormFieldController<String>? _yearController;
  FormFieldController<int>? _journeyController;
  FormFieldController<int>? _groupController;
  FormListFieldController<String>? _topicsController;

  void _clearAuthor() {
    setState(() {
      _selectedAuthorId = 0;
      _authorController?.value = null;
    });
  }

  void _clearEvent() {
    setState(() {
      _selectedEventId = 0;
      _eventController?.value = null;
    });
  }

  void _clearYear() {
    setState(() {
      _selectedYear = '';
      _yearController?.value = null;
    });
  }

  void _clearJourney() {
    setState(() {
      _selectedJourneyId = 0;
      _journeyController?.value = null;
    });
  }

  void _clearGroup() {
    setState(() {
      _selectedGroupId = 0;
      _groupController?.value = null;
    });
  }

  void _clearTopics() {
    setState(() {
      _selectedTopics = [];
      _topicsController?.value = [];
    });
  }

  void _syncSelections(LearnListViewModel viewModel) {
    if (_hasSyncedFilters) {
      return;
    }

    _selectedAuthorId = viewModel.filterByAuthorId;
    _selectedEventId = viewModel.filterByEventId;
    _selectedYear = viewModel.filterByYear;
    _selectedJourneyId = viewModel.filterByJourneyId;
    _selectedGroupId = viewModel.filterByGroupId;
    _selectedTopics = List<String>.from(viewModel.filterByTopics);

    _authorController = FormFieldController<int>(_selectedAuthorId == 0 ? null : _selectedAuthorId);
    _eventController = FormFieldController<int>(_selectedEventId == 0 ? null : _selectedEventId);
    _yearController = FormFieldController<String>(_selectedYear.isEmpty ? null : _selectedYear);
    _journeyController = FormFieldController<int>(_selectedJourneyId == 0 ? null : _selectedJourneyId);
    _groupController = FormFieldController<int>(_selectedGroupId == 0 ? null : _selectedGroupId);
    _topicsController = FormListFieldController<String>(List<String>.from(_selectedTopics));

    _hasSyncedFilters = true;
  }

  Future<void> _applyFilters(BuildContext context, LearnListViewModel viewModel) async {
    await viewModel.applyFilters(
      authorId: _selectedAuthorId,
      year: _selectedYear,
      eventId: _selectedEventId,
      topics: _selectedTopics,
      journeyId: _selectedJourneyId,
      groupId: _selectedGroupId,
    );
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  void _cancel(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 300.ms),
          MoveEffect(
            curve: Curves.bounceOut,
            delay: 300.0.ms,
            duration: 400.0.ms,
            begin: const Offset(0.0, 100.0),
            end: const Offset(0.0, 0.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _authorController?.dispose();
    _eventController?.dispose();
    _yearController?.dispose();
    _journeyController?.dispose();
    _groupController?.dispose();
    _topicsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _cancel(context),
      child: Consumer<LearnListViewModel>(
        builder: (context, viewModel, child) {
          _syncSelections(viewModel);
          final authors = viewModel.authors.where((author) => author.id != null).toList();
          final events = viewModel.events.where((event) => event.eventId != null).toList();
          final years = viewModel.years.where((year) => year.year != null).toList();
          final journeys = viewModel.journeys;
          final groups = viewModel.groups;
          final topics = viewModel.topics.where((topic) => (topic.topicName ?? '').isNotEmpty).toList();
          final topicNames = topics.map((topic) => topic.topicName ?? '').toList();
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryBackground.withValues(alpha: 0.82),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 2.0, 16.0, 16.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 600.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).secondaryBackground,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 12.0,
                            color: Color(0x1E000000),
                            offset: Offset(0.0, 5.0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                              child: Text(
                                'Content Filter',
                                style: AppTheme.of(context).headlineMedium,
                              ),
                            ),
                            // Author Dropdown
                            _buildLabel(
                              context,
                              'Author',
                              hasValue: _selectedAuthorId != 0,
                              onClear: _clearAuthor,
                            ),
                            FlutterFlowDropDown<int>(
                              controller: _authorController,
                              options: authors.map((e) => e.id!).toList(),
                              optionLabels: authors.map((e) => e.name ?? 'Author').toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedAuthorId = val ?? 0;
                                });
                              },
                              width: double.infinity,
                              height: 50.0,
                              textStyle: AppTheme.of(context).bodyMedium,
                              hintText: 'Select Author',
                              searchHintText: 'Search for an author...',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              fillColor: AppTheme.of(context).secondaryBackground,
                              elevation: 2.0,
                              borderColor: AppTheme.of(context).alternate,
                              borderWidth: 2.0,
                              borderRadius: 12.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                              hidesUnderline: true,
                              isOverButton: true,
                              isSearchable: true,
                            ),

                            // Event Dropdown
                            _buildLabel(
                              context,
                              'Event',
                              hasValue: _selectedEventId != 0,
                              onClear: _clearEvent,
                            ),
                            FlutterFlowDropDown<int>(
                              controller: _eventController,
                              options: events.map((e) => e.eventId!).toList(),
                              optionLabels: events.map((e) => e.eventName ?? 'Event').toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedEventId = val ?? 0;
                                });
                              },
                              width: double.infinity,
                              height: 50.0,
                              textStyle: AppTheme.of(context).bodyMedium,
                              hintText: 'Select Event',
                              searchHintText: 'Search for an event...',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              fillColor: AppTheme.of(context).secondaryBackground,
                              elevation: 2.0,
                              borderColor: AppTheme.of(context).alternate,
                              borderWidth: 2.0,
                              borderRadius: 12.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                              hidesUnderline: true,
                              isOverButton: true,
                              isSearchable: true,
                            ),

                            // Year Dropdown
                            _buildLabel(
                              context,
                              'Year',
                              hasValue: _selectedYear.isNotEmpty,
                              onClear: _clearYear,
                            ),
                            FlutterFlowDropDown<String>(
                              controller: _yearController,
                              options: years.map((e) => e.year!.toInt().toString()).toList(),
                              optionLabels: years.map((e) => e.year!.toInt().toString()).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedYear = val ?? '';
                                });
                              },
                              width: double.infinity,
                              height: 50.0,
                              textStyle: AppTheme.of(context).bodyMedium,
                              hintText: 'Select Year',
                              searchHintText: 'Search for a year...',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              fillColor: AppTheme.of(context).secondaryBackground,
                              elevation: 2.0,
                              borderColor: AppTheme.of(context).alternate,
                              borderWidth: 2.0,
                              borderRadius: 12.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                              hidesUnderline: true,
                              isOverButton: true,
                              isSearchable: true,
                            ),

                            // Journeys Dropdown
                            _buildLabel(
                              context,
                              'Journeys',
                              hasValue: _selectedJourneyId != 0,
                              onClear: _clearJourney,
                            ),
                            FlutterFlowDropDown<int>(
                              controller: _journeyController,
                              options: journeys.map((e) => e.id).toList(),
                              optionLabels: journeys.map((e) => e.title ?? 'Journey').toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedJourneyId = val ?? 0;
                                });
                              },
                              width: double.infinity,
                              height: 50.0,
                              textStyle: AppTheme.of(context).bodyMedium,
                              hintText: 'Select Journey',
                              searchHintText: 'Search for a journey...',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              fillColor: AppTheme.of(context).secondaryBackground,
                              elevation: 2.0,
                              borderColor: AppTheme.of(context).alternate,
                              borderWidth: 2.0,
                              borderRadius: 12.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                              hidesUnderline: true,
                              isOverButton: true,
                              isSearchable: true,
                            ),

                            // Groups Dropdown
                            _buildLabel(
                              context,
                              'Groups',
                              hasValue: _selectedGroupId != 0,
                              onClear: _clearGroup,
                            ),
                            FlutterFlowDropDown<int>(
                              controller: _groupController,
                              options: groups.map((e) => e.id).toList(),
                              optionLabels: groups.map((e) => e.name ?? 'Group').toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedGroupId = val ?? 0;
                                });
                              },
                              width: double.infinity,
                              height: 50.0,
                              textStyle: AppTheme.of(context).bodyMedium,
                              hintText: 'Select Group',
                              searchHintText: 'Search for a group...',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              fillColor: AppTheme.of(context).secondaryBackground,
                              elevation: 2.0,
                              borderColor: AppTheme.of(context).alternate,
                              borderWidth: 2.0,
                              borderRadius: 12.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                              hidesUnderline: true,
                              isOverButton: true,
                              isSearchable: true,
                            ),

                            // Topics Dropdown
                            _buildLabel(
                              context,
                              'Topics',
                              hasValue: _selectedTopics.isNotEmpty,
                              onClear: _clearTopics,
                            ),
                            FlutterFlowDropDown<String>(
                              multiSelectController: _topicsController,
                              options: topicNames,
                              optionLabels: topicNames,
                              onMultiSelectChanged: (val) {
                                setState(() {
                                  _selectedTopics = List<String>.from(val ?? []);
                                });
                              },
                              width: double.infinity,
                              height: 50.0,
                              textStyle: AppTheme.of(context).bodyMedium,
                              hintText: 'Select Topics',
                              searchHintText: 'Search for topics...',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              fillColor: AppTheme.of(context).secondaryBackground,
                              elevation: 2.0,
                              borderColor: AppTheme.of(context).alternate,
                              borderWidth: 2.0,
                              borderRadius: 12.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                              hidesUnderline: true,
                              isOverButton: true,
                              isSearchable: true,
                              isMultiSelect: true,
                            ),

                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FFButtonWidget(
                                    onPressed: () => _cancel(context),
                                    text: 'Cancel',
                                    options: FFButtonOptions(
                                      height: 40.0,
                                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                      color: AppTheme.of(context).secondaryBackground,
                                      textStyle: AppTheme.of(context).labelLarge.override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                              fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                            ),
                                            color: AppTheme.of(context).primary,
                                          ),
                                      elevation: 0.0,
                                      borderSide: BorderSide(
                                        color: AppTheme.of(context).secondaryBackground,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  FFButtonWidget(
                                    onPressed: () => _applyFilters(context, viewModel),
                                    text: 'Apply Filter',
                                    options: FFButtonOptions(
                                      height: 44.0,
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(
    BuildContext context,
    String label, {
    bool hasValue = false,
    VoidCallback? onClear,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(
                    fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: AppTheme.of(context).primary,
                ),
          ),
          if (hasValue && onClear != null)
            IconButton(
              onPressed: onClear,
              icon: Icon(Icons.close, color: AppTheme.of(context).primary, size: 18.0),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 16.0,
              tooltip: 'Clear $label filter',
            ),
        ],
      ),
    );
  }
}
