import 'package:flutter/widgets.dart';
import 'package:gw_community/data/repositories/home_repository.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';
import 'package:gw_community/ui/home/home_page/home_page.dart';
import 'package:gw_community/ui/home/home_page/view_model/home_view_model.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class ViewAsActions {
  static Future<void> start(
    BuildContext context, {
    required String authUserId,
    required String displayName,
  }) async {
    context.read<ViewAsSession>().start(
          ViewAsTarget(authUserId: authUserId, displayName: displayName),
        );
    await _reload(context);
    if (!context.mounted) return;
    context.goNamed(HomePage.routeName);
  }

  static Future<void> exit(BuildContext context) async {
    context.read<ViewAsSession>().stop();
    await _reload(context);
    if (!context.mounted) return;
    context.goNamed(HomePage.routeName);
  }

  static Future<void> _reload(BuildContext context) async {
    final homeRepo = context.read<HomeRepository>();
    await context.read<FFAppState>().loadGroupModuleConfig(homeRepo);
    if (!context.mounted) return;
    await context.read<HomeViewModel>().loadData();
  }
}
