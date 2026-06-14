import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/file_resource_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/resource_view_page/resource_view_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_youtube_player.dart';
import 'package:intl/intl.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class ResourceCardWidget extends StatelessWidget {
  const ResourceCardWidget({
    super.key,
    required this.resource,
    required this.isAdminOrManager,
    required this.onToggleStatus,
    required this.onDelete,
    this.onUnlink,
    this.onSaved,
  });

  final CcFileResourcesRow resource;
  final bool isAdminOrManager;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  /// Non-null only for portal-linked resources (resource.portalItemId != null).
  /// When provided, an "Unlink from Group" action is shown in the popup.
  final VoidCallback? onUnlink;

  /// Called after a successful edit so the parent can refresh the list.
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        onTap: () => _openResource(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(context),
              const SizedBox(width: 14),
              Expanded(child: _buildContent(context)),
              if (isAdminOrManager) _buildMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _typeColor().withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_typeIcon(), color: _typeColor(), size: 22),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                resource.title,
                style: GoogleFonts.lexendDeca(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E2429),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isAdminOrManager) ...[
              const SizedBox(width: 8),
              _buildStatusBadge(),
            ],
          ],
        ),
        if (resource.description != null && resource.description!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            resource.description!,
            style: GoogleFonts.lexendDeca(
              fontSize: 12,
              color: const Color(0xFF57636C),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(_typeIcon(), size: 12, color: const Color(0xFF57636C)),
            const SizedBox(width: 4),
            Text(
              _typeLabel(),
              style: const TextStyle(fontSize: 11, color: Color(0xFF57636C)),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.calendar_today_outlined,
                size: 12, color: Color(0xFF57636C)),
            const SizedBox(width: 4),
            Text(
              _formatDate(resource.createdAt),
              style: const TextStyle(fontSize: 11, color: Color(0xFF57636C)),
            ),
            if (resource.portalItemId != null) ...[
              const SizedBox(width: 10),
              const Icon(Icons.link, size: 12, color: Color(0xFF57636C)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isPublished = resource.status == 'published';
    final color = isPublished ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPublished ? 'Published' : 'Draft',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF57636C)),
      onSelected: (value) {
        switch (value) {
          case 'view':
            _openResource(context);
          case 'edit':
            _openEditSheet(context);
          case 'toggle':
            onToggleStatus();
          case 'unlink':
            _confirmUnlink(context);
          case 'delete':
            _confirmDelete(context);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(children: [
            Icon(Icons.open_in_new, size: 18),
            SizedBox(width: 10),
            Text('View'),
          ]),
        ),
        if (resource.portalItemId == null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 10),
              Text('Edit'),
            ]),
          ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(children: [
            Icon(
              resource.status == 'published'
                  ? Icons.unpublished_outlined
                  : Icons.publish_outlined,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(resource.status == 'published' ? 'Unpublish' : 'Publish'),
          ]),
        ),
        if (onUnlink != null)
          PopupMenuItem(
            value: 'unlink',
            child: Row(children: [
              Icon(Icons.link_off, size: 18, color: Colors.orange.shade700),
              const SizedBox(width: 10),
              Text('Unlink from Group',
                  style: TextStyle(color: Colors.orange.shade700)),
            ]),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 18, color: Colors.red.shade700),
            const SizedBox(width: 10),
            Text('Delete', style: TextStyle(color: Colors.red.shade700)),
          ]),
        ),
      ],
    );
  }

  void _openResource(BuildContext context) {
    if (resource.type == 'video') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (_) => WebViewAware(
          child: _VideoResourceModal(resource: resource),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResourceViewPage(resource: resource)),
      );
    }
  }

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditResourceSheet(
        resource: resource,
        onSaved: onSaved,
      ),
    );
  }

  void _confirmUnlink(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unlink from Group'),
        content: Text(
          'Remove "${resource.title}" from this group\'s Resources tab?\n\n'
          'The original content will remain in the Library.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onUnlink!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Resource'),
        content: Text('Remove "${resource.title}" from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon() {
    switch (resource.type) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'audio':
        return Icons.audiotrack_outlined;
      case 'video':
        return Icons.videocam_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _typeColor() {
    switch (resource.type) {
      case 'pdf':
        return Colors.red;
      case 'audio':
        return Colors.purple;
      case 'video':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _typeLabel() {
    switch (resource.type) {
      case 'pdf':
        return 'PDF';
      case 'audio':
        return 'Audio';
      case 'video':
        return 'Video';
      default:
        return resource.type;
    }
  }

  String _formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);
}

class _VideoResourceModal extends StatelessWidget {
  const _VideoResourceModal({required this.resource});

  final CcFileResourcesRow resource;

  @override
  Widget build(BuildContext context) {
    final modalMaxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.of(context).primaryBackground.withValues(alpha: 0.82),
        child: Align(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 80, 16, 80),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 600, maxHeight: modalMaxHeight),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 12,
                      color: Color(0x1E000000),
                      offset: Offset(0, 5),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Close button
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 16, 8, 0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.of(context).secondaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: AppTheme.of(context).primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Title
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
                        child: Text(
                          resource.title,
                          style: AppTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                color: AppTheme.of(context).primary,
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),

                      // Description
                      if (resource.description != null && resource.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                          child: Text(
                            resource.description!,
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexendDeca(fontWeight: FontWeight.normal),
                                  color: AppTheme.of(context).primary,
                                  fontSize: 14,
                                  letterSpacing: 0,
                                ),
                          ),
                        ),

                      // YouTube player
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                        child: FlutterFlowYoutubePlayer(
                          url: resource.url,
                          autoPlay: false,
                          looping: false,
                          mute: false,
                          showControls: true,
                          showFullScreen: true,
                          strictRelatedVideos: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditResourceSheet extends StatefulWidget {
  const _EditResourceSheet({required this.resource, this.onSaved});

  final CcFileResourcesRow resource;
  final VoidCallback? onSaved;

  @override
  State<_EditResourceSheet> createState() => _EditResourceSheetState();
}

class _EditResourceSheetState extends State<_EditResourceSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _urlController;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.resource.title);
    _descriptionController =
        TextEditingController(text: widget.resource.description ?? '');
    _urlController = TextEditingController(text: widget.resource.url);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();

    if (title.isEmpty) {
      setState(() => _errorMessage = 'Title is required.');
      return;
    }
    if (url.isEmpty) {
      setState(() => _errorMessage = 'URL / address is required.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final ok = await FileResourceRepository().updateFileResource(
      widget.resource.id,
      title: title,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : '',
      url: url,
    );

    if (!mounted) return;

    if (!ok) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Failed to save. Please try again.';
      });
      return;
    }

    Navigator.of(context).pop();
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.edit_outlined,
                      color: AppTheme.of(context).primary),
                  const SizedBox(width: 10),
                  Text(
                    'Edit Resource',
                    style: GoogleFonts.montserrat(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E2429),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                    _label('Title *'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _titleController,
                      decoration: _inputDecoration('Resource title'),
                    ),
                    const SizedBox(height: 14),
                    _label('Description'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: _inputDecoration('Optional description'),
                    ),
                    const SizedBox(height: 14),
                    _label('URL / Address'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      decoration: _inputDecoration('https://...'),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.of(context).primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.openSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E2429),
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF57636C), fontSize: 14),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.06),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      );
}
