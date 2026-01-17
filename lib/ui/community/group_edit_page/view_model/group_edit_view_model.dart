import 'dart:async';
import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/utils/upload_data.dart';

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

  List<String> _initialManagerIds = []; // To track changes

  String _managerSearchQuery = '';
  String get managerSearchQuery => _managerSearchQuery;

  Timer? _debounce;

  String? _uploadedImageUrl;
  String? get uploadedImageUrl => _uploadedImageUrl;

  // Helper to get the display image URL (uploaded or existing)
  String? get displayImageUrl => _uploadedImageUrl ?? group.groupImageUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CcMembersRow> _availableManagers = []; // Acts as search results
  List<CcMembersRow> get availableManagers => _availableManagers;

  List<CcMembersRow> _selectedManagerObjects = [];

  bool _isPrivate = false;
  bool get isPrivate => _isPrivate;

  void setIsPrivate(bool value) {
    _isPrivate = value;
    notifyListeners();
  }

  // Initialization
  Future<void> init() async {
    _setLoading(true);
    try {
      // Initialize controllers with existing data
      nameController = TextEditingController(text: group.name);
      descriptionController = TextEditingController(text: group.description);
      welcomeMessageController = TextEditingController(text: group.welcomeMessage);
      policyMessageController = TextEditingController(text: group.policyMessage);

      // Initialize privacy
      _isPrivate = (group.groupPrivacy?.toLowerCase() ?? 'public') == 'private';

      // Initialize selected managers from group members
      // We use getGroupMembersAsUsers to get the full user profiles of existing members
      final allMembers = await _groupRepository.getGroupMembersAsUsers(group.id);

      // Filter for managers/facilitators
      _selectedManagerObjects = allMembers.where((m) {
        // getGroupMembersAsUsers returns CcMembersRow which has 'userRole' if joined properly
        // wait, CcMembersRow from getGroupMembersAsUsers might NOT have userRole populated directly
        // if it comes from CcMembersTable join.
        // Actually, getGroupMembersAsUsers in repository does NOT join with role.
        // We need to match with the links.
        return false; // logic below
      }).toList();

      // Better approach: Get links, then get users.
      final links = await _groupRepository.getGroupMembers(group.id);
      final managerUserIds = links
          .where((m) => m.userId != null && (m.userRole == 'GROUP_MANAGER' || m.userRole == 'Manager'))
          .map((m) => m.userId!)
          .toSet();

      _selectedManagerObjects = allMembers.where((u) => managerUserIds.contains(u.authUserId)).toList();
      _selectedManagerIds = _selectedManagerObjects.map((u) => u.authUserId!).toList();
      _initialManagerIds = List.from(_selectedManagerIds);

      // We do NOT fetch all available users anymore.
      _availableManagers = [];
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

  void toggleManager(String managerId, [CcMembersRow? user]) {
    if (_selectedManagerIds.contains(managerId)) {
      _selectedManagerIds.remove(managerId);
      _selectedManagerObjects.removeWhere((u) => u.authUserId == managerId);
    } else {
      _selectedManagerIds.add(managerId);
      if (user != null) {
        _selectedManagerObjects.add(user);
      }
    }
    notifyListeners();
  }

  Future<void> setManagerSearchQuery(String query) async {
    _managerSearchQuery = query;

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (query.trim().length < 3) {
      _availableManagers = [];
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      // Server-side search
      try {
        _availableManagers = await _groupRepository.searchAvailableUsers(query);
      } catch (e) {
        debugPrint('Error searching managers: $e');
        _availableManagers = [];
      }
      notifyListeners();
    });
  }

  // Filtered managers based on search query
  List<CcMembersRow> get filteredManagers {
    // Return search results
    return _availableManagers;
  }

  // Get selected managers as CcMembersRow objects
  List<CcMembersRow> get selectedManagers {
    return _selectedManagerObjects;
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
        showUploadMessage(context, 'Uploading file...', showLoading: true);

        final downloadUrls = await uploadSupabaseStorageFiles(bucketName: 'portal', selectedFiles: selectedMedia);

        if (downloadUrls.isNotEmpty) {
          _uploadedImageUrl = downloadUrls.first;
          notifyListeners();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
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
      await _groupRepository.updateGroup(
        id: group.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        welcomeMessage: welcomeMessageController.text.trim(),
        policyMessage: policyMessageController.text.trim(),
        imageUrl: _uploadedImageUrl, // Only pass if new image uploaded, repository handles null
        privacy: _isPrivate ? 'Private' : 'Public', // Update privacy
      );

      // Sync managers
      final managersToAdd = _selectedManagerIds.where((id) => !_initialManagerIds.contains(id));
      final managersToRemove = _initialManagerIds.where((id) => !_selectedManagerIds.contains(id));

      for (final userId in managersToAdd) {
        // Check if already member
        final isMember = await _groupRepository.isUserMemberOfGroup(group.id, userId);
        if (isMember) {
          await _groupRepository.updateMemberRole(group.id, userId, 'GROUP_MANAGER');
        } else {
          await _groupRepository.addMemberWithRole(group.id, userId, 'GROUP_MANAGER');
        }
      }

      for (final userId in managersToRemove) {
        await _groupRepository.updateMemberRole(group.id, userId, 'MEMBER');
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating group: $e')));
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
    _debounce?.cancel();
    super.dispose();
  }
}
