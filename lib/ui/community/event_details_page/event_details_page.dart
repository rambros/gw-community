import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/event_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/community/event_details_page/view_model/event_details_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({
    super.key,
    required this.eventRow,
    this.groupId,
  });

  final CcEventsRow? eventRow;
  final int? groupId;

  static String routeName = 'EventDetailsPage';
  static String routePath = '/eventDetailsPage';

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late EventDetailsViewModel _viewModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    debugPrint('EventDetailsPage: initState. widget.eventRow=${widget.eventRow?.id}, title=${widget.eventRow?.title}');
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'eventDetails'});
    _viewModel = EventDetailsViewModel(
      repository: context.read<EventRepository>(),
      currentUserUid: context.currentUserIdOrEmpty,
      appState: context.read<FFAppState>(),
      initialEvent: widget.eventRow,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventId = widget.eventRow?.id;
      debugPrint('EventDetailsPage: PostFrameCallback. eventId from widget=$eventId');
      if (eventId != null) {
        _viewModel.initialize(eventId);
      } else {
        _viewModel.loadEvent();
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<EventDetailsViewModel>(
        builder: (context, viewModel, _) {
          debugPrint('EventDetailsPage: Building. viewModel.event=${viewModel.event?.id}');
          return PopScope(
            canPop: false,
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
                  onPressed: () async {
                    context.goNamed(
                      CommunityPage.routeName,
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 0),
                        ),
                      },
                    );
                  },
                ),
                title: Text(
                  'Event Details',
                  style: AppTheme.of(context).titleLarge.override(
                        font: GoogleFonts.poppins(
                          fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                          fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                        ),
                        color: AppTheme.of(context).primaryBackground,
                        fontSize: 20.0,
                        letterSpacing: 0.0,
                      ),
                ),
                centerTitle: true,
                elevation: 2.0,
              ),
              body: SafeArea(
                top: true,
                child: viewModel.event == null && viewModel.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.of(context).primary,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroImage(context, viewModel),
                            if (viewModel.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: AppTheme.of(context).labelMedium.copyWith(
                                        color: AppTheme.of(context).error,
                                      ),
                                ),
                              ),
                            _buildEventInfoSection(context, viewModel),
                            _buildParticipantsSection(context, viewModel),
                            _buildRegistrationSection(context, viewModel),
                            _buildAdminActions(context, viewModel),
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, EventDetailsViewModel viewModel) {
    final imageUrl = viewModel.event?.eventImageUrl ?? 'https://picsum.photos/seed/945/600';
    // Se o URL não for uma imagem (ex: mp3), podemos usar o placeholder
    final isImage = imageUrl.contains(RegExp(r'\.(jpg|jpeg|png|webp|gif)', caseSensitive: false));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.network(
          isImage ? imageUrl : 'https://picsum.photos/seed/945/600',
          width: MediaQuery.sizeOf(context).width,
          height: 140.0,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  Widget _buildEventInfoSection(BuildContext context, EventDetailsViewModel viewModel) {
    final event = viewModel.event;
    if (event == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 12.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valueOrDefault<String>(event.title, 'Title'),
              style: AppTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.lexendDeca(
                      fontWeight: AppTheme.of(context).headlineMedium.fontWeight,
                      fontStyle: AppTheme.of(context).headlineMedium.fontStyle,
                    ),
                    color: AppTheme.of(context).secondary,
                    letterSpacing: 0.0,
                  ),
            ),
            Text(
              'Facilitated by ${event.facilitatorName ?? '-'}',
              style: AppTheme.of(context).titleSmall.override(
                    font: GoogleFonts.lexendDeca(
                      fontWeight: AppTheme.of(context).titleSmall.fontWeight,
                      fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                    ),
                    letterSpacing: 0.0,
                  ),
            ),
            Text(
              viewModel.isPublic ? 'Open for everyone' : 'Open only for this group',
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(
                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: AppTheme.of(context).primary,
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                  child: FaIcon(
                    FontAwesomeIcons.calendarDays,
                    color: AppTheme.of(context).secondary,
                    size: 32.0,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${dateTimeFormat(
                      'MMMMEEEEd',
                      event.eventDate,
                      locale: FFLocalizations.of(context).languageCode,
                    )},  ${dateTimeFormat(
                      'jm',
                      event.eventTime?.time,
                      locale: FFLocalizations.of(context).languageCode,
                    )}',
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: AppTheme.of(context).secondary,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 12.0, 0.0),
                  child: FaIcon(
                    FontAwesomeIcons.clock,
                    color: AppTheme.of(context).secondary,
                    size: 32.0,
                  ),
                ),
                Text(
                  '${event.duration ?? 0} min',
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.lexendDeca(
                          fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: AppTheme.of(context).secondary,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
              child: Text(
                valueOrDefault<String>(event.description, 'description'),
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.lexendDeca(
                        fontWeight: AppTheme.of(context).bodySmall.fontWeight,
                        fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                      ),
                      color: AppTheme.of(context).secondary,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context, EventDetailsViewModel viewModel) {
    final participants = viewModel.participants;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 0.0, 0.0),
              child: Text(
                '${viewModel.participantsCount} People Registered',
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.lexendDeca(
                        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: AppTheme.of(context).secondary,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            if (participants.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No registrations yet.',
                  style: AppTheme.of(context).labelMedium,
                ),
              )
            else
              SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(participants.length, (index) {
                    final participant = participants[index];
                    return Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 6.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UserAvatar(
                            key: Key('participant_$index'),
                            imageUrl: participant.photoUrl,
                            fullName: participant.displayName,
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                            child: Text(
                              valueOrDefault<String>(participant.displayName, 'name'),
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexendDeca(
                                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationSection(BuildContext context, EventDetailsViewModel viewModel) {
    final isRegistered = viewModel.isUserRegistered;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isRegistered)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                child: FFButtonWidget(
                  onPressed: viewModel.isActionInProgress
                      ? null
                      : () async {
                          final success = await viewModel.register();
                          if (!success || !context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You are registered with success',
                                style: TextStyle(
                                  color: AppTheme.of(context).primaryText,
                                ),
                              ),
                              backgroundColor: AppTheme.of(context).secondary,
                            ),
                          );
                        },
                  text: viewModel.isActionInProgress ? 'Processing...' : 'Register',
                  options: FFButtonOptions(
                    width: 160.0,
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
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
              ),
            if (isRegistered)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                child: FFButtonWidget(
                  onPressed: viewModel.isActionInProgress
                      ? null
                      : () async {
                          final success = await viewModel.unregister();
                          if (!success || !context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You are unsubscribed with success',
                                style: TextStyle(
                                  color: AppTheme.of(context).primaryText,
                                ),
                              ),
                              backgroundColor: AppTheme.of(context).secondary,
                            ),
                          );
                        },
                  text: viewModel.isActionInProgress ? 'Processing...' : 'Unsubscribe',
                  options: FFButtonOptions(
                    width: 160.0,
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
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
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context, EventDetailsViewModel viewModel) {
    if (!viewModel.canEdit || viewModel.event == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 24.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (viewModel.canDelete)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    final confirmDialogResponse = await showDialog<bool>(
                          context: context,
                          builder: (alertDialogContext) {
                            return WebViewAware(
                              child: AlertDialog(
                                title: const Text('Confirmation'),
                                content: const Text('Delete this event?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(alertDialogContext, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(alertDialogContext, true),
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ) ??
                        false;
                    if (!confirmDialogResponse) {
                      return;
                    }
                    final success = await viewModel.deleteEvent();
                    if (!success || !context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Event deleted with success',
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                          ),
                        ),
                        backgroundColor: AppTheme.of(context).secondary,
                      ),
                    );
                    context.goNamed(CommunityPage.routeName);
                  },
                  text: 'Delete',
                  options: FFButtonOptions(
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
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
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
              child: FFButtonWidget(
                onPressed: () async {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  }
                  context.pushNamed(
                    EventEditPage.routeName,
                    queryParameters: {
                      'eventRow': serializeParam(
                        viewModel.event,
                        ParamType.SupabaseRow,
                      ),
                      'groupId': serializeParam(
                        widget.groupId,
                        ParamType.int,
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
                text: 'Edit',
                options: FFButtonOptions(
                  height: 40.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
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
            ),
          ],
        ),
      ),
    );
  }
}
