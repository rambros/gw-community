import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/custom_functions.dart' as functions;

/// Rounded avatar that shows either the user's photo or derived initials.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.fullName,
    this.size = 50.0,
  });

  final String? imageUrl;
  final String? fullName;
  final double size;

  bool get _hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final initials = _buildInitials();

    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      shape: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.of(context).alternate,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.of(context).alternate,
            width: 0.0,
          ),
        ),
        alignment: Alignment.center,
        child: SizedBox(
          width: size,
          height: size,
          child: _hasImage
              ? _buildImage()
              : _InitialsPlaceholder(
                  size: size,
                  initials: initials,
                ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Hero(
      tag: imageUrl!,
      transitionOnUserGestures: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: CachedNetworkImage(
          fadeInDuration: const Duration(milliseconds: 500),
          fadeOutDuration: const Duration(milliseconds: 500),
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _buildInitials() {
    final calculated = functions.getInitials(fullName ?? '');
    if (calculated == null || calculated.isEmpty) {
      return '?';
    }
    return calculated;
  }
}

class _InitialsPlaceholder extends StatelessWidget {
  const _InitialsPlaceholder({
    required this.initials,
    required this.size,
  });

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Text(
        initials,
        textAlign: TextAlign.center,
        style: AppTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lexendDeca(
                fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
              ),
              color: AppTheme.of(context).primaryText,
              fontSize: size * 0.4,
            ),
      ),
    );
  }
}
