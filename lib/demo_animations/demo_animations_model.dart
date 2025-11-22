import '/utils/flutter_flow_util.dart';
import 'demo_animations_widget.dart' show DemoAnimationsWidget;
import 'package:flutter/material.dart';

class DemoAnimationsModel extends FlutterFlowModel<DemoAnimationsWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
  }
}
