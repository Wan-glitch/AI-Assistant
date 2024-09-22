import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_ai_assistant/main.dart';

void main() {
  testWidgets('AI Assistant app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyAIApp());

    // Verify that the app title is displayed
    expect(find.text('My AI Assistant'), findsOneWidget);

    // Verify that the 'AI is running in the background...' text is displayed
    expect(find.text('AI is running in the background...'), findsOneWidget);

    // Verify that the 'Start Listening' button is present
    expect(find.text('Start Listening'), findsOneWidget);

    // Tap the 'Start Listening' button and trigger a frame.
    await tester.tap(find.text('Start Listening'));
    await tester.pump();

    // Verify that the button text changes to 'Stop Listening'
    expect(find.text('Stop Listening'), findsOneWidget);
  });
}