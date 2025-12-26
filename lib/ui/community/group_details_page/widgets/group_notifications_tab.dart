import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/data/services/supabase/supabase.dart';
import '/index.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/core/widgets/user_avatar.dart';
import '/utils/flutter_flow_util.dart';
import '../view_model/group_details_view_model.dart';

class GroupNotificationsTab extends StatelessWidget {
  const GroupNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupDetailsViewModel>();
    final group = viewModel.group;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Notifications',
                    style: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.w500,
                          ),
                          fontSize: 18.0,
                        ),
                  ),
                ),
              ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
            child: StreamBuilder<List<CcViewNotificationsUsersRow>>(
              stream: viewModel.notificationsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: SpinKitRipple(
                        color: AppTheme.of(context).primary,
                        size: 50.0,
                      ),
                    ),
                  );
                }
                final notificationsList = snapshot.data!;
                if (notificationsList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No notifications yet.',
                        style: AppTheme.of(context).bodyMedium,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notificationsList.length,
                  itemBuilder: (context, index) {
                    final notification = notificationsList[index];
                    return Align(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                        child: InkWell(
                          onTap: () {
                            context.pushNamed(
                              NotificationViewPage.routeName,
                              queryParameters: {
                                'notificationId': serializeParam(
                                  notification.id,
                                  ParamType.int,
                                ),
                              }.withoutNulls,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).primaryBackground,
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 15.0,
                                  color: Color(0x1A000000),
                                  offset: Offset(0.0, 7.0),
                                  spreadRadius: 3.0,
                                )
                              ],
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: AppTheme.of(context).primaryBackground,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        UserAvatar(
                                          imageUrl: notification.photoUrl,
                                          fullName: notification.fullName,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  notification.displayName ?? 'User name',
                                                  style: AppTheme.of(context).bodyMedium.override(
                                                        font: GoogleFonts.lexendDeca(),
                                                        color: AppTheme.of(context).secondary,
                                                        fontSize: 16.0,
                                                      ),
                                                ),
                                                Text(
                                                  dateTimeFormat('relative', notification.updatedAt),
                                                  style: AppTheme.of(context).labelSmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                                    child: Text(
                                      notification.title!,
                                      style: AppTheme.of(context).bodyLarge.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                            ),
                                            color: AppTheme.of(context).primary,
                                            fontSize: 16.0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
    Positioned(
      bottom: 16.0,
      right: 16.0,
      child: FloatingActionButton.extended(
        onPressed: () async {
          context.pushNamed(
            NotificationAddPage.routeName,
            queryParameters: {
              'groupId': serializeParam(
                group.id,
                ParamType.int,
              ),
              'groupName': serializeParam(
                group.name,
                ParamType.String,
              ),
            }.withoutNulls,
            extra: <String, dynamic>{
              kTransitionInfoKey: const TransitionInfo(
                hasTransition: true,
                transitionType: PageTransitionType.fade,
                duration: Duration(milliseconds: 0),
              ),
            },
          );
        },
        backgroundColor: AppTheme.of(context).primary,
        elevation: 8.0,
        icon: Icon(
          Icons.add,
          color: AppTheme.of(context).primaryBackground,
        ),
        label: Text(
          'New notification',
          style: AppTheme.of(context).labelLarge.override(
                font: GoogleFonts.poppins(),
                color: AppTheme.of(context).primaryBackground,
              ),
        ),
      ),
    ),
    ],
    );
  }
}
