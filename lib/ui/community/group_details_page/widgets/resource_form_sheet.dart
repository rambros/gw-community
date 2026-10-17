import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/data/repositories/file_resource_repository.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/group_details_page/widgets/resource_markdown_editor.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/upload_data.dart';

class ResourceFormSheet extends StatefulWidget {
  const ResourceFormSheet({
    super.key,
    required this.groupId,
    required this.currentUserId,
    required this.onSaved,
  });

  final int groupId;
  final String currentUserId;
  final VoidCallback onSaved;

  @override
  State<ResourceFormSheet> createState() => _ResourceFormSheetState();
}

class _ResourceFormSheetState extends State<ResourceFormSheet> {
  final _repository = FileResourceRepository();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _bodyController = TextEditingController();

  String _selectedType = 'pdf';
  SelectedFile? _selectedFile;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final files = await selectFiles(allowedExtensions: _extensionsFor(_selectedType));
    if (files == null || files.isEmpty) return;
    setState(() => _selectedFile = files.first);
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _errorMessage = context.l10n.titleRequired);
      return;
    }
    if (_selectedType == 'video') {
      if (_videoUrlController.text.trim().isEmpty) {
        setState(() => _errorMessage = context.l10n.pleaseEnterYoutubeUrl);
        return;
      }
    } else if (_selectedType == 'text') {
      if (_bodyController.text.trim().isEmpty) {
        setState(() => _errorMessage = context.l10n.pleaseEnterText);
        return;
      }
    } else if (_selectedFile == null) {
      setState(() => _errorMessage = context.l10n.pleaseSelectFile);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      String? url;
      String? body;
      if (_selectedType == 'video') {
        url = _videoUrlController.text.trim();
      } else if (_selectedType == 'text') {
        url = textResourcePlaceholderUrl;
        body = _bodyController.text.trim();
      } else {
        url = await _repository.uploadFile(
          _selectedFile!.bytes,
          _selectedFile!.originalFilename,
          _selectedType,
        );
        if (url == null) {
          setState(() => _errorMessage = context.l10n.uploadFailed);
          return;
        }
      }

      final ok = await _repository.createFileResource(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        url: url,
        type: _selectedType,
        groupId: widget.groupId,
        createdBy: widget.currentUserId,
        body: body,
      );

      if (!ok) {
        setState(() => _errorMessage = context.l10n.failedToSaveResource);
        return;
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final maxHeight = MediaQuery.sizeOf(context).height - viewInsets.bottom - 8;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              _buildHeader(context),
              Flexible(child: _buildBody(context)),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() => Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: [
          Icon(Icons.add_circle_outline, color: AppTheme.of(context).primary),
          const SizedBox(width: 10),
          Text(
            context.l10n.addResource,
            style: GoogleFonts.montserrat(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E2429),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
          ],

          _label(context, '${context.l10n.title} *'),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(context.l10n.resourceTitle),
          ),
          const SizedBox(height: 14),

          _label(context, context.l10n.description),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(context.l10n.optionalDescription),
          ),
          const SizedBox(height: 14),

          _label(context, context.l10n.type),
          const SizedBox(height: 8),
          _buildTypeSelector(context),
          const SizedBox(height: 14),

          _label(context, _contentLabel(context)),
          const SizedBox(height: 8),
          if (_selectedType == 'video')
            TextField(
              controller: _videoUrlController,
              keyboardType: TextInputType.url,
              decoration: _inputDecoration(context.l10n.youtubeUrl),
            )
          else if (_selectedType == 'text')
            ResourceMarkdownEditor(
              controller: _bodyController,
              enabled: !_isSaving,
            )
          else
            _buildFilePicker(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    final types = [
      ('pdf', Icons.picture_as_pdf_outlined, 'PDF'),
      ('audio', Icons.audiotrack_outlined, context.l10n.mediaAudio),
      ('video', Icons.videocam_outlined, context.l10n.mediaVideo),
      ('text', Icons.article_outlined, context.l10n.mediaText),
    ];

    return Row(
      children: [
        for (var i = 0; i < types.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _typeOption(context, types[i])),
        ],
      ],
    );
  }

  Widget _typeOption(BuildContext context, (String, IconData, String) type) {
    final selected = _selectedType == type.$1;
    final primary = AppTheme.of(context).primary;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedType = type.$1;
        _selectedFile = null;
        _videoUrlController.clear();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              type.$2,
              color: selected ? primary : Colors.grey.shade500,
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              type.$3,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? primary : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _contentLabel(BuildContext context) {
    switch (_selectedType) {
      case 'video':
        return context.l10n.youtubeVideoUrl;
      case 'text':
        return context.l10n.enterTextRequired;
      default:
        return context.l10n.fileRequired;
    }
  }

  Widget _buildFilePicker(BuildContext context) {
    return GestureDetector(
      onTap: _isSaving ? null : _pickFile,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file_outlined, color: AppTheme.of(context).primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedFile?.originalFilename ?? context.l10n.tapToSelectFile,
                style: TextStyle(
                  fontSize: 13,
                  color: _selectedFile != null ? const Color(0xFF1E2429) : Colors.grey.shade500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
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
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(context.l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      );

  List<String> _extensionsFor(String type) {
    switch (type) {
      case 'pdf':
        return ['pdf'];
      case 'audio':
        return ['mp3', 'aac', 'm4a', 'wav', 'ogg'];
      case 'video':
        return ['mp4', 'mov', 'avi', 'mkv'];
      default:
        return [];
    }
  }
}
