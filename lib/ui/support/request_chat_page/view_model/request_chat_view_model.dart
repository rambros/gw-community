import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/support_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:image_picker/image_picker.dart';

class RequestChatViewModel extends ChangeNotifier {
  final SupportRepository _repository;
  final int requestId;

  RequestChatViewModel({
    required SupportRepository repository,
    required this.requestId,
  }) : _repository = repository {
    _init();
  }

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  CcSupportRequestsRow? _request;
  Stream<List<CcSupportMessagesRow>>? messagesStream;
  File? _selectedImage;
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;

  CcSupportRequestsRow? get request => _request;
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  bool get isResolved => _request?.status == 'resolved';
  bool get canSendMessage => !isResolved && !_isSending;

  Future<void> _init() async {
    await loadRequest();
    messagesStream = _repository.watchMessages(requestId);
    _isLoading = false;
    notifyListeners();

    // Mark messages as read
    await _repository.markMessagesAsRead(requestId);
  }

  Future<void> loadRequest() async {
    _request = await _repository.getRequestById(requestId);
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<bool> sendMessage() async {
    final content = messageController.text.trim();

    if (content.isEmpty && _selectedImage == null) {
      return false;
    }

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl;
      String? imageName;

      // Upload image if selected
      if (_selectedImage != null) {
        final fileName = _selectedImage!.path.split('/').last;
        imageUrl = await _repository.uploadMessageImage(
          _selectedImage!.path,
          fileName,
        );
        imageName = fileName;
      }

      // Send message
      final result = await _repository.sendMessage(
        requestId: requestId,
        content: content.isNotEmpty ? content : 'Image attached',
        imageUrl: imageUrl,
        imageName: imageName,
      );

      _isSending = false;

      if (result != null) {
        messageController.clear();
        _selectedImage = null;
        notifyListeners();

        // Scroll to bottom after sending
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return true;
      } else {
        _errorMessage = 'Failed to send message';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isSending = false;
      _errorMessage = 'Error sending message: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsResolved() async {
    final success = await _repository.markAsResolved(requestId);
    if (success) {
      await loadRequest();
    }
    return success;
  }

  Future<bool> reopenRequest() async {
    final success = await _repository.reopenRequest(requestId);
    if (success) {
      await loadRequest();
    }
    return success;
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void scrollToBottomOnNewMessages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
