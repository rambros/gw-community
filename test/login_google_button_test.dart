import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gw_community/ui/auth/widgets/login_google_button.dart';

void main() {
  testWidgets('LoginGoogleButton renders and triggers onPressed', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LoginGoogleButton(
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      ),
    );

    // Verify the text is rendered
    expect(find.text('Sign in with Google'), findsOneWidget);

    // Verify the Google icon is rendered
    expect(find.byType(FaIcon), findsOneWidget);

    // Tap the button
    await tester.tap(find.text('Sign in with Google'));
    await tester.pump();

    // Verify onPressed was called
    expect(tapped, isTrue);
  });

  testWidgets('LoginGoogleButton shows loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LoginGoogleButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      ),
    );

    // Verify the signing in text is rendered
    expect(find.text('Signing in...'), findsOneWidget);
  });
}
