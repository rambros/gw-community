import 'package:flutter/material.dart';

import '/data/services/supabase/supabase.dart';
import '/data/repositories/group_repository.dart';
import '/utils/upload_data.dart';

class GroupEditViewModel extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final CcGroupsRow group;

  GroupEditViewModel(this._groupRepository, this.group);

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController welcomeMessageController;
  late TextEditingController policyMessageController;

  // State
  List<String> _selectedManagerIds = [];
  List<String> get selectedManagerIds => _selectedManagerIds;

  String? _uploadedImageUrl;
  String? get uploadedImageUrl => _uploadedImageUrl;

  // Helper to get the display image URL (uploaded or existing)
  String? get displayImageUrl => _uploadedImageUrl ?? group.groupImageUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CcUsersRow> _availableManagers = [];
  List<CcUsersRow> get availableManagers => _availableManagers;

  // Initialization
  Future<void> init() async {
    _setLoading(true);
    try {
      // Initialize controllers with existing data
      nameController = TextEditingController(text: group.name);
      descriptionController = TextEditingController(text: group.description);
      welcomeMessageController = TextEditingController(text: group.welcomeMessage);
      policyMessageController = TextEditingController(text: group.policyMessage);

      // Initialize selected managers
      _selectedManagerIds = List<String>.from(group.groupManagers);

      // Fetch available managers
      _availableManagers = await _groupRepository.getGroupManagers();
    } catch (e) {
      debugPrint('Error initializing GroupEditViewModel: $e');
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

  // Update Group
  Future<bool> updateGroup(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    _setLoading(true);
    try {
      // Ensure current user is in the managers list if not already (optional, but good practice)
      final managers = List<String>.from(_selectedManagerIds);
      // If we want to enforce that the creator/current user remains a manager, we can add check here.
      // For now, we trust the selection or existing logic.

      await _groupRepository.updateGroup(
        id: group.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        welcomeMessage: welcomeMessageController.text.trim(),
        policyMessage: policyMessageController.text.trim(),
        imageUrl: _uploadedImageUrl, // Only pass if new image uploaded, repository handles null
        managerIds: managers,
      );

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating group: $e')),
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
