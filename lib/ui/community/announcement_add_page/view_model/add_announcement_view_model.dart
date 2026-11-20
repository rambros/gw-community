import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/services/message_image.dart';
import 'package:gw_community/data/services/push/group_message_notifier.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';
import 'package:image_picker/image_picker.dart';

class AddAnnouncementViewModel extends ChangeNotifier {
  AddAnnouncementViewModel({
    required AnnouncementRepository repository,
    required this.currentUserUid,
    this.groupId,
    this.groupName,
    required this.privacy,
    this.groupMembers = const [],
    this.toFacilitators = false,
  }) : _repository = repository {
    _loadCurrentUser();
  }

  final AnnouncementRepository _repository;
  final String currentUserUid;
  final int? groupId;
  final String? groupName;
  final String privacy;
  final List<CcMembersRow> groupMembers;
  final bool toFacilitators;

  final titleController = TextEditingController();
  final experienceController = TextEditingController();
  final titleFocusNode = FocusNode();
  final experienceFocusNode = FocusNode();

  String _visibility = 'group_only';
  String get visibility => _visibility;

  CcMembersRow? _recipientMember;
  CcMembersRow? get recipientMember => _recipientMember;

  bool _pinMessage = false;
  bool get pinMessage => _pinMessage;

  Uint8List? _imageBytes;
  Uint8List? get imageBytes => _imageBytes;

  final ImagePicker _imagePicker = ImagePicker();

  void setPinMessage(bool value) {
    _pinMessage = value;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: messageImageMaxSide.toDouble(),
        maxHeight: messageImageMaxSide.toDouble(),
        imageQuality: 80,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (bytes.length > messageImageMaxBytes) {
        _setError('image_too_large');
        return;
      }
      _imageBytes = await compute(encodeMessageImage, bytes);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('image_not_supported');
    }
  }

  void clearImage() {
    _imageBytes = null;
    notifyListeners();
  }

  void setRecipient(CcMembersRow? member) {
    _recipientMember = member;
    notifyListeners();
  }

  CcMembersRow? _currentUser;
  CcMembersRow? get currentUser => _currentUser;

  bool _isLoadingUser = false;
  bool get isLoadingUser => _isLoadingUser;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get canSelectVisibility => groupName != null && groupName!.isNotEmpty;

  void setVisibility(String? value) {
    if (value == null) return;
    _visibility = value;
    notifyListeners();
  }

  Future<void> _loadCurrentUser() async {
    _isLoadingUser = true;
    notifyListeners();
    try {
      _currentUser = await _repository.getUserById(currentUserUid);
    } finally {
      _isLoadingUser = false;
      notifyListeners();
    }
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty || experienceController.text.trim().isEmpty) {
      _setError('Please fill in all required fields.');
      return false;
    }
    _clearError();
    return true;
  }

  Future<bool> saveAnnouncement() async {
    if (viewAsBlocksWrite()) return false;
    if (!_validateForm()) {
      return false;
    }
    _setSaving(true);
    try {
      String? imageUrl;
      final imageBytes = _imageBytes;
      final messageGroupId = groupId;
      if (imageBytes != null && messageGroupId != null) {
        imageUrl = await _repository.uploadAnnouncementImage(
          groupId: messageGroupId,
          bytes: imageBytes,
        );
      }
      final sharingId = await _repository.createAnnouncement(
        title: titleController.text.trim(),
        text: experienceController.text.trim(),
        privacy: privacy,
        userId: currentUserUid,
        groupId: groupId,
        visibility: visibility,
        recipientUserId: toFacilitators ? null : _recipientMember?.authUserId,
        isPinned: toFacilitators ? false : _pinMessage,
        audience: toFacilitators ? 'facilitators' : null,
        imageUrl: imageUrl,
      );
      unawaited(GroupMessageNotifier.notify(sharingId));
      return true;
    } catch (e) {
      _setError('Error creating announcement: $e');
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
    experienceController.dispose();
    titleFocusNode.dispose();
    experienceFocusNode.dispose();
    super.dispose();
  }
}
