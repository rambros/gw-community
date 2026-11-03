import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/admin_view_as_queries.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/group_details_page/view_model/group_details_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MemberDetailsSheet extends StatefulWidget {
  final CcMembersRow member;

  const MemberDetailsSheet({
    super.key,
    required this.member,
  });

  @override
  State<MemberDetailsSheet> createState() => _MemberDetailsSheetState();
}

class _MemberDetailsSheetState extends State<MemberDetailsSheet> {
  bool _isLoadingJourneys = true;
  List<CcViewUserJourneysRow> _journeys = [];

  CcMembersRow get member => widget.member;

  @override
  void initState() {
    super.initState();
    _loadJourneys();
  }

  Future<void> _loadJourneys() async {
    final authUserId = member.authUserId;
    if (authUserId == null || authUserId.isEmpty) {
      if (mounted) {
        setState(() {
          _journeys = [];
          _isLoadingJourneys = false;
        });
      }
      return;
    }

    final journeys = await AdminViewAsQueries.journeys(authUserId);
    if (!mounted) return;
    setState(() {
      _journeys = journeys;
      _isLoadingJourneys = false;
    });
  }

  String _displayName(BuildContext context) {
    if (member.hideLastName == true) {
      return member.firstName ?? member.displayName ?? context.l10n.unknown;
    }
    final fullName =
        '${member.firstName ?? ''} ${member.lastName ?? ''}'.trim();
    return fullName.isNotEmpty
        ? fullName
        : (member.displayName ?? context.l10n.unknown);
  }

  String _lastAccessValue(BuildContext context) {
    final access = member.lastAccess;
    if (access == null) return context.l10n.neverAccessed;
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(access.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.of(context).primary;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.details,
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.lexendDeca(),
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _displayName(context),
                        style: AppTheme.of(context).headlineSmall.override(
                              font: GoogleFonts.lexendDeca(),
                              color: primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24.0),
                      if (member.email != null) ...[
                        _InfoCard(
                          icon: Icons.email_outlined,
                          label: context.l10n.email,
                          value: member.email!,
                        ),
                        const SizedBox(height: 12.0),
                      ],
                      _InfoCard(
                        icon: Icons.schedule_outlined,
                        label: context.l10n.lastAccess,
                        value: _lastAccessValue(context),
                      ),
                      if (member.bio != null && member.bio!.isNotEmpty) ...[
                        const SizedBox(height: 12.0),
                        _InfoCard(
                          icon: Icons.info_outline,
                          label: 'Bio',
                          value: member.bio!,
                        ),
                      ],
                      if (member.country != null &&
                          member.country!.isNotEmpty) ...[
                        const SizedBox(height: 12.0),
                        _InfoCard(
                          icon: Icons.location_on_outlined,
                          label: 'Country',
                          value: member.country!,
                        ),
                      ],
                      const SizedBox(height: 20.0),
                      Text(
                        context.l10n.journeys,
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.lexendDeca(),
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 10.0),
                      if (_isLoadingJourneys)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: primary,
                              ),
                            ),
                          ),
                        )
                      else if (_journeys.isEmpty)
                        _InfoCard(
                          icon: Icons.map_outlined,
                          label: context.l10n.journeys,
                          value: context.l10n.noJourneysStarted,
                        )
                      else
                        ..._journeys.map((journey) {
                          final completed = journey.stepsCompleted ?? 0;
                          final total = journey.stepsTotal ?? 0;
                          final progress =
                              total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: AppTheme.of(context)
                                      .alternate
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.map_outlined,
                                        size: 20,
                                        color: primary,
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Text(
                                          journey.title ??
                                              context.l10n.unknown,
                                          style: AppTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.lexendDeca(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    context.l10n.stepsProgress(
                                      completed,
                                      total,
                                    ),
                                    style:
                                        AppTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.lexendDeca(),
                                              color: AppTheme.of(context)
                                                  .secondaryText,
                                            ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      backgroundColor: AppTheme.of(context)
                                          .alternate
                                          .withValues(alpha: 0.35),
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + bottomSafe),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmRemoveMember(context),
                    icon: Icon(
                      Icons.person_remove_outlined,
                      color: Colors.red.shade700,
                    ),
                    label: Text(
                      'Remove from Group',
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.lexendDeca(),
                            color: Colors.red.shade700,
                          ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemoveMember(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (alertContext) => AlertDialog(
        title: Text(context.l10n.confirmation),
        content: Text(
          context.l10n.confirmRemoveMemberNamed(_displayName(alertContext)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(alertContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final viewModel = context.read<GroupDetailsViewModel>();
      final success = await viewModel.removeMember(member.authUserId!);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Member removed successfully'
                  : 'Failed to remove member',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.of(context).alternate.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.of(context).primary,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.lexendDeca(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.lexendDeca(),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
