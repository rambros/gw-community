import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/data/repositories/group_repository.dart';
import 'view_model/group_invitation_view_model.dart';
import '/backend/supabase/supabase.dart';

class GroupInvitationPage extends StatelessWidget {
  final CcGroupsRow? groupRow;

  const GroupInvitationPage({
    super.key,
    required this.groupRow,
  });

  static String routeName = 'groupInvitation';
  static String routePath = '/groupInvitation';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupInvitationViewModel(
        context.read<GroupRepository>(),
        groupRow,
      ),
      child: const GroupInvitationPageView(),
    );
  }
}

class GroupInvitationPageView extends StatelessWidget {
  const GroupInvitationPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupInvitationViewModel>();
    final group = viewModel.group;

    if (group == null) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
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
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Group Not Found',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(),
                  color: FlutterFlowTheme.of(context).primaryBackground,
                ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: const Center(child: Text('Group information is missing.')),
      );
    }

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      floatingActionButton: Align(
        alignment: const AlignmentDirectional(0.2, 1.0),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
          child: FloatingActionButton.extended(
            onPressed: () async {
              final success = await viewModel.joinGroup(context);
              if (success) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'You have joined the group successfully',
                        style: TextStyle(
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                      backgroundColor: FlutterFlowTheme.of(context).secondary,
                    ),
                  );
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  }
                  context.pushNamed(
                    'communityPage', // Assuming route name
                    extra: <String, dynamic>{
                      kTransitionInfoKey: const TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                }
              }
            },
            backgroundColor: FlutterFlowTheme.of(context).primary,
            elevation: 8.0,
            label: viewModel.isLoading
                ? const SpinKitRipple(color: Colors.white, size: 30.0)
                : Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.6,
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          'Join Group',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.lexendDeca(),
                                color: FlutterFlowTheme.of(context).primaryBackground,
                                fontSize: 16.0,
                              ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
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
          onPressed: () async {
            context.pop();
          },
        ),
        title: Text(
          'About Group',
          style: FlutterFlowTheme.of(context).titleLarge.override(
                font: GoogleFonts.poppins(),
                color: FlutterFlowTheme.of(context).primaryBackground,
                fontSize: 20.0,
              ),
        ),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 90.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (group.groupImageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.network(
                                group.groupImageUrl!,
                                width: 90.0,
                                height: 90.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                            child: Text(
                              valueOrDefault<String>(group.name, 'name'),
                              style: FlutterFlowTheme.of(context).headlineSmall.override(
                                    font: GoogleFonts.lexendDeca(),
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                            child: Text(
                              '${group.groupPrivacy} group - ${formatNumber(
                                group.numberMembers,
                                formatType: FormatType.compact,
                              )} members',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexendDeca(fontWeight: FontWeight.w500),
                                    color: FlutterFlowTheme.of(context).secondary,
                                    fontSize: 16.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                  child: Text(
                    'Description',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(fontWeight: FontWeight.w500),
                          color: FlutterFlowTheme.of(context).secondary,
                          fontSize: 16.0,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                      child: Text(
                        valueOrDefault<String>(group.description, 'description'),
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.lexendDeca(),
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                      ),
                    ),
                  ),
                ),
                // Facilitators section
                FutureBuilder<List<CcViewGroupFacilitatorsRow>>(
                  future: CcViewGroupFacilitatorsTable().querySingleRow(
                    queryFn: (q) => q.eqOrNull('group_id', group.id),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: SpinKitRipple(
                            color: FlutterFlowTheme.of(context).primary,
                            size: 50.0,
                          ),
                        ),
                      );
                    }
                    final facilitators = snapshot.data!;
                    final facilitator = facilitators.isNotEmpty ? facilitators.first : null;

                    if (facilitator == null) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 0.0, 0.0),
                          child: Text(
                            'Facilitators',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexendDeca(fontWeight: FontWeight.w500),
                                  color: FlutterFlowTheme.of(context).secondary,
                                  fontSize: 16.0,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primaryBackground,
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                              child: Text(
                                facilitator.managerNames.join(", "),
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.lexendDeca(),
                                      color: FlutterFlowTheme.of(context).primary,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 0.0, 0.0),
                  child: Text(
                    'Group policy',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(fontWeight: FontWeight.w500),
                          color: FlutterFlowTheme.of(context).secondary,
                          fontSize: 16.0,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                      child: Text(
                        valueOrDefault<String>(group.policyMessage, 'policy message'),
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.lexendDeca(),
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
