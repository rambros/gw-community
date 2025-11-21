import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/flutter_flow/flutter_flow_theme.dart';

import '../view_model/group_details_view_model.dart';
import '/components/user_avatar/user_avatar_widget.dart';

class GroupAboutTab extends StatelessWidget {
  const GroupAboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupDetailsViewModel>();
    final group = viewModel.group;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, 'Description', group.description),
            const SizedBox(height: 16.0),
            _buildSection(context, 'Welcome Message', group.welcomeMessage),
            const SizedBox(height: 16.0),
            _buildSection(context, 'Policy Message', group.policyMessage),
            const SizedBox(height: 24.0),
            Text(
              'Members',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: FlutterFlowTheme.of(context).primary,
                  ),
            ),
            const SizedBox(height: 8.0),
            if (viewModel.isLoadingMembers)
              Center(
                child: SpinKitRipple(
                  color: FlutterFlowTheme.of(context).primary,
                  size: 30.0,
                ),
              )
            else if (viewModel.members.isEmpty)
              Text(
                'No members found.',
                style: FlutterFlowTheme.of(context).bodyMedium,
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.members.length,
                itemBuilder: (context, index) {
                  final member = viewModel.members[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        UserAvatarWidget(
                          imageUrl: member.photoUrl,
                          fullName: member.fullName,
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          member.displayName ?? member.fullName ?? 'Unknown',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.lexendDeca(),
                color: FlutterFlowTheme.of(context).secondary,
              ),
        ),
        const SizedBox(height: 4.0),
        Text(
          content,
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      ],
    );
  }
}
