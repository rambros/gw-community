import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';

void main() {
  testWidgets('FlutterFlowIconButton renders and triggers onPressed', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlutterFlowIconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verify the icon is rendered
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Tap the button
    await tester.tap(find.byType(FlutterFlowIconButton));
    await tester.pump();

    // Verify onPressed was called
    expect(tapped, isTrue);
  });
}
