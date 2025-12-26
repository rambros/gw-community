import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/utils/upload_data.dart';

class GroupAddViewModel extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final String currentUserUid;

  GroupAddViewModel(
    this._groupRepository, {
    required this.currentUserUid,
  });

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final welcomeMessageController = TextEditingController();
  final policyMessageController = TextEditingController();

  // State
  List<String> _selectedManagerIds = [];
  List<String> get selectedManagerIds => _selectedManagerIds;

  String? _uploadedImageUrl;
  String? get uploadedImageUrl => _uploadedImageUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CcMembersRow> _availableManagers = [];
  List<CcMembersRow> get availableManagers => _availableManagers;

  // Initialization
  Future<void> init() async {
    _setLoading(true);
    try {
      // Fetch users with 'Group Manager' role
      // Note: The original code filtered by 'Group Manager' role.
      // We'll use the repository method if available or query directly if needed.
      // Repository has getGroupManagers() which does exactly this.
      _availableManagers = await _groupRepository.getGroupManagers();

      // Pre-select current user if they are a manager?
      // Original code didn't seem to do this explicitly, but let's keep it empty or add current user if desired.
      // For now, empty.
    } catch (e) {
      debugPrint('Error initializing GroupAddViewModel: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Setters
  void setSelectedManagers(List<String>? ids) {
    _selectedManagerIds = ids ?? [];
    notifyListeners();
  }

  // Image Upload
  Future<void> uploadImage(BuildContext context) async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      storageFolderPath: 'groups',
      maxWidth: 300.00,
      maxHeight: 200.00,
      allowPhoto: true,
      includeBlurHash: true,
    );

    if (selectedMedia != null && selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
      if (!context.mounted) return;
      _setLoading(true);
      try {
        showUploadMessage(
          context,
          'Uploading file...',
          showLoading: true,
        );

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
        _setLoading(false);
      }
    }
  }

  // Save Group
  Future<bool> saveGroup(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a group image')),
      );
      return false;
    }

    _setLoading(true);
    try {
      // Ensure current user is in the managers list if not already
      final managers = List<String>.from(_selectedManagerIds);
      if (!managers.contains(currentUserUid)) {
        managers.add(currentUserUid);
      }

      await _groupRepository.createGroup(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        welcomeMessage: welcomeMessageController.text.trim(),
        policyMessage: policyMessageController.text.trim(),
        imageUrl: _uploadedImageUrl!,
        managerIds: managers,
        privacy: 'Public', // Defaulting to Public as per original code implicit behavior or UI
      );

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    welcomeMessageController.dispose();
    policyMessageController.dispose();
    super.dispose();
  }
}
