import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/group_repository.dart';

class GroupResourcesTab extends StatefulWidget {
  final int groupId;
  final String userId;
  final bool isAdminOrManager;

  const GroupResourcesTab({
    required this.groupId,
    required this.userId,
    required this.isAdminOrManager,
    super.key,
  });

  @override
  State<GroupResourcesTab> createState() => _GroupResourcesTabState();
}

class _GroupResourcesTabState extends State<GroupResourcesTab> {
  final GroupRepository _repository = GroupRepository();
  List<Map<String, dynamic>> _resources = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _repository.getGroupResources(
        widget.groupId,
        widget.userId,
      );
      setState(() {
        _resources = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading resources: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadResources,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final featuredResources = _resources.where((r) => r['featured'] == true).toList();
    final otherResources = _resources.where((r) => r['featured'] != true).toList();

    return RefreshIndicator(
      onRefresh: _loadResources,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (featuredResources.isNotEmpty) ...[
            _buildSectionHeader('🌟 Featured'),
            const SizedBox(height: 8),
            ...featuredResources.map((r) => _buildResourceCard(r)),
            const SizedBox(height: 24),
          ],
          if (otherResources.isNotEmpty) ...[
            _buildSectionHeader('📖 Resources'),
            const SizedBox(height: 8),
            ...otherResources.map((r) => _buildResourceCard(r)),
          ],
          if (_resources.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No resources added to this group yet.',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Lexend Deca',
      ),
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    final item = resource['portal_item'] as Map<String, dynamic>?;
    if (item == null) return const SizedBox.shrink();

    final isExclusive = resource['visibility'] == 'exclusive';
    final title = item['title'] as String? ?? 'Untitled';
    final description = item['description'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openResource(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isExclusive ? Icons.lock : Icons.public,
                color: isExclusive ? Colors.orange : Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lexend Deca',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isExclusive ? 'Exclusive to this group' : 'Public - also in Library',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Lexend Deca',
                      ),
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontFamily: 'Lexend Deca',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.isAdminOrManager)
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showResourceOptions(resource),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openResource(Map<String, dynamic> item) {
    // TODO: Navigate to resource details page
    // Navigator.push(context, MaterialPageRoute(builder: (_) => ResourceDetailsPage(item: item)));
  }

  void _showResourceOptions(Map<String, dynamic> resource) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove from Group'),
              onTap: () {
                Navigator.pop(context);
                _confirmRemoveResource(resource);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemoveResource(Map<String, dynamic> resource) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Resource'),
        content: const Text('Are you sure you want to remove this resource from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _repository.removeResourceFromGroup(
          widget.groupId,
          resource['portal_item_id'] as int,
        );
        _loadResources();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resource removed successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error removing resource: $e')),
          );
        }
      }
    }
  }
}
