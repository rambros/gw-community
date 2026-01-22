import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

/// Widget que exibe o cabeçalho do experience com informações do autor
/// Inclui: avatar, nome do usuário, grupo (se aplicável) e visibilidade
class ExperienceHeaderWidget extends StatelessWidget {
  const ExperienceHeaderWidget({
    super.key,
    required this.experience,
  });

  final CcViewSharingsUsersRow experience;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: AppTheme.of(context).primaryBackground,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            UserAvatar(
              imageUrl: experience.photoUrl,
              fullName: experience.fullName,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        experience.displayName,
                        'name',
                      ),
                      style: AppTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.normal,
                            ),
                            color: AppTheme.of(context).secondary,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    _buildVisibilityText(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityText(BuildContext context) {
    final isEveryone = experience.visibility == 'everyone';
    final groupName = experience.groupName;

    // If not everyone and has a group name, show "Visible only for <group name>"
    if (!isEveryone && groupName != null && groupName.isNotEmpty) {
      return RichText(
        textScaler: MediaQuery.of(context).textScaler,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Visible only for ',
              style: TextStyle(
                color: AppTheme.of(context).primary,
                fontSize: 12.0,
              ),
            ),
            TextSpan(
              text: groupName,
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(
                      fontWeight: FontWeight.bold,
                    ),
                    color: AppTheme.of(context).primary,
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(),
                color: AppTheme.of(context).primary,
                fontSize: 12.0,
                letterSpacing: 0.0,
              ),
        ),
      );
    }

    // Default: "Visible for everyone"
    return Text(
      'Visible for everyone',
      style: AppTheme.of(context).bodyMedium.override(
            font: GoogleFonts.lexendDeca(),
            color: AppTheme.of(context).primary,
            fontSize: 12.0,
            letterSpacing: 0.0,
          ),
    );
  }
}
