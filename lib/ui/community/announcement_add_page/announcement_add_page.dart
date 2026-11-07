import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/announcement_add_page/view_model/add_announcement_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class AnnouncementAddPage extends StatefulWidget {
  const AnnouncementAddPage({
    super.key,
    this.groupId,
    this.groupName,
    String? privacy,
    this.groupMembers = const [],
    this.initialRecipientAuthUserId,
    this.initialRecipient,
    this.toFacilitators = false,
  }) : privacy = privacy ?? 'public';

  final int? groupId;
  final String? groupName;
  final String privacy;
  final List<CcMembersRow> groupMembers;
  final String? initialRecipientAuthUserId;
  final CcMembersRow? initialRecipient;
  final bool toFacilitators;

  static String routeName = 'announcementAddPage';
  static String routePath = '/announcementAddPage';

  @override
  State<AnnouncementAddPage> createState() => _AnnouncementAddPageState();
}

class _AnnouncementAddPageState extends State<AnnouncementAddPage> {
  late AddAnnouncementViewModel _viewModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'announcementAddPage'});
    final members = _enrichedGroupMembers();
    _viewModel = AddAnnouncementViewModel(
      repository: context.read<AnnouncementRepository>(),
      currentUserUid: context.currentUserIdOrEmpty,
      groupId: widget.groupId,
      groupName: widget.groupName,
      privacy: widget.privacy,
      groupMembers: members,
      toFacilitators: widget.toFacilitators,
    );
    final initial = _resolveInitialRecipient(members);
    if (initial != null) {
      _viewModel.setRecipient(initial);
    }
  }

  List<CcMembersRow> _enrichedGroupMembers() {
    final members = List<CcMembersRow>.from(widget.groupMembers);
    final initial = widget.initialRecipient;
    final initialId = initial?.authUserId;
    if (initial != null &&
        initialId != null &&
        initialId.isNotEmpty &&
        !members.any((m) => m.authUserId == initialId)) {
      members.add(initial);
    }
    return members;
  }

  CcMembersRow? _resolveInitialRecipient(List<CcMembersRow> members) {
    final preferredId = widget.initialRecipient?.authUserId ??
        widget.initialRecipientAuthUserId;
    if (preferredId == null || preferredId.isEmpty) {
      return widget.initialRecipient;
    }
    for (final member in members) {
      if (member.authUserId == preferredId) return member;
    }
    return widget.initialRecipient;
  }

  String _memberName(CcMembersRow? member) {
    if (member == null) return '';

    final displayName = member.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final parts = <String>[
      if (member.firstName?.trim().isNotEmpty == true) member.firstName!.trim(),
      if (member.hideLastName != true &&
          member.lastName?.trim().isNotEmpty == true)
        member.lastName!.trim(),
    ];
    final name = parts.join(' ').trim();
    if (name.isNotEmpty) return name;

    final email = member.email?.trim();
    if (email != null && email.contains('@')) {
      final local = email.split('@').first.trim();
      if (local.isNotEmpty) return local;
    }
    return '';
  }

  String _headerUserName(CcMembersRow? member) {
    final fromMember = _memberName(member);
    if (fromMember.isNotEmpty) return fromMember;

    final loginUser = FFAppState().loginUser;
    for (final candidate in [
      loginUser.displayName,
      loginUser.fullName,
      loginUser.firstName,
    ]) {
      final value = candidate.trim();
      if (value.isNotEmpty) return value;
    }
    final email = loginUser.email.trim();
    if (email.contains('@')) {
      final local = email.split('@').first.trim();
      if (local.isNotEmpty) return local;
    }
    return '';
  }

  String _memberOptionLabel(CcMembersRow member) {
    final parts = <String>[
      if (member.firstName?.trim().isNotEmpty == true) member.firstName!.trim(),
      if (member.hideLastName != true &&
          member.lastName?.trim().isNotEmpty == true)
        member.lastName!.trim(),
    ];
    var name = parts.join(' ').trim();
    if (name.isEmpty) {
      name = member.displayName?.trim() ?? '';
    }
    final email = member.email?.trim();
    if (name.isEmpty) {
      return email?.isNotEmpty == true ? email! : context.l10n.member;
    }
    if (email != null && email.isNotEmpty) {
      return '$name ($email)';
    }
    return name;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AddAnnouncementViewModel>(
        builder: (context, viewModel, _) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: AppTheme.of(context).primaryBackground,
              appBar: AppBar(
                backgroundColor: AppTheme.of(context).primary,
                automaticallyImplyLeading: false,
                leading: FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 60.0,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  widget.toFacilitators
                      ? context.l10n.newMessageToFacilitator
                      : context.l10n.newMessage,
                  style: AppTheme.of(context).titleLarge.override(
                        font: GoogleFonts.poppins(
                          fontWeight:
                              AppTheme.of(context).titleLarge.fontWeight,
                          fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                        ),
                        fontSize: 20.0,
                        letterSpacing: 0.0,
                      ),
                ),
                centerTitle: true,
                elevation: 2.0,
              ),
              body: SafeArea(
                top: true,
                child: viewModel.isLoadingUser && viewModel.currentUser == null
                    ? _buildLoadingIndicator(context)
                    : Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            8.0, 0.0, 8.0, 8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context, viewModel),
                              _buildForm(context, viewModel),
                              _buildActions(context, viewModel),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50.0,
        height: 50.0,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            AppTheme.of(context).primary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AddAnnouncementViewModel viewModel) {
    final userName = _headerUserName(viewModel.currentUser);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (userName.isNotEmpty)
            Text(
              userName,
              style: AppTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.normal,
                      fontStyle: AppTheme.of(context).bodyLarge.fontStyle,
                    ),
                    color: AppTheme.of(context).secondary,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
            ),
          if (widget.groupId != null)
            Text(
              context.l10n.fromGroup(widget.groupName ?? ''),
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(
                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: AppTheme.of(context).secondary,
                    letterSpacing: 0.0,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, AddAnnouncementViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
          child: TextFormField(
            controller: viewModel.titleController,
            focusNode: viewModel.titleFocusNode,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(context, context.l10n.title),
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(
                    fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: AppTheme.of(context).secondary,
                  letterSpacing: 0.0,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
          child: TextFormField(
            controller: viewModel.experienceController,
            focusNode: viewModel.experienceFocusNode,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(context, context.l10n.message),
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(
                    fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: AppTheme.of(context).secondary,
                  letterSpacing: 0.0,
                ),
            maxLines: 14,
          ),
        ),
        if (widget.toFacilitators)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
            child: Text(
              context.l10n.messageToFacilitatorHint,
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).secondary,
                  ),
            ),
          ),
        if (!widget.toFacilitators && viewModel.groupMembers.isNotEmpty && widget.groupId != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
            child: DropdownButtonFormField<CcMembersRow?>(
              key: ValueKey(
                'send-to-${viewModel.recipientMember?.authUserId ?? 'all'}',
              ),
              initialValue: viewModel.recipientMember,
              isExpanded: true,
              decoration: _inputDecoration(context, context.l10n.sendTo),
              items: [
                DropdownMenuItem<CcMembersRow?>(
                  value: null,
                  child: Text(
                    context.l10n.allMembersBroadcast,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(),
                          color: AppTheme.of(context).secondary,
                        ),
                  ),
                ),
                ...viewModel.groupMembers
                    .map((member) => DropdownMenuItem<CcMembersRow?>(
                          value: member,
                          child: Text(
                            _memberOptionLabel(member),
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexendDeca(),
                                  color: AppTheme.of(context).secondary,
                                ),
                          ),
                        )),
              ],
              onChanged: viewModel.setRecipient,
            ),
          ),
        if (!widget.toFacilitators)
          _pinSwitch(context, viewModel.pinMessage, viewModel.setPinMessage),
        if (viewModel.errorMessage != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
            child: Text(
              viewModel.errorMessage!,
              style: AppTheme.of(context).labelMedium.copyWith(
                    color: AppTheme.of(context).error,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _pinSwitch(
    BuildContext context,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
      child: Material(
        color: const Color(0xFFF9FAFB),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: AppTheme.of(context).alternate,
            width: 1.0,
          ),
        ),
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          secondary: Icon(
            Icons.push_pin_outlined,
            color: AppTheme.of(context).primary,
          ),
          title: Text(
            context.l10n.pinMessage,
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(),
                  color: AppTheme.of(context).secondary,
                ),
          ),
          activeThumbColor: AppTheme.of(context).primary,
          activeTrackColor: AppTheme.of(context).primary.withValues(alpha: 0.5),
          controlAffinity: ListTileControlAffinity.trailing,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTheme.of(context).labelLarge.override(
            font: GoogleFonts.poppins(
              fontWeight: AppTheme.of(context).labelLarge.fontWeight,
              fontStyle: AppTheme.of(context).labelLarge.fontStyle,
            ),
            color: AppTheme.of(context).primary,
            fontSize: 16.0,
            letterSpacing: 0.0,
          ),
      hintStyle: AppTheme.of(context).bodySmall.override(
            font: GoogleFonts.lexendDeca(
              fontWeight: AppTheme.of(context).bodySmall.fontWeight,
              fontStyle: AppTheme.of(context).bodySmall.fontStyle,
            ),
            color: AppTheme.of(context).alternate,
            letterSpacing: 0.0,
          ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppTheme.of(context).alternate,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppTheme.of(context).alternate,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
    );
  }

  Widget _buildActions(
      BuildContext context, AddAnnouncementViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 32.0, 16.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: FFButtonWidget(
              onPressed: () => context.pushNamed(CommunityPage.routeName),
              text: context.l10n.cancel,
              options: FFButtonOptions(
                height: 40.0,
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                color: AppTheme.of(context).primaryBackground,
                textStyle: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(
                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                      ),
                      color: AppTheme.of(context).secondary,
                      letterSpacing: 0.0,
                    ),
                elevation: 0.0,
                borderSide: BorderSide(
                  color: AppTheme.of(context).secondaryBackground,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          FFButtonWidget(
            onPressed: viewModel.isSaving
                ? null
                : () async {
                    final success = await viewModel.saveAnnouncement();
                    if (!success || !context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n.messageCreatedSuccessfully,
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                          ),
                        ),
                        backgroundColor: AppTheme.of(context).secondary,
                      ),
                    );
                    context.pop();
                  },
            text: viewModel.isSaving ? context.l10n.saving : context.l10n.addMessage,
            options: FFButtonOptions(
              height: 40.0,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              color: AppTheme.of(context).primary,
              textStyle: AppTheme.of(context).labelLarge.override(
                    font: GoogleFonts.poppins(
                      fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                      fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                    ),
                    color: AppTheme.of(context).primaryBackground,
                    letterSpacing: 0.0,
                  ),
              elevation: 1.0,
              borderSide: BorderSide(
                color: AppTheme.of(context).secondaryBackground,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ],
      ),
    );
  }
}
