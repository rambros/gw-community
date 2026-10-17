import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/event_repository.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/event_recurrence.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:gw_community/utils/upload_data.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class EventAddViewModel extends ChangeNotifier {
  EventAddViewModel({
    required EventRepository repository,
    required GroupRepository groupRepository,
    required this.currentUserUid,
    this.groupId,
    this.groupName,
  })  : _repository = repository,
        _groupRepository = groupRepository {
    _initializeDefaults();
    _loadGroupImage();
  }

  final EventRepository _repository;
  final GroupRepository _groupRepository;
  final String currentUserUid;
  final int? groupId;
  final String? groupName;

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final facilitatorController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final endDateController = TextEditingController();
  final timeController = TextEditingController();
  final durationController = TextEditingController();
  final urlRegistrationController = TextEditingController();

  final titleFocus = FocusNode();
  final facilitatorFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final dateFocus = FocusNode();
  final endDateFocus = FocusNode();
  final timeFocus = FocusNode();
  final durationFocus = FocusNode();
  final urlFocus = FocusNode();

  final dateMask = MaskTextInputFormatter(mask: '##/##/##');
  final timeMask = MaskTextInputFormatter(mask: '##:##');
  final durationMask = MaskTextInputFormatter(mask: '###');

  DateTime? _eventDate;
  DateTime? get eventDate => _eventDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  DateTime? _eventTime;
  DateTime? get eventTime => _eventTime;

  String _visibility = 'group_only';
  String get visibility => _visibility;

  String _status = 'scheduled';
  String get status => _status;

  String _eventType = 'single_day';
  String get eventType => _eventType;

  String _recurrence = EventRecurrence.none;
  String get recurrence => _recurrence;

  DateTime? _recurrenceUntil;
  DateTime? get recurrenceUntil => _recurrenceUntil;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _groupImageUrl;
  String? get groupImageUrl => _groupImageUrl;

  String? _uploadedImageUrl;
  String? get uploadedImageUrl => _uploadedImageUrl;

  bool _disposed = false;

  /// Custom upload wins. Otherwise the group's own image is the header.
  String? get displayImageUrl {
    final uploaded = _uploadedImageUrl?.trim();
    if (uploaded != null && uploaded.isNotEmpty) return uploaded;
    final groupImage = _groupImageUrl?.trim();
    if (groupImage != null && groupImage.isNotEmpty) return groupImage;
    return null;
  }

  bool get hasCustomImage {
    final uploaded = _uploadedImageUrl?.trim();
    return uploaded != null && uploaded.isNotEmpty;
  }

  bool get isUsingGroupImage => !hasCustomImage && displayImageUrl != null;

  void _initializeDefaults() {
    final now = DateTime.now();
    setEventDate(now);
    setEndDate(now);
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

  void setEventType(String? value) {
    if (value == null) return;
    _eventType = value;
    notifyListeners();
  }

  void setRecurrence(String? value) {
    if (value == null) return;
    _recurrence = value;
    if (!EventRecurrence.repeats(value)) {
      _recurrenceUntil = null;
    }
    notifyListeners();
  }

  void setRecurrenceUntil(DateTime? date) {
    _recurrenceUntil = date == null ? null : DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  Future<void> _loadGroupImage() async {
    if (groupId == null) return;
    try {
      final group = await _groupRepository.getGroupById(groupId!);
      if (_disposed) return;
      _groupImageUrl = group?.groupImageUrl;
      notifyListeners();
    } catch (_) {
      // The form still works without a default header.
    }
  }

  void useGroupImage() {
    _uploadedImageUrl = null;
    notifyListeners();
  }

  Future<void> uploadImage(BuildContext context) async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      storageFolderPath: 'events',
      maxWidth: 800.00,
      maxHeight: 800.00,
      allowPhoto: true,
      includeBlurHash: true,
    );

    if (selectedMedia != null && selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
      if (!context.mounted) return;
      _setSaving(true);
      try {
        showUploadMessage(context, 'Uploading file...', showLoading: true);

        final downloadUrls = await uploadSupabaseStorageFiles(
          bucketName: 'portal',
          selectedFiles: selectedMedia,
        );

        if (downloadUrls.isNotEmpty) {
          _uploadedImageUrl = downloadUrls.first;
          notifyListeners();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
        }
      } finally {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
        _setSaving(false);
      }
    }
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

  void setEndDate(DateTime date, {String? locale}) {
    _endDate = date;
    endDateController.text = dateTimeFormat(
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
    if (viewAsBlocksWrite()) return false;
    if (!validateForm()) {
      return false;
    }

    if (_eventDate == null) {
      _setError('Please select date for the event.');
      return false;
    }

    DateTime? finalEventTime = _eventTime;
    int? duration;
    DateTime? finalEndDate = _endDate;

    if (_eventType == 'single_day') {
      if (_eventTime == null) {
        _setError('Please select time for the event.');
        return false;
      }
      duration = int.tryParse(durationController.text.trim());
      if (duration == null) {
        _setError('Invalid duration value.');
        return false;
      }
      finalEndDate = null;
    } else {
      // multi_day
      if (_endDate == null) {
        _setError('Please select end date for the event.');
        return false;
      }
      if (_endDate!.isBefore(_eventDate!)) {
        _setError('End date cannot be before start date.');
        return false;
      }
      finalEventTime = null;
      duration = null;
    }

    if (_recurrenceUntil != null && _recurrenceUntil!.isBefore(_eventDate!)) {
      _setError('Repeat until cannot be before the first date.');
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
        eventTime: finalEventTime,
        durationMinutes: duration,
        status: _status,
        visibility: _visibility,
        registrationUrl: urlRegistrationController.text.trim().isEmpty
            ? null
            : urlRegistrationController.text.trim(),
        groupId: groupId,
        endDate: finalEndDate,
        eventType: _eventType,
        imageUrl: hasCustomImage ? _uploadedImageUrl : null,
        recurrence: EventRecurrence.repeats(_recurrence) ? _recurrence : null,
        recurrenceUntil: EventRecurrence.repeats(_recurrence) ? _recurrenceUntil : null,
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
    _disposed = true;
    titleController.dispose();
    facilitatorController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    endDateController.dispose();
    timeController.dispose();
    durationController.dispose();
    urlRegistrationController.dispose();

    titleFocus.dispose();
    facilitatorFocus.dispose();
    descriptionFocus.dispose();
    dateFocus.dispose();
    endDateFocus.dispose();
    timeFocus.dispose();
    durationFocus.dispose();
    urlFocus.dispose();
    super.dispose();
  }
}
