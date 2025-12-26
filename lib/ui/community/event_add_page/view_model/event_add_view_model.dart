import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/event_repository.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class EventAddViewModel extends ChangeNotifier {
  EventAddViewModel({
    required EventRepository repository,
    required this.currentUserUid,
    this.groupId,
    this.groupName,
  }) : _repository = repository {
    _initializeDefaults();
  }

  final EventRepository _repository;
  final String currentUserUid;
  final int? groupId;
  final String? groupName;

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final facilitatorController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final durationController = TextEditingController();
  final urlRegistrationController = TextEditingController();

  final titleFocus = FocusNode();
  final facilitatorFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final dateFocus = FocusNode();
  final timeFocus = FocusNode();
  final durationFocus = FocusNode();
  final urlFocus = FocusNode();

  final dateMask = MaskTextInputFormatter(mask: '##/##/##');
  final timeMask = MaskTextInputFormatter(mask: '##:##');
  final durationMask = MaskTextInputFormatter(mask: '###');

  DateTime? _eventDate;
  DateTime? get eventDate => _eventDate;

  DateTime? _eventTime;
  DateTime? get eventTime => _eventTime;

  String _visibility = 'group_only';
  String get visibility => _visibility;

  String _status = 'scheduled';
  String get status => _status;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _initializeDefaults() {
    final now = DateTime.now();
    setEventDate(now);
    setEventTime(now);
  }

  void setVisibility(String? value) {
    if (value == null) return;
    _visibility = value;
    notifyListeners();
  }

  void setStatus(String? value) {
    if (value == null) return;
    _status = value;
    notifyListeners();
  }

  void setEventDate(DateTime date, {String? locale}) {
    _eventDate = date;
    dateController.text = dateTimeFormat(
      'd/M/y',
      date,
      locale: locale,
    );
    notifyListeners();
  }

  void setEventTime(DateTime time, {String? locale}) {
    _eventTime = time;
    timeController.text = dateTimeFormat(
      'Hm',
      time,
      locale: locale,
    );
    notifyListeners();
  }

  bool validateForm() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _setError('Please fill in all required fields.');
    } else {
      _clearError();
    }
    return isValid;
  }

  Future<bool> saveEvent() async {
    if (!validateForm()) {
      return false;
    }

    if (_eventDate == null || _eventTime == null) {
      _setError('Please select date and time for the event.');
      return false;
    }

    final duration = int.tryParse(durationController.text.trim());
    if (duration == null) {
      _setError('Invalid duration value.');
      return false;
    }

    _setSaving(true);
    _clearError();

    try {
      await _repository.createEvent(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        facilitatorName: facilitatorController.text.trim(),
        facilitatorId: currentUserUid,
        eventDate: _eventDate!,
        eventTime: _eventTime!,
        durationMinutes: duration,
        status: _status,
        visibility: _visibility,
        registrationUrl: urlRegistrationController.text.trim().isEmpty
            ? null
            : urlRegistrationController.text.trim(),
        groupId: groupId,
      );
      return true;
    } catch (e) {
      _setError('Error creating event: $e');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    titleController.dispose();
    facilitatorController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    durationController.dispose();
    urlRegistrationController.dispose();

    titleFocus.dispose();
    facilitatorFocus.dispose();
    descriptionFocus.dispose();
    dateFocus.dispose();
    timeFocus.dispose();
    durationFocus.dispose();
    urlFocus.dispose();
    super.dispose();
  }
}
