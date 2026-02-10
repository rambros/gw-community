import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/group_details_page/view_model/group_details_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

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
            if (viewModel.shouldShowOnlyAbout) ...[
              if (!viewModel.canJoin && group.groupPrivacy?.toLowerCase().trim() == 'private') ...[
                const SizedBox(height: 24.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: AppTheme.of(context).secondary, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.lock_outline, color: AppTheme.of(context).secondary, size: 32.0),
                      const SizedBox(height: 12.0),
                      Text(
                        'This is a private group. You need an invitation to join and see the content.',
                        textAlign: TextAlign.center,
                        style: AppTheme.of(
                          context,
                        ).bodyMedium.override(font: GoogleFonts.lexendDeca(), color: AppTheme.of(context).secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16.0),
            if (group.moreInformation != null && group.moreInformation!.isNotEmpty)
              _CollapsibleSection(title: 'More Information', content: group.moreInformation!),
            if (viewModel.shouldShowOnlyAbout && viewModel.canJoin) ...[
              const SizedBox(height: 24.0),
              Center(
                child: FFButtonWidget(
                  onPressed: () => viewModel.joinGroup(),
                  text: 'Join Group',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: AppTheme.of(context).primary,
                    textStyle: AppTheme.of(
                      context,
                    ).titleSmall.override(font: GoogleFonts.lexendDeca(), color: Colors.white, fontSize: 16.0),
                    elevation: 2.0,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  showLoadingIndicator: viewModel.isJoining,
                ),
              ),
            ],
            const SizedBox(height: 24.0),
            if (viewModel.isLoadingMembers)
              Center(child: SpinKitRipple(color: AppTheme.of(context).primary, size: 30.0))
            else if (viewModel.members.isEmpty)
              Text(
                'No members found.',
                style: AppTheme.of(context).bodyMedium.override(
                      color: AppTheme.of(context).textColor,
                    ),
              )
            else
              _buildMembersSections(context, viewModel),
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
          style: AppTheme.of(
            context,
          ).titleMedium.override(font: GoogleFonts.lexendDeca(), color: AppTheme.of(context).primary),
        ),
        const SizedBox(height: 4.0),
        Text(
          content,
          style: AppTheme.of(context).bodyMedium.override(
                color: AppTheme.of(context).textColor,
              ),
        ),
      ],
    );
  }

  Widget _buildMembersSections(BuildContext context, GroupDetailsViewModel viewModel) {
    final group = viewModel.group;
    final members = viewModel.members;

    // Separa facilitators (group_managers) dos membros comuns usando IDs
    final facilitators = members.where((m) {
      if (m.authUserId == null) return false;
      return viewModel.groupManagerIds.contains(m.authUserId);
    }).toList();

    final regularMembers = members.where((m) {
      if (m.authUserId == null) return true;
      return !viewModel.groupManagerIds.contains(m.authUserId);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seção Facilitators
        if (facilitators.isNotEmpty) ...[
          Text(
            'Facilitators',
            style: AppTheme.of(
              context,
            ).titleMedium.override(font: GoogleFonts.lexendDeca(), color: AppTheme.of(context).primary),
          ),
          const SizedBox(height: 8.0),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: facilitators.length,
            itemBuilder: (context, index) {
              return _buildMemberRow(context, facilitators[index]);
            },
          ),
          const SizedBox(height: 16.0),
        ],
        // Seção Members
        if (regularMembers.isNotEmpty) ...[
          Text(
            'Members',
            style: AppTheme.of(
              context,
            ).titleMedium.override(font: GoogleFonts.lexendDeca(), color: AppTheme.of(context).primary),
          ),
          const SizedBox(height: 8.0),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: regularMembers.length,
            itemBuilder: (context, index) {
              return _buildMemberRow(context, regularMembers[index]);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildMemberRow(BuildContext context, CcMembersRow member) {
    final displayName = () {
      if (member.hideLastName == true) {
        return member.firstName ?? member.displayName ?? 'Unknown';
      }
      final fullName = '${member.firstName ?? ''} ${member.lastName ?? ''}'.trim();
      return fullName.isNotEmpty ? fullName : (member.displayName ?? 'Unknown');
    }();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          UserAvatar(imageUrl: member.photoUrl, fullName: displayName, size: 36.0),
          const SizedBox(width: 10.0),
          Text(
            displayName,
            style: AppTheme.of(context).bodyMedium.override(
                  color: AppTheme.of(context).textColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final String content;

  const _CollapsibleSection({required this.title, required this.content});

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: AppTheme.of(context).titleMedium.override(
                      font: GoogleFonts.lexendDeca(),
                      color: AppTheme.of(context).primary,
                    ),
              ),
              Icon(
                _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: AppTheme.of(context).secondary,
                size: 24.0,
              ),
            ],
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.content,
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).textColor,
                  ),
            ),
          ),
      ],
    );
  }
}
